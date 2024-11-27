class_name Hud extends CanvasLayer

const MATERIAL_ICON := preload("res://ui/material_icon.tscn")
const HUD_MAT_ICON := preload("res://ui/hud_material_icon.tscn")
const MACHINE_INV_ICON := preload("res://ui/machine_inventory_icon.tscn")
const MACHINE_BUILD_ICON := preload("res://ui/machine_blueprint.tscn")
const UI_MENU_SOUND = preload("res://assets/sounds/ui_accept.mp3")

var menu_opened:bool = false

@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var menu_node := $Menu
@onready var menu_buttons := $Menu/VBoxContainer/MenuButtons
@onready var current_menu_screen :Node = $Menu/VBoxContainer/MenuDisplay/MaterialsInventoryDisplay

@onready var materials_inv_display := $Menu/VBoxContainer/MenuDisplay/MaterialsInventoryDisplay
@onready var materials_containers := $Menu/VBoxContainer/MenuDisplay/MaterialsInventoryDisplay/VBoxContainer/MaterialsContainers
@onready var materials_inv_info := $Menu/VBoxContainer/MenuDisplay/MaterialsInventoryDisplay/VBoxContainer/InventoryInfo
@onready var machines_inv_display := $Menu/VBoxContainer/MenuDisplay/MachinesInventoryDisplay
@onready var machines_inv_container := $Menu/VBoxContainer/MenuDisplay/MachinesInventoryDisplay/ScrollContainer/MarginContainer/HBoxContainer
@onready var build_menu_display := $Menu/VBoxContainer/MenuDisplay/BuildMenuDisplay
@onready var machine_blueprint_container := $Menu/VBoxContainer/MenuDisplay/BuildMenuDisplay/ScrollContainer/MarginContainer/HBoxContainer
@onready var upgrade_menu_display := $Menu/VBoxContainer/MenuDisplay/UpgradeMenuDisplay
@onready var upgrade_blueprint_container := $Menu/VBoxContainer/MenuDisplay/UpgradeMenuDisplay/ScrollContainer/MarginContainer/HBoxContainer

@onready var hud_materials_container : HBoxContainer = $MarginContainer/VBoxContainer/HUDMaterialsContainer
@onready var hud_energy_label: Label = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/HUDEnergyLabel


func _ready() -> void:
	for machine_type in Machine.Type.values():
		var machine_blueprint :MachineBlueprint = MACHINE_BUILD_ICON.instantiate()
		machine_blueprint.machine_type = machine_type
		machine_blueprint.machine_created.connect(update_build_menu.unbind(1))
		machine_blueprint.machine_created.connect(unlock_upgrade)
		machine_blueprint_container.add_child(machine_blueprint)
	
	for upgrade:UpgradeBlueprint in upgrade_blueprint_container.get_children():
		upgrade.upgrade_created.connect(update_upgrade_menu)
	
	# Wait until BaseCamp is created to connect
	while BaseCamp.Instance == null:
		await get_tree().create_timer(0.1).timeout
	BaseCamp.Instance.materials_stored.connect(update_hud_materials)
	BaseCamp.Instance.energy_updated.connect(update_hud_energy)
	update_hud_energy()


func _unhandled_key_input(event: InputEvent) -> void:
	if menu_opened and event.is_action_pressed("back"):
		untoggle_buttons(null)
		set_menu_visibility(false)


