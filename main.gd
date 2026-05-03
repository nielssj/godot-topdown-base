class_name Main
extends Node3D

signal game_won
signal game_lost


func _ready() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.died.connect(_on_enemy_died)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_enemy_died() -> void:
	if _are_all_enemies_dead():
		game_won.emit()


func _are_all_enemies_dead() -> bool:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.is_dead:
			return false
	return true


func _on_player_died() -> void:
	game_lost.emit()
