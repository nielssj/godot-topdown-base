class_name AutoFireMode
extends FireMode

@export var fire_rate: float = 1.0
@export var projectile_speed: float = 20.0
@export var projectile_lifetime: float = 3.0
@export var projectile_damage: float = 1.0

var _is_firing: bool = false
var _cooldown: float = 0.0

func fire_pressed(_weapon: Weapon) -> bool:
	_is_firing = true
	return true

func fire_released(_weapon: Weapon) -> bool:
	_is_firing = false
	return true

func process(weapon: Weapon, delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta
	if not _is_firing:
		return
	if _cooldown > 0.0:
		return
	var dir := -weapon.global_transform.basis.z
	var pos := weapon.global_position
	for p in weapon._pool:
		if not p.is_active():
			p.activate(pos, dir, projectile_speed, projectile_lifetime, projectile_damage, weapon.source)
			_cooldown = 1.0 / fire_rate
			return
