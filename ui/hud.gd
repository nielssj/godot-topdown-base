class_name HUD
extends CanvasLayer

@onready var win_message: Control = $CenterContainer/WinMessage
@onready var lose_message: Control = $CenterContainer/LoseMessage

@export var game_manager: GameManager


func _ready() -> void:
	self.visible = false
	win_message.visible = false
	lose_message.visible = false
	if game_manager:
		game_manager.game_won.connect(_on_game_won)
		game_manager.game_lost.connect(_on_game_lost)


func _on_game_won() -> void:
	self.visible = true
	win_message.visible = true


func _on_game_lost() -> void:
	self.visible = true
	lose_message.visible = true
