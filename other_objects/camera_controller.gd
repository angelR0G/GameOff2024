class_name FollowCamera extends Node3D

const LERP_FACTOR := 2.0
const TARGET_SPEED_FACTOR := 1.5

@export var target:Node3D = null

static var Instance :FollowCamera = null

func _ready() -> void:
	Instance = self

func _process(delta: float) -> void:
	if target != null:
		var target_position := target.global_position
		if target is CharacterBody3D:
			target_position += (target as CharacterBody3D).velocity/TARGET_SPEED_FACTOR
			
		global_position = lerp(global_position, target_position, LERP_FACTOR * delta)
		


func set_target(node:Node3D) -> void:
	target = node

func get_camera_rotation() -> float:
	return rotation.y

func get_camera() -> Camera3D:
	return $Camera3D
