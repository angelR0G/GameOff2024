class_name MaterialContainer extends Node

signal materials_transfered

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
		if quantity_to_add <= 0:
			return 0
		
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

func get_material_quantity_from_id(id:int) -> int:
	return objects.get(id, 0)

func transfer_materials(materials_origin: MaterialContainer) -> void:
	if materials_origin == null:
		return
	
	for material_id in materials_origin.get_all_keys():
		var material_quantity :int = materials_origin.get_material_quantity_from_id(material_id)
		var transfered_quantity := add_material(material_id, material_quantity)
		materials_origin.remove_material(material_id, transfered_quantity)
	
	materials_transfered.emit()


func clear() -> void:
	objects.clear()


func remaining_weight() -> int:
	return max_weight - current_weight
