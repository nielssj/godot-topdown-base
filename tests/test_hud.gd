extends GutTest

const MainScene = preload("res://main.tscn")

var main: Main
var hud: HUD


func before_each() -> void:
	main = MainScene.instantiate()
	add_child_autofree(main)
	hud = main.get_node("MainHUD")


func test_init_hides_hud_and_messages() -> void:
	assert_false(hud.visible)
	assert_false(hud.win_message.visible)
	assert_false(hud.lose_message.visible)


func test_game_won_shows_win_message() -> void:
	main.game_won.emit()
	assert_true(hud.visible)
	assert_true(hud.win_message.visible)
	assert_false(hud.lose_message.visible)


func test_game_lost_shows_lose_message() -> void:
	main.game_lost.emit()
	assert_true(hud.visible)
	assert_true(hud.lose_message.visible)
	assert_false(hud.win_message.visible)
