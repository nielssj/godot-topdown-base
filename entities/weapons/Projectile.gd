class_name Projectile
extends Area3D

var _velocity: Vector3 = Vector3.ZERO
var _lifetime: float = 0.0
var _max_lifetime: float = 0.0
var _damage: float = 0.0
var _active: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_physics_process(false)

func is_active() -> bool:
	return _active

func activate(pos: Vector3, dir: Vector3, speed: float, max_lifetime: float, damage: float) -> void:
	global_position = pos
	_velocity = dir.normalized() * speed
	_lifetime = 0.0
	_max_lifetime = max_lifetime
	_damage = damage
	_active = true
	visible = true
	monitoring = true
	set_physics_process(true)

func deactivate() -> void:
	_active = false
	_velocity = Vector3.ZERO
	visible = false
	set_deferred("monitoring", false)
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	global_position += _velocity * delta
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		deactivate()

func _on_body_entered(_body: Node) -> void:
	if _body is Obstacle:
		(_body as Obstacle).damage(1)
	if _active:
		deactivate()
