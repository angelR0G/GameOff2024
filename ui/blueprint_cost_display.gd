class_name BlueprintCostDisplay extends HBoxContainer

const COST_ICON_SCENE := preload("res://ui/blueprint_cost_icon.tscn")
var _cost :Dictionary = {}

func set_cost(materials:Dictionary) -> void:
	for child in get_children():
		child.queue_free()
	
	for material_id:int in materials.keys():
		var required_amount :int = materials[material_id]
		var player_amount :int = 0
		var new_icon := COST_ICON_SCENE.instantiate()
		
		if BaseCamp.Instance:
			player_amount = BaseCamp.Instance.materials.get_material_quantity_from_id(material_id)
		
		new_icon.get_child(0).texture = MATERIALS.search_by_id(material_id).sprite
		
		new_icon.get_child(1).text = str(player_amount) + "/" + str(required_amount)
		new_icon.get_child(1).add_theme_color_override("font_color", Color.BLACK if player_amount >= required_amount else Color.RED)
		
		add_child(new_icon)
	
	_cost = materials


func has_player_enough_materials() -> bool:
	if BaseCamp.Instance == null or _cost.is_empty():
		return false
	
	var player_materials := BaseCamp.Instance.materials
	for material_id in _cost:
		if player_materials.get_material_quantity_from_id(material_id) < _cost[material_id]:
			return false
		
	return true


func remove_cost_from_player() -> void:
	if BaseCamp.Instance == null:
		return
	
	var player_materials := BaseCamp.Instance.materials
	for material_id in _cost:
		player_materials.remove_material(material_id, _cost[material_id])
	

func are_all_materials_discovered() -> bool:
	for mat_id in _cost:
		if not MATERIALS.search_by_id(mat_id).discovered:
			return false
	return true
