class_name Blueprint extends AspectRatioContainer

var machine:Machine

@onready var name_label := $BlueprintIcon/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/BlueprintNameLabel
@onready var description_label := $BlueprintIcon/MarginContainer/VBoxContainer/BlueprintDescriptionLabel
@onready var build_button := $BlueprintIcon/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/BuildButton
@onready var blueprint_cost_display: BlueprintCostDisplay = $BlueprintIcon/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/BlueprintCostDisplay

func _ready() -> void:
	blueprint_cost_display.set_cost(Drill.DRILL_BUILD_COST)

func set_machine_name(text:String) -> void:
	name_label.text = text


func set_machine_description(text:String) -> void:
	description_label.text = text


func set_machine(new_machine:Machine) ->void:
	machine = new_machine
	set_machine_name(machine.machine_name)
	set_machine_description(machine.description)
	

func enter_build_mode() -> void:
	var player := Player.Instance
	var hud := player.hud
	
	BUILDMODE.enter_build_mode(machine)
	player.input_disabled = true
	hud.set_menu_visibility(false)
	hud.set_menu_enabled(false)
	
	await BUILDMODE.build_mode_exited
	
	player.input_disabled = false
	hud.show_machines_inventory()
	hud.set_menu_visibility(true)
	hud.set_menu_enabled(true)
	
