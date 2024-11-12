class_name DroneStation extends Machine

var speed:float = 1.0
var radius:float = 30.0
var drone:Drone = null
var is_drone_in_station:bool = true

@onready var station_gl :GameLocation = $GameLocation

func _init() -> void:
	can_be_placed_on_world = true


func create_drone(scene:PackedScene) -> void:
	drone = scene.instantiate()
	add_child(drone)
	
	drone.station = self
	drone.drone_arrived_to_station.connect(set_drone_in_station)


func destroy_station() -> void:
	if drone != null:
		drone.queue_free()
	queue_free()


func set_drone_in_station() -> void:
	is_drone_in_station = true
	
	if is_working():
		update_drone_target()


func update_drone_target() -> void:
	pass

func _on_start_working() -> void:
	if is_drone_in_station:
		update_drone_target()

func _on_stop_working() -> void:
	drone.return_to_station()
