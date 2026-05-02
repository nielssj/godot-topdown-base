class_name Obstacle
extends StaticBody3D


# How much damage the obstacle is able to sustain without before breaking
@export var health: int = 4


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var destroy_timer: Timer = $DestroyTimer

var _exploded: bool = false


func _ready() -> void:
	destroy_timer.timeout.connect(queue_free)


func damage(amount: int, _source: Node3D = null) -> void:
	if _exploded:
		return
	health = health - amount
	animation_player.play("pulse")
	if health <= 0:
		_explode()


func _explode() -> void:
	_exploded = true
	particles.emitting = true
	mesh_instance.visible = false
	collision_shape.set_deferred("disabled", true)
	destroy_timer.start()
