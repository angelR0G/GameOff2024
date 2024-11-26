class_name MachineInventoryIcon extends AspectRatioContainer

const PLACE_MACHINE_SOUND = preload("res://assets/sounds/place_machine.mp3")
const UI_BACK_SOUND = preload("res://assets/sounds/ui_back.mp3")

var machine:Machine

@onready var name_label := $MachineIcon/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/MachineNameLabel
@onready var amount_label := $MachineIcon/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/AmountLabel
@onready var description_label := $MachineIcon/MarginContainer/VBoxContainer/MachineDescriptionLabel
@onready var place_button := $MachineIcon/MarginContainer/VBoxContainer/MarginContainer2/PlaceButton
@onready var place_label := $MachineIcon/MarginContainer/VBoxContainer/MarginContainer2/PlaceInstructions

func set_machine_name(text:String) -> void:
	name_label.text = text
	name_label.add_theme_font_size_override("font_size", 18 if text.length() <= 10 else 14)


func set_machine_description(text:String) -> void:
	description_label.text = text


func set_machine_placeable(is_placeable:bool, place_instructions:String = "") -> void:
	place_button.visible = is_placeable
	place_label.visible = not is_placeable
	
	if not is_placeable:
		place_label.text = place_instructions


func set_machine_amount(amount:int) -> void:
	amount_label.text = "" if amount <= 1 else "x" + str(amount)

func set_machine(new_machine:Machine) ->void:
	machine = new_machine
	set_machine_name(machine.machine_name)
	set_machine_description(machine.description)
	set_machine_placeable(machine.can_be_placed_on_world, machine.place_instructions)
	

func enter_build_mode() -> void:
	var player := Player.Instance
	var hud := player.hud
	
	BUILDMODE.enter_build_mode(machine)
	player.input_disabled = true
	hud.set_menu_visibility(false)
	hud.set_menu_enabled(false)
	
	var machine_placed :bool = await BUILDMODE.build_mode_exited
	
	player.input_disabled = false
	hud.set_menu_visibility(true, PLACE_MACHINE_SOUND if machine_placed else UI_BACK_SOUND)
	hud.show_machines_inventory()
	hud.set_menu_enabled(true)
	
