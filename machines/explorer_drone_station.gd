class_name ExplorerDroneStation extends DroneStation

const drone_scene := preload("res://machines/drone.tscn")

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
	
