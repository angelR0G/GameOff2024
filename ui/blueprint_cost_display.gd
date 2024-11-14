class_name BlueprintCostDisplay extends HBoxContainer

const COST_ICON_SCENE := preload("res://ui/blueprint_cost_icon.tscn")

func set_cost(materials:Dictionary) -> void:
	for child in get_children():
		child.queue_free()
	
	for material_id:int in materials.keys():
		var required_amount :int = materials[material_id]
		var player_amount :int = 0
		var new_icon := COST_ICON_SCENE.instantiate()
		
		if Player.Instance:
			player_amount = Player.Instance.materials.get_material_quantity_from_id(material_id)
		
		new_icon.get_child(0).texture = MATERIALS.search_by_id(material_id).sprite
		
		new_icon.get_child(1).text = str(player_amount) + "/" + str(required_amount)
		new_icon.get_child(1).add_theme_color_override("font_color", Color.BLACK if player_amount >= required_amount else Color.RED)
		
		add_child(new_icon)
