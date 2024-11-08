class_name Hud extends CanvasLayer

@onready var menu_node := $Menu
@onready var menu_buttons := $Menu/VBoxContainer/MenuButtons

func set_menu_visibility(new_state:bool) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(menu_node, "position", Vector2(0, 0 if new_state else 330), 0.5)

func untoggle_buttons(exception:Button) -> void:
	for button in menu_buttons.get_children():
		if button == exception:
			continue
		
		# Removes pressed state without generating events
		button.set_pressed_no_signal(false)

func show_materials_inventory() -> void:
	untoggle_buttons(menu_buttons.get_child(0))


func show_machines_inventory() -> void:
	untoggle_buttons(menu_buttons.get_child(1))


func show_build_menu() -> void:
	untoggle_buttons(menu_buttons.get_child(2))


func show_upgrades_menu() -> void:
	untoggle_buttons(menu_buttons.get_child(3))
