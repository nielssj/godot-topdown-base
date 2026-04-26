extends GutTest

var PlayerScene = preload("res://entities/characters/player.tscn")

var player: Player

func before_each():
	# Create player instance
	player = PlayerScene.instantiate()
	add_child_autofree(player)

func after_each():
	if is_instance_valid(player) and not player.is_queued_for_deletion():
		player.queue_free()
		player = null

# Test that the player is initialized properly
func test_player_initialization():
	assert_not_null(player, "Player instance should be created")
	assert_eq(player.speed, 4.0, "Player default speed should be 4")
	assert_eq(player.fall_acceleration, 75.0, "Player default fall_acceleration should be 75")
	assert_true(player.enable_control, "Player control should be enabled by default")
