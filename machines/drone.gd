class_name Drone extends CharacterBody3D

@warning_ignore("unused_signal")
signal drone_arrived_to_station

var speed:float = 2.0 : set = set_speed
var station:DroneStation = null
var moving_to_target:bool = false

@onready var nav_agent :NavigationAgent3D = $NavigationAgent3D
@onready var gl_target :GameLocationAgent = $GameLocationAgent

func _ready() -> void:
	gl_target.game_location_reached.connect(on_target_enter)
	nav_agent.max_speed = speed


func set_speed(new_speed:float) -> void:
	speed = new_speed
	if nav_agent != null:
		nav_agent.max_speed = speed


func return_to_station() -> void:
	set_target(station.station_gl)


func on_target_enter() -> void:
	pass


func set_target(new_target:GameLocation) -> void:
	if new_target == null or not new_target.is_inside_tree():
		return
	
	gl_target.set_target(new_target)
	nav_agent.target_position = gl_target.get_target_position()


func _physics_process(_delta: float) -> void:
	if moving_to_target:
		_move_to_target()


func _move_to_target() -> void:
	var target_position := get_next_pathfinding_location()
	var movement_direction := (target_position - global_position).normalized()
	if movement_direction != Vector3.ZERO:
		look_at(target_position)
	nav_agent.velocity = movement_direction * speed
	velocity = nav_agent.velocity
	
	move_and_slide()

func get_next_pathfinding_location() -> Vector3:
	if nav_agent.is_navigation_finished():
		return global_position
	
	return nav_agent.get_next_path_position()


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if moving_to_target:
		velocity = safe_velocity
		move_and_slide()
