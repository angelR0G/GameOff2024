class_name ExplorerDroneStation extends DroneStation

const DRONE_SCENE := preload("res://machines/explorer_drone.tscn")

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
	
	radius = 50.0


func _ready() -> void:
	interaction.interaction_function = display_interactions
	
	create_drone(DRONE_SCENE)
	(drone as ExplorerDrone).drone_explored_mine.connect(increase_explored_mines_count)
	
	await save_mines_in_radius()
	active = true


func save_mines_in_radius() -> void:
	var is_an_explorable_mine := func (object:Node3D) -> bool: 
		return object is Mine and not (object as Mine).explored
	var is_further := func(mine1:Mine, mine2:Mine) -> bool:
		return global_position.distance_squared_to(mine1.global_position) > global_position.distance_squared_to(mine2.global_position)
	
	nearby_mines.assign((await BUILDMODE.get_bodies_in_area(global_position, radius)).filter(is_an_explorable_mine))
	nearby_mines.sort_custom(is_further)


func get_new_drone_target_location() -> GameLocation:
	if nearby_mines.is_empty():
		return null
	
	return nearby_mines.back().game_location


func update_drone_target() -> void:
	if can_continue_exploring_mines():
		drone.set_target(get_new_drone_target_location())
		drone.moving_to_target = true
		is_drone_in_station = false
	else:
		destroy_station()


func can_continue_exploring_mines() -> bool:
	# Check if has explored the max amount of mines
	if explored_mines_count >= max_explorable_mines:
		return false
	
	while not nearby_mines.is_empty():
		if not nearby_mines.back().explored:
			# There is a not explored mine close
			return true
		nearby_mines.pop_back()
	
	# There is not any not explored mine close
	return false


func increase_explored_mines_count() -> void:
	explored_mines_count += 1


func display_interactions() -> void:
	if station_being_destroyed:
		return
	
	super()
	
	var interactions_ui := InteractionsDisplay.Instance
	interactions_ui.add_interaction("Remove Explorer Drone", func()->void:
		explored_mines_count = max_explorable_mines
		station_being_destroyed = true
		if is_drone_in_station:
			destroy_station()
		else:
			drone.return_to_station())
	
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed
