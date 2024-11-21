class_name GameLocation extends Node3D

signal location_reached(body:Node3D)

@onready var gl_area: Area3D = $Area3D

func _on_game_location_entered(body: Node3D) -> void:
	location_reached.emit(body)


func get_object() -> Node3D:
	return get_parent()


func is_body_inside(body: Node3D) -> bool:
	return gl_area.overlaps_body(body)
