class_name Player extends CharacterBody3D

static var Instance :Player = null
const _material_container := preload("res://materials/material_container.gd")
const ROTATION_SPEED := 4.0

@export var speed :float = 14.0
@export var fall_acceleration = 75
@export var movement_enabled :bool
var machines :MachineContainer = MachineContainer.new()
var materials :MaterialContainer = MaterialContainer.new()

@onready var camera :Camera3D = $CameraPivot/Camera3D
@onready var hud :Hud = $Hud
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var container_manager: ContainerManagerUI = $ContainerManager


var target_velocity := Vector3.ZERO
var available_interactions :Array[InteractionCollider] = []
var input_disabled :bool = false

func _init() -> void:
	materials.max_weight = 80

func _ready() -> void:
	movement_enabled = true
	if Instance == null:
		Instance = self
	
	machines.add_machine_by_type(Machine.Type.Drill)
	machines.add_machine_by_type(Machine.Type.Drill)
	machines.add_machine_by_type(Machine.Type.Drill)
	machines.add_machine_by_type(Machine.Type.Generator)
	machines.add_machine_by_type(Machine.Type.CollectorDroneStation)
	machines.add_machine_by_type(Machine.Type.EnergyStation)
	machines.add_machine_by_type(Machine.Type.EnergyStation)
	machines.add_machine_by_type(Machine.Type.EnergyStation)
	machines.add_machine_by_type(Machine.Type.EnergyExtender)
	machines.add_machine_by_type(Machine.Type.EnergyExtender)
	machines.add_machine_by_type(Machine.Type.EnergyExtender)

func _process(delta):
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
	var camera_rot := camera.get_parent_node_3d().rotation.y
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
	if target_velocity.x != 0 or target_velocity.z != 0:
		var target_rot := Vector3.FORWARD.rotated(Vector3.UP, mesh.rotation.y).signed_angle_to(Vector3(target_velocity.x, 0, target_velocity.z), Vector3.UP)
		target_rot = minf(ROTATION_SPEED * delta, abs(target_rot)) * sign(target_rot)
		mesh.rotate_y(target_rot)


func _unhandled_input(input: InputEvent) -> void:
	if input_disabled:
		return
	
	if input.is_action_pressed("interact"):
		interact()
	

func interact() -> void:
	if available_interactions.is_empty() or available_interactions[0] == null:
		return
	
	input_disabled = true
	hud.set_menu_enabled(false)
	await available_interactions[0].interact()
	
	input_disabled = false
	hud.set_menu_enabled(true)
	

func add_interaction_object(obj:InteractionCollider) -> void:
	available_interactions.append(obj)

func remove_interaction_object(obj:InteractionCollider) -> void:
	available_interactions.erase(obj)
