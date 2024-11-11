class_name DroneStation extends Machine

var speed:float = 1.0
var radius:float = 30.0
var drone:Drone = null

@onready var station_gl :GameLocation = $GameLocation

func _init() -> void:
	can_be_placed_on_world = true


func destroy_station() -> void:
	if drone != null:
		drone.queue_free()
	queue_free()
