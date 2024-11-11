class_name Drone extends CharacterBody3D

var speed:float = 1.0
var station:DroneStation = null
var moving_to_target:bool = false

@onready var nav_agent :NavigationAgent3D = $NavigationAgent3D
@onready var gl_target :GameLocationAgent = $GameLocationAgent


func _ready() -> void:
	gl_target.game_location_reached.connect(on_target_enter)


func update_target() -> void:
	pass


func return_to_station() -> void:
	set_target(station.station_gl)


func on_target_enter() -> void:
	pass


func set_target(new_target:GameLocation) -> void:
	if new_target == null:
		return
	
	gl_target.set_target(new_target)
	nav_agent.target_position = gl_target.get_target_position()


func _physics_process(_delta: float) -> void:
	if moving_to_target:
		move_to_target()


func move_to_target() -> void:
	var movement_direction := (get_next_pathfinding_location() - global_position).normalized()
	
	velocity = movement_direction * speed
	
	move_and_slide()
	

func get_next_pathfinding_location() -> Vector3:
	if nav_agent.is_navigation_finished():
		return global_position
	
	return nav_agent.get_next_path_position()
