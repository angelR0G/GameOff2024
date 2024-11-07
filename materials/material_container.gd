class_name MaterialContainer extends Node


@export var max_weight :int
@export var objects :Dictionary = {}


func add_material(id:int, quantity:int) -> bool:
	if MATERIALS.search_by_id(id):
		if objects.has(id):
			objects[id] = objects.get(id)+quantity
		else:
			objects[id] = quantity
		return true
	return false

func remove_material(id:int, quantity:int) -> bool:
	if MATERIALS.search_by_id(id):
		if objects.has(id):
			objects[id] = objects.get(id)-quantity
			var material_value:int = objects.get(id)
			if material_value <= 0:
				objects.erase(id)
			return true
	return false

func get_all_keys() ->Array:
	return objects.keys()

func get_value_from_id(id:int) -> int:
	return objects.get(id)

func transfer_materials(materialsOrigin: MaterialContainer) -> void:
	for key in materialsOrigin.get_all_keys():
		var value :int = materialsOrigin.get_value_from_id(key)
		add_material(key, value)
	materialsOrigin.clear()
func clear() -> void:
	objects.clear()
