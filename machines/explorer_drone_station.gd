class_name ExplorerDroneStation extends DroneStation

const drone_scene := preload("res://machines/drone.tscn")

var explored_mines_count :int = 0
var max_explorable_mines :int = 3

func _init() -> void:
	super()
	
	# Explorer drone station parameters
	_type = Machine.Type.ExplorerDroneStation
	machine_name = "Explorer Drone Station"
	description = "Place a drone that explore nearby mines automatically."
	energy_cost = 0
	active = false


func _ready() -> void:
	drone = drone_scene.instantiate()
	add_child(drone)
	


func get_new_drone_target() -> GameLocation:
	return null


func destroy_station() -> void:
	pass
