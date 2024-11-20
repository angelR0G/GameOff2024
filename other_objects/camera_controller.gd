class_name FollowCamera extends Node3D

@export var target:Node3D = null

static var Instance :FollowCamera = null

func _ready() -> void:
	Instance = self

func _process(_delta: float) -> void:
	if target != null:
		global_position = target.global_position


func set_target(node:Node3D) -> void:
	target = node

func get_camera_rotation() -> float:
	return rotation.y
