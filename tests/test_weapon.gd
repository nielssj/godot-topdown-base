extends GutTest

var WeaponScene = preload("res://entities/weapons/Weapon.tscn")

var weapon

func before_each():
	weapon = WeaponScene.instantiate()
	add_child_autofree(weapon)
	await get_tree().process_frame

func after_each():
	if is_instance_valid(weapon) and not weapon.is_queued_for_deletion():
		weapon.queue_free()
		weapon = null

func test_weapon_initialization():
	assert_eq(weapon.fire_rate, 1.0, "fire_rate default should be 1.0")
	assert_eq(weapon.pool_size, 10, "pool_size default should be 10")
	assert_eq(weapon.projectile_speed, 20.0, "projectile_speed default should be 20.0")
	assert_eq(weapon.projectile_lifetime, 3.0, "projectile_lifetime default should be 3.0")

func test_pool_is_populated_and_inactive():
	assert_eq(weapon.get_pool_size(), 10, "pool should contain pool_size projectiles")
	assert_eq(weapon.get_active_count(), 0, "all projectiles should start inactive")

func test_fire_activates_one_projectile():
	var result: bool = weapon.fire()
	assert_true(result, "fire() should return true when pool has inactive projectiles")
	assert_eq(weapon.get_active_count(), 1, "active count should be 1 after one fire()")
	var active: Projectile = null
	for p: Projectile in weapon._pool:
		if p.is_active():
			active = p
			break
	assert_not_null(active, "an active Projectile instance from the default projectile scene should exist in the pool")
	assert_is(active, Projectile, "active projectile should be an instance of the default Projectile scene")

func test_pool_exhaustion_returns_false():
	for i in weapon.pool_size:
		weapon._cooldown = 0.0
		var result: bool = weapon.fire()
		assert_true(result, "fire() call %d should return true" % i)
	assert_eq(weapon.get_active_count(), weapon.pool_size, "all projectiles should be active")
	weapon._cooldown = 0.0
	var exhausted: bool = weapon.fire()
	assert_false(exhausted, "fire() should return false when pool is exhausted")
	assert_eq(weapon.get_active_count(), weapon.pool_size, "active count should not change after exhausted fire()")

func test_fire_respects_cooldown():
	assert_true(weapon.fire(), "first fire should succeed")
	assert_false(weapon.fire(), "second immediate fire should fail due to cooldown")
	weapon._cooldown = 0.0
	assert_true(weapon.fire(), "fire should succeed again after cooldown clears")
