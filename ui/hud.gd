class_name Hud extends CanvasLayer

const MATERIAL_ICON := preload("res://ui/material_icon.tscn")

@onready var menu_node := $Menu
@onready var menu_buttons := $Menu/VBoxContainer/MenuButtons
@onready var materials_inv_display := $Menu/VBoxContainer/MenuDisplay/MaterialsInventoryDisplay
@onready var machines_inv_display := $Menu/VBoxContainer/MenuDisplay/MachinesInventoryDisplay
@onready var current_menu_screen :Node = $Menu/VBoxContainer/MenuDisplay/MaterialsInventoryDisplay


func set_menu_visibility(new_state:bool) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(menu_node, "position", Vector2(0, 0 if new_state else 330), 0.5)


func untoggle_buttons(exception:Button) -> void:
	for button in menu_buttons.get_children():
		if button == exception:
			continue
		
		# Removes pressed state without generating events
		button.set_pressed_no_signal(false)


func update_menu_screens_visibility(screen_to_show:Node) -> void:
	current_menu_screen.visible = false
	current_menu_screen = screen_to_show
	current_menu_screen.visible = true


# # #
# Materials inventory
# # #
func show_materials_inventory() -> void:
	untoggle_buttons(menu_buttons.get_child(0))
	update_menu_screens_visibility(materials_inv_display)
	update_materials_inventory()


func update_materials_inventory() -> void:
	if not materials_inv_display.visible:
		return
	
	var materials_container := materials_inv_display.get_child(0)
	var player_materials := Player.Instance.materials
	
	# Remove all children
	for mat in materials_container.get_children():
		mat.queue_free()
	
	# Create an icon foreach material in player's inventory
	for mat_id in player_materials.get_all_keys():
		var new_mat_icon :MaterialIcon = MATERIAL_ICON.instantiate()
		materials_container.add_child(new_mat_icon)
		new_mat_icon.set_sprite(MATERIALS.search_by_id(mat_id).sprite)
		new_mat_icon.set_number(player_materials.get_value_from_id(mat_id))


# # #
# Machines inventory
# # #
func show_machines_inventory() -> void:
	untoggle_buttons(menu_buttons.get_child(1))
	update_menu_screens_visibility(machines_inv_display)
	update_machines_inventory()


func update_machines_inventory() -> void:
	pass


# # #
# Build menu
# # #
func show_build_menu() -> void:
	untoggle_buttons(menu_buttons.get_child(2))


func show_upgrades_menu() -> void:
	untoggle_buttons(menu_buttons.get_child(3))
