class_name FireMode
extends Resource

func fire_pressed(_weapon: Weapon) -> bool:
	return true # Virtual function, implement in sub-classes

func fire_released(_weapon: Weapon) -> bool:
	return true # Virtual function, implement in sub-classes

func process(_weapon: Weapon, _delta: float) -> void:
	pass # Virtual function, implement in sub-classes
