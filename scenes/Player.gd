class_name Player extends CharacterBody3D


const material_container := preload("res://materials/material_container.gd")
@export var speed :float = 14.0
@export var fall_acceleration = 75
@export var movement_enabled :bool
@export var machines : Dictionary = {}
@export var materials :MaterialContainer = MaterialContainer.new()

@onready var camera 		= $Camera3D

var target_velocity = Vector3.ZERO

func _process(delta):
	var dir := Vector3()
	
	if !movement_enabled:
		# Check input to get character movement direction
		if Input.is_action_pressed("left"):
			dir.x -= 1.0
		if Input.is_action_pressed("right"):
			dir.x += 1.0
		if Input.is_action_pressed("up"):
			dir.z -= 1.0
		if Input.is_action_pressed("down"):
			dir.z += 1.0

	# Ground Velocity
	target_velocity.x = dir.x * speed
	target_velocity.z = dir.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()

	
func interact() -> void:
	pass
