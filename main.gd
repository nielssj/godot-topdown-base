extends Node3D

@onready var main_hud: HUD = $MainHUD


func _ready() -> void:
	main_hud.visible = false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.died.connect(_on_enemy_died)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_enemy_died() -> void:
	if not _are_all_enemies_dead():
			return
	main_hud.visible = true
	main_hud.win_message.visible = true


func _are_all_enemies_dead() -> bool:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.is_dead:
			return false
	return true
