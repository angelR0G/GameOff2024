class_name ExplorerDroneStation extends DroneStation

const DRONE_SCENE := preload("res://machines/drone.tscn")

var explored_mines_count :int = 0
var max_explorable_mines :int = 3
var nearby_mines :Array[Mine]


func _init() -> void:
	super()
	
	# Explorer drone station parameters
	_type = Machine.Type.ExplorerDroneStation
	machine_name = "Explorer Drone Station"
	description = "Place a drone that explore nearby mines automatically."
	energy_cost = 0
	active = false
	
	radius = 50.0


func _ready() -> void:
	create_drone(DRONE_SCENE)
	(drone as ExplorerDrone).drone_explored_mine.connect(increase_explored_mines_count)
	
	await save_mines_in_radius()


func save_mines_in_radius() -> void:
	var is_an_explorable_mine := func (object) -> bool: 
		return object is Mine #and
	
	var mines :Array[Mine] = (await BUILDMODE.get_bodies_in_area(global_position, radius)).filter(is_an_explorable_mine)


func get_new_drone_target() -> GameLocation:
	return null


func update_drone_target() -> void:
	pass


func can_continue_exploring_mines() -> bool:
	return explored_mines_count < max_explorable_mines


func increase_explored_mines_count() -> void:
	explored_mines_count += 1


func display_interactions() -> void:
	super()
	
	InteractionsDisplay.Instance.add_interaction("Remove Explorer Drone", destroy_station)
