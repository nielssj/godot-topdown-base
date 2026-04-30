class_name Weapon
extends Node3D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.0
@export var pool_size: int = 10
@export var projectile_speed: float = 20.0
@export var projectile_lifetime: float = 3.0
@export var projectile_damage: float = 1.0

var _pool: Array[Projectile] = []
var _cooldown: float = 0.0

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
	if _cooldown > 0.0:
		_cooldown -= delta

func fire() -> bool:
	if _cooldown > 0.0:
		return false
	var dir := -global_transform.basis.z
	var pos := global_position
	for p in _pool:
		if not p.is_active():
			p.activate(pos, dir, projectile_speed, projectile_lifetime, projectile_damage)
			_cooldown = 1.0 / fire_rate
			return true
	return false

func get_pool_size() -> int:
	return _pool.size()

func get_active_count() -> int:
	var count := 0
	for p in _pool:
		if p.is_active():
			count += 1
	return count
