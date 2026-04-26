extends GutTest

var ObstacleScene = preload("res://entities/environment/Obstacle.tscn")

var obstacle: Obstacle


func before_each():
	obstacle = ObstacleScene.instantiate()
	add_child_autofree(obstacle)
	await get_tree().process_frame


func after_each():
	if is_instance_valid(obstacle) and not obstacle.is_queued_for_deletion():
		obstacle.queue_free()
		obstacle = null


func test_obstacle_initialization():
	assert_not_null(obstacle, "Obstacle instance should be created")
	assert_eq(obstacle.health, 4, "Obstacle default health should be 4")
	assert_true(obstacle.mesh_instance.visible, "MeshInstance3D should start visible")
	assert_false(obstacle.collision_shape.disabled, "CollisionShape3D should start enabled")
	assert_false(obstacle.particles.emitting, "GPUParticles3D should start inert")
	assert_true(obstacle.destroy_timer.is_stopped(), "DestroyTimer should not be running initially")
	assert_false(obstacle._exploded, "Obstacle should not be marked exploded initially")


func test_damage_reduces_health():
	obstacle.damage(1)
	assert_eq(obstacle.health, 3, "Health should decrease by damage amount")
	assert_false(obstacle._exploded, "Non-lethal damage should not trigger explosion")
	assert_true(obstacle.destroy_timer.is_stopped(), "DestroyTimer should not start on non-lethal damage")


func test_damage_to_zero_triggers_explosion():
	obstacle.damage(4)
	# flush the deferred collision_shape.disabled = true
	await get_tree().process_frame
	assert_eq(obstacle.health, 0, "Health should reach 0")
	assert_true(obstacle._exploded, "Obstacle should be marked exploded")
	assert_true(obstacle.particles.emitting, "Particles should be emitting")
	assert_false(obstacle.mesh_instance.visible, "MeshInstance3D should be hidden")
	assert_true(obstacle.collision_shape.disabled, "CollisionShape3D should be disabled")
	assert_false(obstacle.destroy_timer.is_stopped(), "DestroyTimer should be running after explosion")


func test_overkill_damage_still_triggers_explosion():
	obstacle.damage(99)
	await get_tree().process_frame
	assert_true(obstacle._exploded, "Overkill damage should still trigger explosion")
	assert_true(obstacle.particles.emitting, "Particles should be emitting after overkill")


func test_damage_after_explosion_is_ignored():
	obstacle.damage(4)
	obstacle.damage(2)
	assert_eq(obstacle.health, 0, "Damage after explosion should be ignored — health stays at 0")


func test_destroy_timer_triggers_queue_free():
	obstacle.damage(4)
	await get_tree().process_frame
	assert_false(obstacle.is_queued_for_deletion(), "Obstacle should not be queued for deletion before timer fires")
	obstacle.destroy_timer.timeout.emit()
	assert_true(obstacle.is_queued_for_deletion(), "Obstacle should be queued for deletion after timer timeout")
