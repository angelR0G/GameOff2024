class_name MachineInventoryIcon extends AspectRatioContainer

@onready var name_label := $MachineIcon/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/MachineNameLabel
@onready var amount_label := $MachineIcon/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/AmountLabel
@onready var description_label := $MachineIcon/MarginContainer/VBoxContainer/MachineDescriptionLabel
@onready var place_button := $MachineIcon/MarginContainer/VBoxContainer/MarginContainer2/PlaceButton
@onready var place_label := $MachineIcon/MarginContainer/VBoxContainer/MarginContainer2/PlaceInstructions

func set_machine_name(text:String) -> void:
	name_label.text = text


func set_machine_description(text:String) -> void:
	description_label.text = text


func set_machine_placeable(is_placeable:bool, place_instructions:String = "") -> void:
	place_button.visible = is_placeable
	place_label.visible = not is_placeable
	
	if not is_placeable:
		place_label.text = place_instructions


func set_machine_amount(amount:int) -> void:
	amount_label.text = "" if amount <= 1 else "x" + str(amount)
