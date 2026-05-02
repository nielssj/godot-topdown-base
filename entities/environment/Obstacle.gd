class_name Obstacle
extends StaticBody3D

@export var health: int = 4

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

const DAMAGE_ANIMATION = "ObstacleAnimations/pulse"
const DEATH_ANIMATION = "ObstacleAnimations/death"


func damage(amount: int, _source: Node3D = null) -> void:
	if health <= 0:
		return
	health = health - amount
	animation_player.play(DAMAGE_ANIMATION)
	if health <= 0:
		_explode()


func _explode() -> void:
	collision_shape.set_deferred("disabled", true)
	animation_player.stop()
	animation_player.play(DEATH_ANIMATION)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == DEATH_ANIMATION:
		queue_free()
