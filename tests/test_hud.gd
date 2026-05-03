extends GutTest

const HudScene = preload("res://ui/hud.tscn")

var game_manager: GameManager
var hud: HUD


func before_each() -> void:
	game_manager = GameManager.new()
	add_child_autofree(game_manager)
	hud = HudScene.instantiate()
	hud.game_manager = game_manager
	add_child_autofree(hud)


func test_init_hides_hud_and_messages() -> void:
	assert_false(hud.visible)
	assert_false(hud.win_message.visible)
	assert_false(hud.lose_message.visible)


func test_game_won_shows_win_message() -> void:
	game_manager.game_won.emit()
	assert_true(hud.visible)
	assert_true(hud.win_message.visible)
	assert_false(hud.lose_message.visible)


func test_game_lost_shows_lose_message() -> void:
	game_manager.game_lost.emit()
	assert_true(hud.visible)
	assert_true(hud.lose_message.visible)
	assert_false(hud.win_message.visible)
