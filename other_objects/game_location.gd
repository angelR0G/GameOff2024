class_name GameLocation extends Node3D

signal location_reached(body:Node3D)

func _on_game_location_entered(body: Node3D) -> void:
	location_reached.emit(body)


func get_object() -> Node3D:
	return get_parent()
