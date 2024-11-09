class_name MachineInventoryIcon extends AspectRatioContainer

@onready var name_label := $Background/MarginContainer/VBoxContainer/MarginContainer/MachineNameLabel
@onready var description_label := $Background/MarginContainer/VBoxContainer/MachineDescriptionLabel
@onready var place_button := $Background/MarginContainer/VBoxContainer/MarginContainer2/PlaceButton
@onready var place_label := $Background/MarginContainer/VBoxContainer/MarginContainer2/PlaceInstructions

func set_machine_name(text:String) -> void:
	name_label.text = text


func set_machine_description(text:String) -> void:
	description_label.text = text


func set_machine_placeable(is_placeable:bool, place_instructions:String = "") -> void:
	place_button.visible = is_placeable
	place_label.visible = not is_placeable
	
	if not is_placeable:
		place_label.text = place_instructions
