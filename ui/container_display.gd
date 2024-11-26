class_name ContainerDisplay extends PanelContainer

const MATERIAL_ICON = preload("res://ui/material_icon.tscn")

var container :MaterialContainer = null
var selected_icon :MaterialIcon = null

@onready var mat_icons_container :GridContainer = $VBoxContainer/CenterContainer/GridContainer
@onready var weight_label: Label = $VBoxContainer/HBoxContainer/WeightLabel

signal material_selected(id:int)

func set_container_reference(cont:MaterialContainer) -> void:
	container = cont
	update_display()


func update_display() -> void:
	if container == null:
		return
	
	var selected_icon_id :int = selected_icon.id if selected_icon != null else -1
	selected_icon = null
	for child:Node in mat_icons_container.get_children():
		child.free()
	
	for material_id:int in container.get_all_keys():
		var new_icon := MATERIAL_ICON.instantiate()
		mat_icons_container.add_child(new_icon)
		
		new_icon.id = material_id
		new_icon.set_sprite(MATERIALS.search_by_id(material_id).sprite)
		new_icon.set_number(container.get_material_quantity_from_id(material_id))
		new_icon.gui_input.connect(_on_icon_clicked.bind(new_icon, material_id))
		if new_icon.id == selected_icon_id:
			update_highlighted_icon(new_icon)
	
	weight_label.text = str(container.current_weight) + "/" + str(container.max_weight)
	weight_label.add_theme_color_override("font_color", Color.BLACK if container.current_weight < container.max_weight * 0.8 else Color.RED)


func _on_icon_clicked(event:InputEvent, icon:MaterialIcon, material_id:int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		update_highlighted_icon(icon)
		material_selected.emit(material_id)


func update_highlighted_icon(new_highlighted_icon:MaterialIcon) -> void:
	if selected_icon != null:
		selected_icon.set_highlighted(false)
		
	selected_icon = new_highlighted_icon
	
	if selected_icon != null:
		selected_icon.set_highlighted(true)
