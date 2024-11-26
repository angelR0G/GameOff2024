class_name DroneStation extends Machine

var speed:float = 1.0
var radius:float = 30.0
var drone:Drone = null
var is_drone_in_station:bool = true
var station_being_destroyed:bool = false

@onready var station_gl :GameLocation = $GameLocation
@onready var interaction: InteractionCollider = $InteractionTrigger

func _init() -> void:
	can_be_placed_on_world = true


func create_drone(scene:PackedScene) -> void:
	drone = scene.instantiate()
	add_child(drone)
	drone.position -= Vector3.LEFT * -2
	
	drone.station = self
	drone.drone_arrived_to_station.connect(set_drone_in_station)


func destroy_station() -> void:
	powered = false
	queue_free()


func set_drone_in_station() -> void:
	is_drone_in_station = true
	
	if is_working():
		update_drone_target()


func update_drone_target() -> void:
	pass

func _on_start_working() -> void:
	if not is_node_ready():
		await ready
	super()
	
	if is_drone_in_station:
		update_drone_target()

func _on_stop_working() -> void:
	if is_queued_for_deletion():
		return
	if not is_node_ready():
		await ready
	super()
	
	drone.return_to_station()
