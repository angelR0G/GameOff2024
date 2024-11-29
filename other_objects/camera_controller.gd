class_name FollowCamera extends Node3D

@onready var camera: Camera3D = $Camera3D

const MOVEMENT_LERP_FACTOR := 2.0
const ZOOM_LERP_FACTOR := 3.0
const TARGET_SPEED_FACTOR := 1.5
const MIN_ZOOM := 20.0
const MAX_ZOON := 52.0

@export var target:Node3D = null

static var Instance :FollowCamera = null
var target_zoom := 0.0
var zoom_enabled := true

func _ready() -> void:
	Instance = self
	camera.make_current()
	target_zoom = camera.size
	
	# Update player and motorbike audio listeners' rotation
	if Player.Instance:
		Player.Instance.audio_listener.rotation.y = rotation.y
	var motorbike :Motorbike = get_tree().get_first_node_in_group("bike")
	if motorbike != null:
		motorbike.audio_listener.rotation.y = rotation.y

func _process(delta: float) -> void:
	move_to_target(delta)
	update_zoom(delta)


func move_to_target(delta:float) -> void:
	if target == null:
		return
	
	var target_position := target.global_position
	if target is CharacterBody3D:
		target_position += (target as CharacterBody3D).velocity/TARGET_SPEED_FACTOR
		
	global_position = lerp(global_position, target_position, MOVEMENT_LERP_FACTOR * delta)

func update_zoom(delta:float) -> void:
	if target_zoom == camera.size:
		return
	
	camera.size = lerp(camera.size, target_zoom, ZOOM_LERP_FACTOR * delta)
	# Update audio bus volume
	var bus_volume := remap(camera.size, MIN_ZOOM, MAX_ZOON, 0.0, -12.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("World"), bus_volume)

func _unhandled_input(event: InputEvent) -> void:
	if zoom_enabled:
		if event.is_action_pressed("zoom_in"):
			target_zoom = maxf(MIN_ZOOM, target_zoom - 4.0)
		elif event.is_action_pressed("zoom_out"):
			target_zoom = minf(target_zoom + 4.0, MAX_ZOON)

func set_target(node:Node3D) -> void:
	target = node

func get_camera_rotation() -> float:
	return rotation.y

func get_camera() -> Camera3D:
	return camera
