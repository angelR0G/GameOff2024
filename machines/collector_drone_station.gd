class_name CollectorDroneStation extends DroneStation

const DRONE_SCENE := preload("res://machines/collector_drone.tscn")

static var storage_max_weight :int = 1000
static var drone_max_weight :int = 160

var nearby_mines :Array[Mine]
var last_mine_collected :Mine = null
var stored_materials : MaterialContainer = MaterialContainer.new()

@onready var update_timer: Timer = $UpdateWaitTimer

func _init() -> void:
	super()
	
	# Explorer drone station parameters
	_type = Machine.Type.CollectorDroneStation
	machine_name = "Collector Drone Station"
	description = "Place a drone that collect materials from nearby mines and stores them."
	energy_cost = 1
	
	radius = 50.0


func _ready() -> void:
	interaction.interaction_function = display_interactions
	stored_materials.max_weight = storage_max_weight
	
	create_drone(DRONE_SCENE)
	(drone as CollectorDrone).materials.max_weight = drone_max_weight
	
	await save_mines_in_radius()
	active = true


func save_mines_in_radius() -> void:
	var is_a_mine := func (object:Node3D) -> bool: 
		return object is Mine
	
	nearby_mines.assign((await BUILDMODE.get_bodies_in_area(global_position, radius)).filter(is_a_mine))


func get_new_drone_target_location() -> GameLocation:
	var target_mine :Mine = null
	var max_material_amount :int = -1
	
	# Search the drill with more materials stored
	for mine:Mine in nearby_mines:
		if mine == last_mine_collected or not can_drone_collect_materials_from_mine(mine):
			continue
		
		var mat_amount := (mine.installed_machine as Drill).material_amount
		if mat_amount > max_material_amount:
			target_mine = mine
			max_material_amount = mat_amount
	
	# Check the last mine collected after all the others to repeat it only if others are not collectable
	if target_mine == null:
		target_mine = last_mine_collected
	
	if target_mine == null:
		return null
	
	return target_mine.game_location


func can_drone_collect_materials_from_mine(mine:Mine) -> bool:
	if mine == null or not mine.has_a_drill() or (mine.installed_machine as Drill).material_amount <= 0:
		return false
	
	var material_weight :int = MATERIALS.search_by_id(mine.material_id).weight
	return drone.materials.remaining_weight() >= material_weight and stored_materials.remaining_weight() >= material_weight


func update_drone_target() -> void:
	update_timer.stop()
	
	if station_being_destroyed:
		destroy_station()
	else:
		var drone_new_target :GameLocation = get_new_drone_target_location()
		if drone_new_target == null:
			update_timer.start()
		else:
			drone.set_target(drone_new_target)
			drone.moving_to_target = true
			is_drone_in_station = false


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
	interactions_ui.add_interaction("Open Storage", func()-> void:
		# TODO: Abrir menu de inventario
		pass)
	
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed


func _on_stop_working() -> void:
	super()
	
	update_timer.stop()
