class_name MaterialContainer extends Node


@export var max_weight :int
@export var objects :Dictionary = {}
var current_weight :int

func add_material(id:int, quantity:int) -> int:
	var material := MATERIALS.search_by_id(id)
	
	if material==null:
		return 0
		
	var weight_left := max_weight - current_weight
	var quantity_to_add := quantity
	
	if  max_weight != -1:
		@warning_ignore("integer_division")
		quantity_to_add = mini(weight_left / material.weight, quantity)
		
	if objects.has(id):
		objects[id] = objects.get(id)+quantity_to_add
	else:
		objects[id] = quantity_to_add
		
	current_weight += material.weight*quantity_to_add
	return quantity_to_add
	

func remove_material(id:int, quantity:int) -> bool:
	var material := MATERIALS.search_by_id(id)
	if material:
		if objects.has(id):
			current_weight -= material.weight*mini(quantity, objects.get(id))
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
