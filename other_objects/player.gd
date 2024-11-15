class_name Player extends CharacterBody3D

static var Instance :Player = null
const _material_container := preload("res://materials/material_container.gd")

@export var speed :float = 14.0
@export var fall_acceleration = 75
@export var movement_enabled :bool
var machines :MachineContainer = MachineContainer.new()
var materials :MaterialContainer = MaterialContainer.new()

@onready var camera 		:= $Camera3D
@onready var hud :Hud = $Hud
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var mesh: MeshInstance3D = $MeshInstance3D


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
	target_velocity.x = dir.x * speed
	target_velocity.z = dir.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
	anim.play("walking" if velocity.length() > 0.1 else "idle")
	if dir.x != 0 or dir.z != 0:
		mesh.look_at(position + Vector3(dir.x, 0, dir.z))


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
	available_interactions[0].interact()
	
	await available_interactions[0].on_stop_interaction
	input_disabled = false
	hud.set_menu_enabled(true)
	

func add_interaction_object(obj:InteractionCollider) -> void:
	available_interactions.append(obj)

func remove_interaction_object(obj:InteractionCollider) -> void:
	available_interactions.erase(obj)
