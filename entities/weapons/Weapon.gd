class_name Weapon
extends Node3D

@export var projectile_scene: PackedScene
@export var pool_size: int = 10
@export var fire_mode: FireMode

var _pool: Array[Projectile] = []

func _ready() -> void:
	_build_pool.call_deferred()

func _build_pool() -> void:
	var parent: Node = get_tree().current_scene if get_tree().current_scene else get_tree().root
	for i in pool_size:
		var p: Projectile = projectile_scene.instantiate()
		parent.add_child(p)
		p.deactivate()
		_pool.append(p)

func _exit_tree() -> void:
	for p in _pool:
		if is_instance_valid(p):
			p.queue_free()
	_pool.clear()

func _physics_process(delta: float) -> void:
	fire_mode.process(self, delta)

func fire_pressed() -> bool:
	return fire_mode.fire_pressed(self)

func fire_released() -> bool:
	return fire_mode.fire_released(self)

func get_pool_size() -> int:
	return _pool.size()

func get_active_count() -> int:
	var count := 0
	for p in _pool:
		if p.is_active():
			count += 1
	return count
