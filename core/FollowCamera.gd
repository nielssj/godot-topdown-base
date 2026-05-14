class_name FollowCamera
extends Camera3D

# Source: Adapted from https://kidscancode.org/godot_recipes/3d/interpolated_camera/
# Updated for Godot 4 syntax and improved functionality

@export var lerp_speed: float = 3.0
@export var target_path: NodePath = NodePath() : set = set_target_path
@export var offset: Vector3 = Vector3(-2, 2, 4)

var target: Node3D = null
var top_down_on: bool = false # Top down mode: offset to more birds-like view
var top_down_correction: Vector3 = Vector3(0, 0, -4) # Offset correction to be made in top-down mode

func set_target_path(value: NodePath) -> void:
	target_path = value
	if target_path != NodePath() and has_node(value):
		target = get_node(value)

func _ready() -> void:
	if target_path != NodePath():
		# Defer to ensure all nodes are ready
		call_deferred("_find_target")

func _find_target() -> void:
	if target_path != NodePath() and has_node(target_path):
		target = get_node(target_path)

# Check if camera has line of sight (is not blocked by a wall)
func _has_line_of_sight() -> bool:
	if not target:
		return true

	var space_state = get_world_3d().direct_space_state
	var target_origin = target.global_position
	var camera_origin = global_position
	var collision_layer = 1 << 3 # layer 4 - walls

	if top_down_on:
		camera_origin = camera_origin - top_down_correction

	var query = PhysicsRayQueryParameters3D.create(camera_origin, target_origin)
	query.collision_mask = collision_layer
	query.exclude = []

	var result = space_state.intersect_ray(query)
	if result:
		return false
	return true

func _physics_process(delta: float) -> void:
	if not target:
		return

	var target_pos: Transform3D
	if not _has_line_of_sight():
		# No line-of-sight: enable top down mode (corrected offset)
		var corrected_offset = offset + top_down_correction
		target_pos = target.global_transform * Transform3D(Basis(), corrected_offset)
		top_down_on = true
	else:
		# Default: orthographic-like mode (regular offset)
		target_pos = target.global_transform * Transform3D(Basis(), offset)
		top_down_on = false

	global_transform = global_transform.interpolate_with(target_pos, lerp_speed * delta)
	look_at(target.global_position, Vector3.UP)
