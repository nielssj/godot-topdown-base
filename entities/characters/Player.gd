class_name Player
extends CharacterBody3D

@export var speed: float = 4.0
@export var fall_acceleration: float = 75.0
@export var enable_control: bool = true

@onready var mesh = $Mesh
@onready var weapon: Weapon = get_node_or_null("Mesh/Weapon")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta):
	# Handle movement input only if control is enabled
	if enable_control:
		# Two-axis input (supporting both WASD and controller joystick)
		var input_vector = Input.get_vector("move_forward", "move_back", "move_right", "move_left")
		var direction = Vector3(input_vector.x, 0, input_vector.y)

		# Calculate effective speed based on what we're carrying
		var effective_speed = speed

		# Turn player towards current move direction
		if direction != Vector3.ZERO:
			direction = direction.normalized()
			mesh.look_at(position + direction, Vector3.UP)

		# Ground velocity
		velocity.x = direction.x * effective_speed
		velocity.z = direction.z * effective_speed

		# Downward velocity (gravity) - always apply
		velocity.y -= fall_acceleration * delta

		# Move
		move_and_slide()

		# Trigger weapon
		if weapon and Input.is_action_just_pressed("fire"):
			animation_player.play("PlayerAnimations/Casting")
			weapon.fire_pressed()
		if weapon and Input.is_action_just_released("fire"):
			weapon.fire_released()
