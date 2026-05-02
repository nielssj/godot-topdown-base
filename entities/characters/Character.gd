class_name Character
extends CharacterBody3D

@export var health: int = 10

var is_dead: bool = false

signal damage_taken(amount: int)
signal died

func damage(amount: int) -> void:
	if not is_dead:
		health -= amount
		damage_taken.emit(amount)
		if health <= 0:
			is_dead = true
			died.emit()
