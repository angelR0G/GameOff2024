class_name Player extends CharacterBody3D

static var Instance :Player = null
const _material_container := preload("res://materials/material_container.gd")
const ROTATION_SPEED := 6.0

@export var speed :float = 8.0
@export var fall_acceleration = 75
@export var movement_enabled :bool
var machines :MachineContainer = MachineContainer.new()
var materials :MaterialContainer = MaterialContainer.new()

@onready var hud :Hud = $Hud
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var container_manager: ContainerManagerUI = $ContainerManager
@onready var footsteps_timer: Timer = $FootstepsTimer
@onready var footsteps_audio: AudioStreamPlayer3D = $FootstepsTimer/FootstepsAudio
@onready var audio_listener: AudioListener3D = $AudioListener3D
@onready var cheats: CheatMode = $Cheats
@onready var interact_message: MeshInstance3D = $InteractMessage

var target_velocity := Vector3.ZERO
var available_interactions :Array[InteractionCollider] = []
var input_disabled :bool = false : set = _set_input_disabled
var riding_on: Motorbike = null
var interaction_icon_size := Vector2.ZERO
var interaction_icon_tween :Tween = null

func _init() -> void:
	materials.max_weight = 70

func _ready() -> void:
	if Instance == null:
		Instance = self
	
	movement_enabled = true
	
	cheats.cheat_callback = toggle_cheats
	cheats.enabled = true
	


func _process(delta):
	if riding_on != null:
		return
	
	var dir := Vector3()
	
	if movement_enabled and not input_disabled:
		# Check input to get character movement direction
		if Input.is_action_pressed("left"):
			dir.x -= 1.0
		if Input.is_action_pressed("right"):
			dir.x += 1.0
		if Input.is_action_pressed("up"):
			dir.z -= 1.0
		if Input.is_action_pressed("down"):
			dir.z += 1.0
		dir = dir.normalized()

	# Ground Velocity
	var camera_rot := FollowCamera.Instance.get_camera_rotation()
	target_velocity.x = dir.x * speed
	target_velocity.z = dir.z * speed
	target_velocity = target_velocity.rotated(Vector3.UP, camera_rot)

	# Vertical Velocity
	if is_on_floor():
		target_velocity.y = 0
	else:
		# If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)


	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
	anim.play("walking" if velocity.length() > 0.1 else "idle")
	if velocity.length() > 0.1:
		if footsteps_timer.is_stopped():
			footsteps_timer.start()
	else:
		footsteps_timer.stop()
	
	# Rotate to movement direction
	if target_velocity.x != 0 or target_velocity.z != 0:
		var target_rot := Vector3.FORWARD.rotated(Vector3.UP, mesh.rotation.y).signed_angle_to(Vector3(target_velocity.x, 0, target_velocity.z), Vector3.UP)
		target_rot = minf(ROTATION_SPEED * delta, abs(target_rot)) * sign(target_rot)
		mesh.rotate_y(target_rot)


func _set_input_disabled(new_value:bool) -> void:
	input_disabled = new_value
	if cheats != null:
		cheats.enabled = not new_value


func _unhandled_input(input: InputEvent) -> void:
	if input_disabled or riding_on != null:
		return
	
	if input.is_action_pressed("interact"):
		interact()
	

func interact() -> void:
	if available_interactions.is_empty() or available_interactions.back() == null:
		return
	
	input_disabled = true
	hud.set_menu_enabled(false)
	await available_interactions.back().interact()
	
	input_disabled = false
	hud.set_menu_enabled(true)
	

func add_interaction_object(obj:InteractionCollider) -> void:
	available_interactions.append(obj)
	
	if available_interactions.size() <= 1:
		update_interaction_icon_size(Vector2.ONE)

func remove_interaction_object(obj:InteractionCollider) -> void:
	available_interactions.erase(obj)
	
	if available_interactions.is_empty():
		update_interaction_icon_size(Vector2.ZERO)


func update_interaction_icon_size(new_size:Vector2 = interaction_icon_size) -> void:
	interaction_icon_size = new_size
	
	# Update size with camera zoom
	if FollowCamera.Instance:
		new_size *= FollowCamera.Instance.get_zoom()/FollowCamera.MIN_ZOOM
	
	# If a previous tween was being animated, stop it
	if interaction_icon_tween != null and interaction_icon_tween.is_running():
		interaction_icon_tween.kill()
	
	interaction_icon_tween = get_tree().create_tween()
	
	if not interact_message.visible and new_size != Vector2.ZERO:
		interact_message.visible = true
	interaction_icon_tween.tween_property(interact_message.mesh, "size", new_size, 0.2)
	
	if new_size == Vector2.ZERO:
		interaction_icon_tween.tween_property(interact_message, "visible", false, 0.2)


func enable_collision(new_state:bool) -> void:
	set_collision_mask_value(1, new_state)
	set_collision_layer_value(1, new_state)


func toggle_cheats() -> void:
	cheats.action_list = ["speed_cheat"]
	cheats.cheat_callback = func() -> void:
		Engine.time_scale = 2.5 if Engine.time_scale < 2.0 else 1.0
	
	await get_tree().create_timer(3.0).timeout
	cheats.correct_input_audio.volume_db = -60.0
	cheats.message = ""


func play_footstep() -> void:
	footsteps_audio.pitch_scale = randf_range(0.9, 1.3)
	footsteps_audio.play()


func _exit_tree() -> void:
	Instance = null
