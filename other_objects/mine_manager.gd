class_name MineManager extends Node

const DEFAULT_MAT_ID := 1

@export var _mines_by_area :Array[Array] = []
@export var _materials_by_area : Array[Dictionary] = []

func _ready() -> void:
	update_mines_materials()

func update_mines_materials() -> void:
	var area_count := mini(_mines_by_area.size(), _materials_by_area.size())
	var mines_by_area := _mines_by_area.duplicate(true)
	var materials_by_area := _materials_by_area.duplicate(true)
	var next_mine :Mine = null
	
	for area_index in area_count:
		while not mines_by_area[area_index].is_empty():
			next_mine = get_node(mines_by_area[area_index].pop_back())
			next_mine.material_id = get_random_material(materials_by_area[area_index])
		


func get_random_material(materials:Dictionary) -> int:
	if materials.is_empty():
		return DEFAULT_MAT_ID
	
	var ids := materials.keys()
	var random_id :int = ids.pick_random()
	
	if materials[random_id] > 1:
		materials[random_id] = materials[random_id] - 1
	else:
		materials.erase(random_id)
	
	return random_id