func set_menu_visibility(new_state:bool, sound_to_play:AudioStream = null) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(menu_node, "position", Vector2(0, 0 if new_state else 260), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	
	# Disable player input when interacting with the menu
	Player.Instance.input_disabled = new_state
	# Prevent from change camera zoom while in menu
	FollowCamera.Instance.zoom_enabled = not new_state
	
	audio_player.set_stream(UI_MENU_SOUND if sound_to_play == null else sound_to_play)
	audio_player.play()
	
	menu_opened = new_state


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


func set_menu_enabled(new_state:bool) -> void:
	for button:Button in menu_buttons.get_children():
		button.disabled = not new_state


# # #
# Materials inventory
# # #
func show_materials_inventory() -> void:
	untoggle_buttons(menu_buttons.get_child(0))
	update_menu_screens_visibility(materials_inv_display)
	update_materials_inventory()


func update_materials_inventory() -> void:
	if not menu_opened or not materials_inv_display.visible:
		return
	
	var mat_container_1 := materials_containers.get_child(0)
	var mat_container_2 := materials_containers.get_child(1)
	var player_materials := Player.Instance.materials
	
	# Remove all children
	for mat in mat_container_1.get_children():
		mat.free()
	for mat in mat_container_2.get_children():
		mat.free()
	
	# Create an icon foreach material in player's inventory
	for mat_id in player_materials.get_all_keys():
		var container := mat_container_2
		if mat_container_1.get_child_count() <= 1 or mat_container_1.get_child_count() <= mat_container_2.get_child_count():
			container = mat_container_1
		var new_mat_icon :MaterialIcon = MATERIAL_ICON.instantiate()
		
		container.add_child(new_mat_icon)
		new_mat_icon.set_sprite(MATERIALS.search_by_id(mat_id).sprite)
		new_mat_icon.set_number(player_materials.get_material_quantity_from_id(mat_id))
	
	mat_container_2.visible = mat_container_2.get_child_count() > 0
	
	# Update iventory information
	var weight_label :Label = materials_inv_info.get_child(1)
	weight_label.text = str(player_materials.current_weight) + "/" + str(player_materials.max_weight)
	weight_label.add_theme_color_override("font_color", Color.BLACK if player_materials.current_weight < player_materials.max_weight * 0.8 else Color.RED)


# # #
# Machines inventory
# # #
func show_machines_inventory() -> void:
	untoggle_buttons(menu_buttons.get_child(1))
	update_menu_screens_visibility(machines_inv_display)
	update_machines_inventory()


func update_machines_inventory() -> void:
	if not menu_opened or not machines_inv_display.visible:
		return
	
	var player_machines := Player.Instance.machines.get_all_machines()
	
	# Remove all children
	for machine in machines_inv_container.get_children():
		machine.queue_free()
	
	# Create an icon foreach machine in player's inventory
	for machine :Machine in player_machines:
		var new_machine_icon :MachineInventoryIcon = MACHINE_INV_ICON.instantiate()
		
		machines_inv_container.add_child(new_machine_icon)
		new_machine_icon.set_machine(machine)
		new_machine_icon.set_machine_amount(player_machines[machine])

# # #
# Build menu
# # #
func show_build_menu() -> void:
	untoggle_buttons(menu_buttons.get_child(2))
	update_menu_screens_visibility(build_menu_display)
	update_build_menu()


func update_build_menu() -> void:
	if not menu_opened or not build_menu_display.visible:
		return
	
	for child:MachineBlueprint in machine_blueprint_container.get_children():
		if child.blueprint_cost_display.are_all_materials_discovered():
			child.update_blueprint_info()
			child.visible = true
		else:
			child.visible = false


# # #
# Upgrade menu
# # #
func show_upgrades_menu() -> void:
	untoggle_buttons(menu_buttons.get_child(3))
	update_menu_screens_visibility(upgrade_menu_display)
	update_upgrade_menu()


func update_upgrade_menu() -> void:
	if not menu_opened or not upgrade_menu_display.visible:
		return
	
	for child:UpgradeBlueprint in upgrade_blueprint_container.get_children():
		child.update_blueprint_info()
	
	# Engineer and motorbike upgrades only available when materials are discovered
	var player_upgrade :UpgradeBlueprint = $Menu/VBoxContainer/MenuDisplay/UpgradeMenuDisplay/ScrollContainer/MarginContainer/HBoxContainer/EngineerUpgrade
	var motorbike_upgrade :UpgradeBlueprint = $Menu/VBoxContainer/MenuDisplay/UpgradeMenuDisplay/ScrollContainer/MarginContainer/HBoxContainer/MotorbikeUpgrade
	
	player_upgrade.visible = player_upgrade.current_level > 0 or player_upgrade.blueprint_cost_display.are_all_materials_discovered()
	motorbike_upgrade.visible = motorbike_upgrade.current_level > 0 or motorbike_upgrade.blueprint_cost_display.are_all_materials_discovered()


func unlock_upgrade(machine_type:Machine.Type) -> void:
	if machine_type == Machine.Type.Drill:
		$Menu/VBoxContainer/MenuDisplay/UpgradeMenuDisplay/ScrollContainer/MarginContainer/HBoxContainer/DrillUpgrade.visible = true
	elif machine_type == Machine.Type.EnergyStation:
		$Menu/VBoxContainer/MenuDisplay/UpgradeMenuDisplay/ScrollContainer/MarginContainer/HBoxContainer/EnergyStationUpgrade.visible = true
	elif machine_type == Machine.Type.CollectorDroneStation:
		$Menu/VBoxContainer/MenuDisplay/UpgradeMenuDisplay/ScrollContainer/MarginContainer/HBoxContainer/CollectorDroneUpgrade.visible = true
	elif machine_type == Machine.Type.ExplorerDroneStation:
		$Menu/VBoxContainer/MenuDisplay/UpgradeMenuDisplay/ScrollContainer/MarginContainer/HBoxContainer/ExplorerDroneUpgrade.visible = true
	elif machine_type == Machine.Type.TransportDroneStation:
		$Menu/VBoxContainer/MenuDisplay/UpgradeMenuDisplay/ScrollContainer/MarginContainer/HBoxContainer/TransportDroneUpgrade.visible = true


# # #
# HUD
# # #
func update_hud_materials() -> void:
	for child in hud_materials_container.get_children():
		child.queue_free()
	
	# Create an icon for each discovered material
	for mat_id in MATERIALS.all_materials:
		var mat :GMaterial = MATERIALS.all_materials[mat_id]
		if not mat.discovered:
			continue
		
		var new_icon :HudMatIcon = HUD_MAT_ICON.instantiate()
		hud_materials_container.add_child(new_icon)
		new_icon.set_texture(mat.sprite)
		
		# Display the amount stored in base
		if BaseCamp.Instance != null:
			new_icon.set_quantity(BaseCamp.Instance.materials.get_material_quantity_from_id(mat_id))


func update_hud_energy() -> void:
	var base := BaseCamp.Instance
	if base == null:
		return
	hud_energy_label.text = str(base.required_energy) + "/" + str(base.total_energy)
	var label_color := Color.WHITE
	if base.required_energy > base.total_energy - 4:
		label_color = Color.RED
		@warning_ignore("integer_division")
	elif base.required_energy > base.total_energy / 2:
		label_color = Color.YELLOW
	hud_energy_label.add_theme_color_override("font_color", label_color)
