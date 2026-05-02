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
	assert_false(obstacle.collision_shape.disabled, "CollisionShape3D should start enabled")


func test_damage_reduces_health():
	obstacle.damage(1)
	assert_eq(obstacle.health, 3, "Health should decrease by damage amount")
	assert_false(obstacle.collision_shape.disabled, "Non-lethal damage should not disable collision")


func test_damage_to_zero_triggers_explosion():
	obstacle.damage(4)
	await get_tree().process_frame
	assert_eq(obstacle.health, 0, "Health should reach 0")
	assert_eq(obstacle.animation_player.current_animation, "death", "Death animation should be playing after lethal damage")
	assert_true(obstacle.collision_shape.disabled, "CollisionShape3D should be disabled")


func test_overkill_damage_still_triggers_explosion():
	obstacle.damage(99)
	await get_tree().process_frame
	assert_true(obstacle.collision_shape.disabled, "Overkill damage should still disable collision")


func test_damage_after_explosion_is_ignored():
	obstacle.damage(4)
	obstacle.damage(2)
	assert_eq(obstacle.health, 0, "Damage after health reaches 0 should be ignored — health stays at 0")


func test_death_animation_triggers_queue_free():
	obstacle.damage(4)
	assert_false(obstacle.is_queued_for_deletion(), "Obstacle should not be queued for deletion before animation finishes")
	obstacle.animation_player.animation_finished.emit("death")
	assert_true(obstacle.is_queued_for_deletion(), "Obstacle should be queued for deletion after death animation finishes")
