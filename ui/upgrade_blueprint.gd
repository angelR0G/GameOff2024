class_name UpgradeBlueprint extends Blueprint

const LOCKED_PANEL := preload("res://resources/black_square.tres")
const UNLOCKED_PANEL := preload("res://resources/light_square.tres")
const LEVEL_PANEL_SIZE := 10.0

signal upgrade_created

var current_level :int = 0
@export var upgrade_function :Callable
@export var upgrade_name :String = ""
@export var upgrade_description :String = ""
@export var upgrade_cost :Array[Dictionary] = []

@onready var upgrade_levels_container := $BlueprintIcon/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/UpgradeLevelsContainer

func _ready() -> void:
	update_blueprint_info()


func update_blueprint_info() -> void:
	set_blueprint_name(upgrade_name)
	set_blueprint_description(upgrade_description)
	set_upgrade_levels()
	update_button_state()


func buy_upgrade() -> void:
	if not blueprint_cost_display.has_player_enough_materials():
		return
	
	current_level += 1
	
	blueprint_cost_display.remove_cost_from_player()
	upgrade_created.emit()


func set_upgrade_levels() -> void:
	for child:Node in upgrade_levels_container.get_children():
		child.queue_free()
	
	var max_level := upgrade_cost.size()
	for level in max_level:
		var new_level_panel := Panel.new()
		new_level_panel.custom_minimum_size = Vector2(LEVEL_PANEL_SIZE, LEVEL_PANEL_SIZE)
		new_level_panel.add_theme_stylebox_override("panel", UNLOCKED_PANEL if level < current_level else LOCKED_PANEL)
		upgrade_levels_container.add_child(new_level_panel)
	
	# Update level cost
	blueprint_cost_display.visible = not has_reached_max_level()
	if not has_reached_max_level():
		set_blueprint_cost(upgrade_cost[current_level])


func update_button_state() -> void:
	# Disable button when max level reached
	build_button.disabled = has_reached_max_level() or not blueprint_cost_display.has_player_enough_materials()
	build_button.text = "Max Level" if has_reached_max_level() else "Upgrade"


func has_reached_max_level() -> bool:
	return current_level >= upgrade_cost.size()


# # # # # # 
# Upgrade functions
# # # # # #
static func upgrade_player() -> void:
	Player.Instance.speed += 10.0
	Player.Instance.materials.max_weight += 20
