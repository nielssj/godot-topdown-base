class_name SingleFireMode
extends FireMode

@export var projectile_speed: float = 20.0
@export var projectile_lifetime: float = 3.0
@export var projectile_damage: float = 1.0

func fire_pressed(weapon: Weapon) -> bool:
	var dir := -weapon.global_transform.basis.z
	var pos := weapon.global_position
	for p in weapon._pool:
		if not p.is_active():
			p.activate(pos, dir, projectile_speed, projectile_lifetime, projectile_damage)
			return true
	return false
