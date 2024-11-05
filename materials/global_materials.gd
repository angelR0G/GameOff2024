extends Node

var all_materials :Dictionary = {}

func _ready() -> void:
	if all_materials.is_empty():
		for child:GMaterial in get_children():
			all_materials[child.material_id] = child


func search_by_id(id:int) -> GMaterial:
	return all_materials.get(id)
