class_name TransportDroneStation extends DroneStation

const DRONE_SCENE := preload("res://machines/transport_drone.tscn")

static var drone_max_weight :int = 1000

var nearby_stations :Array[CollectorDroneStation]
var last_station_index :int = -1

@onready var update_timer: Timer = $UpdateWaitTimer

func _init() -> void:
	super()
	
	# Transport drone station parameters
	_type = Machine.Type.TransportDroneStation
	machine_name = "Transport Drone"
	description = "Collects the materials stored by collector drones and takes them to the base."
	energy_cost = 2
	
	radius = 50.0


func _ready() -> void:
	interaction.interaction_function = display_interactions
	
	create_drone(DRONE_SCENE)
	(drone as TransportDrone).materials.max_weight = drone_max_weight
	
	await save_stations_in_radius()
	active = true


func save_stations_in_radius() -> void:
	var is_a_valid_station := func (object:Node3D) -> bool: 
		return object is CollectorDroneStation
	
	nearby_stations.assign((await BUILDMODE.get_bodies_in_area(global_position, radius)).filter(is_a_valid_station))
	for station:CollectorDroneStation in nearby_stations:
		station.tree_exiting.connect(remove_nearby_station.bind(station))


func remove_nearby_station(station:CollectorDroneStation) -> void:
	var index := nearby_stations.find(station)
	if index == -1:
		return
	
	# If it is drone's current target, return to station
	if index == last_station_index:
		if not is_drone_in_station:
			drone.return_to_station()
	
	last_station_index = -1
	nearby_stations.remove_at(index)


func get_new_drone_target_location() -> GameLocation:
	var station_index := last_station_index + 1
	
	# Go to the next station
	while station_index < nearby_stations.size():
		if can_drone_collect_materials_from_station(nearby_stations[station_index]):
			break
		
		station_index += 1
	
	# If all stations have been collected, go to base
	if station_index >= nearby_stations.size():
		last_station_index = -1
		return BaseCamp.Instance.game_location
	
	last_station_index = station_index
	return nearby_stations[station_index].station_gl


func can_drone_collect_materials_from_station(station:CollectorDroneStation) -> bool:
	return station != null and station.stored_materials.current_weight > 0


func update_drone_target() -> void:
	update_timer.stop()
	
	if station_being_destroyed:
		destroy_station()
	else:
		var drone_new_target :GameLocation = get_new_drone_target_location()
		if drone_new_target == BaseCamp.Instance.game_location and (drone as TransportDrone).materials.current_weight == 0:
			drone_new_target = null
		
		if drone_new_target != null:
			drone.set_target(drone_new_target)
			drone.moving_to_target = true
			is_drone_in_station = false
		else:
			update_timer.start()


func display_interactions() -> void:
	if station_being_destroyed:
		return
	
	super()
	
	var interactions_ui := InteractionsDisplay.Instance
	interactions_ui.add_interaction("Remove Collector Drone", func()->void:
		station_being_destroyed = true
		if is_drone_in_station:
			destroy_station()
		else:
			drone.return_to_station())
	
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed


func _on_stop_working() -> void:
	super()
	
	update_timer.stop()
