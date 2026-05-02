class_name HUD
extends CanvasLayer

@onready var win_message: Control = $CenterContainer/WinMessage
@onready var lose_message: Control = $CenterContainer/LoseMessage


func _ready() -> void:
	win_message.visible = false
	lose_message.visible = false
