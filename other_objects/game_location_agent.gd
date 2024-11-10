class_name GameLocationAgent extends Node3D

var target:GameLocation = null

signal game_location_reached

func set_target(gl:GameLocation) -> void:
	remove_target()
	target = gl
	target.location_reached.connect(_check_location_reached)


func get_target_position() -> Vector3:
	if target == null:
		return global_position
	
	return target.global_position


func remove_target() -> void:
	if target == null:
		return
	
	target.location_reached.disconnect(_check_location_reached)
	target = null


func _check_location_reached(body:Node3D) -> void:
	if body == get_parent():
		game_location_reached.emit()
