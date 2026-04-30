extends GutTest

var WeaponScene = preload("res://entities/weapons/Weapon.tscn")
var SingleFireModeScript = preload("res://entities/weapons/fire_mode/SingleFireMode.gd")

class StubFireMode extends FireMode:
	var pressed_count: int = 0
	var released_count: int = 0
	var process_count: int = 0
	var pressed_returns: bool = true
	var released_returns: bool = true

	func fire_pressed(_weapon: Weapon) -> bool:
		pressed_count += 1
		return pressed_returns

	func fire_released(_weapon: Weapon) -> bool:
		released_count += 1
		return released_returns

	func process(_weapon: Weapon, _delta: float) -> void:
		process_count += 1

var weapon: Weapon

func _make_weapon(fire_mode: FireMode) -> Weapon:
	var w: Weapon = WeaponScene.instantiate()
	w.fire_mode = fire_mode
	add_child_autofree(w)
	await get_tree().process_frame
	return w

func test_pool_is_populated_and_inactive():
	weapon = await _make_weapon(StubFireMode.new())
	assert_eq(weapon.get_pool_size(), 10, "pool should contain pool_size projectiles")
	assert_eq(weapon.get_active_count(), 0, "all projectiles should start inactive")

func test_fire_pressed_forwards_to_fire_mode():
	var stub := StubFireMode.new()
	stub.pressed_returns = false
	weapon = await _make_weapon(stub)
	assert_false(weapon.fire_pressed(), "fire_pressed should return fire_mode's result")
	assert_eq(stub.pressed_count, 1, "fire_pressed should be delegated to fire_mode exactly once")

func test_fire_released_forwards_to_fire_mode():
	var stub := StubFireMode.new()
	stub.released_returns = false
	weapon = await _make_weapon(stub)
	assert_false(weapon.fire_released(), "fire_released should return fire_mode's result")
	assert_eq(stub.released_count, 1, "fire_released should be delegated to fire_mode exactly once")

func test_physics_process_forwards_to_fire_mode():
	var stub := StubFireMode.new()
	weapon = await _make_weapon(stub)
	weapon._physics_process(0.016)
	assert_eq(stub.process_count, 1, "_physics_process should delegate to fire_mode.process")

func test_single_fire_mode_integration_activates_projectile():
	weapon = await _make_weapon(SingleFireModeScript.new())
	assert_true(weapon.fire_pressed(), "fire_pressed should succeed when pool has an inactive projectile")
	assert_eq(weapon.get_active_count(), 1, "active count should be 1 after one fire_pressed()")
