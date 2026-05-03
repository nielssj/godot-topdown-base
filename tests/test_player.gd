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
	assert_false(player.animation_player.is_playing(), "No animation should be playing on init")

func test_damage_taken_plays_damage_animation():
	player.damage_taken.emit(1, null)
	assert_eq(player.animation_player.current_animation, Player.DAMAGE_ANIMATION)
