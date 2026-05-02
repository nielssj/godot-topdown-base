class_name NPC
extends Character

# How fast the NPC moves in meters per second
@export var speed: float = 3.0
@export var attack_range: float = 2.0
@export var resume_chase_range: float = 3.0

enum State {
	IDLE,
	CHASING,
	ATTACKING,
	DEAD,
}

# Reference to child model node
@onready var model = $Model
@onready var weapon: Weapon = get_node_or_null("Model/Weapon")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# The node the NPC is currently pursuing
var target: Node3D = null

var state: State = State.IDLE:
	set(value):
		# Exit functions (match on OLD state before assignment)
		if state != value:
			match state:
				State.IDLE:
					pass
				State.CHASING:
					pass
				State.ATTACKING:
					_exit_attacking()
		# Assign new state
		state = value
		# Enter functions (match on NEW state after assignment)
		match state:
			State.IDLE:
				_enter_idle()
			State.CHASING:
				_enter_chasing()
			State.ATTACKING:
				_enter_attacking()
			State.DEAD:
				_enter_dead()

func _physics_process(_delta: float) -> void:
	# Delegate per-frame logic to the active state
	match state:
		State.IDLE:
			pass
		State.CHASING:
			_tick_chasing()
		State.ATTACKING:
			_tick_attacking()
		State.DEAD:
			pass

func _enter_idle() -> void:
	pass

func _enter_chasing() -> void:
	pass

func _enter_attacking() -> void:
	velocity = Vector3.ZERO
	if weapon:
		weapon.fire_pressed()

func _exit_attacking() -> void:
	velocity = Vector3.ZERO
	if weapon:
		weapon.fire_released()

func _enter_dead() -> void:
	velocity = Vector3.ZERO
	collision_shape.set_deferred("disabled", true)
	animation_player.stop()
	animation_player.play("NPCAnimations/Death")

func _tick_chasing() -> void:
	# Vector from NPC to target, flattened to the horizontal plane
	var to_target := target.global_position - global_position
	to_target.y = 0.0
	var direction := to_target.normalized()
	# Turn NPC model towards target
	model.look_at(global_position + direction, Vector3.UP)
	# Move
	velocity = direction * speed
	move_and_slide()
	if to_target.length() <= attack_range:
		state = State.ATTACKING

func _tick_attacking() -> void:
	var to_target := target.global_position - global_position
	to_target.y = 0.0
	var direction := to_target.normalized()
	model.look_at(global_position + direction, Vector3.UP)
	velocity = Vector3.ZERO
	move_and_slide()
	if to_target.length() > resume_chase_range:
		state = State.CHASING
		return
	if weapon:
		weapon.fire_pressed()

func _on_vision_area_body_entered(body: Node3D) -> void:
	# Only an idle NPC reacts to vision
	if state != State.IDLE:
		return
	if body.is_in_group("player"):
		target = body
		state = State.CHASING

func _on_damage_taken(_amount: int, source: Node3D) -> void:
	if source != null and state != State.DEAD:
		target = source
		state = State.CHASING
	animation_player.stop()
	animation_player.play("NPCAnimations/Pulse")

func _on_died() -> void:
	state = State.DEAD
