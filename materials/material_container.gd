class_name MaterialContainer extends Node


@export var max_weight :int
@export var objects :Dictionary = {}


func add_material(id:int) -> bool:
	if MATERIALS.search_by_id(id):
		if objects.has(id):
			objects[id] = objects.get(id)+1
		else:
			objects[id] = 1
		return true
	return false

func remove_material(id:int) -> bool:
	if MATERIALS.search_by_id(id):
		if objects.has(id):
			objects[id] = objects.get(id)-1
			var material_value = objects.get(id)
			if material_value <= 0:
				objects.erase(id)
			return true
	return false
	
func clear() -> void:
	objects.clear()
