class_name Blueprint extends AspectRatioContainer

@onready var name_label := $BlueprintIcon/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/BlueprintNameLabel
@onready var description_label := $BlueprintIcon/MarginContainer/VBoxContainer/BlueprintDescriptionLabel
@onready var build_button := $BlueprintIcon/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/BuildButton
@onready var blueprint_cost_display: BlueprintCostDisplay = $BlueprintIcon/MarginContainer/VBoxContainer/MarginContainer2/VBoxContainer/BlueprintCostDisplay

func set_blueprint_name(text:String) -> void:
	name_label.text = text


func set_blueprint_description(text:String) -> void:
	description_label.text = text


func set_blueprint_cost(cost:Dictionary) -> void:
	blueprint_cost_display.set_cost(cost)
