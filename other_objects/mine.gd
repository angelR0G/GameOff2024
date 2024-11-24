class_name Mine extends StaticBody3D

const EXPLORE_UI := preload("res://ui/explore_ui.tscn")
const EXPLORATION_TIME := 10.0

@export var material_id :int = 0
var explored :bool = false
var installed_machine :MineMachine = null

@onready var mesh := $Mesh
@onready var interaction := $InteractionTrigger
@onready var mine_machine_spot := $MineMachineSpot
@onready var game_location :GameLocation = $GameLocation

func _ready() -> void:
	interaction.interaction_function = _interaction

func _interaction() -> void:
	var interactions_ui := InteractionsDisplay.Instance
	
	if not explored:
		interactions_ui.add_interaction("Explore Mine", explore_mine)
	elif installed_machine == null:
		if MATERIALS.is_special_material(material_id):
			# It has a special material that can be collected
			interactions_ui.add_interaction("Extract Rare Material", extract_special_material)
		else:
			# Empty mine, a machine can be installed
			var place_machine_by_type := func(type:Machine.Type) -> void:
				var machine :Machine = Player.Instance.machines.remove_machine_by_type(type)
				if machine != null:
					place_machine(machine)
			
			interactions_ui.add_interaction("Place Drill", place_machine_by_type.bind(Machine.Type.Drill), not Player.Instance.machines.has_machine_of_type(Machine.Type.Drill))
			interactions_ui.add_interaction("Place Generator", place_machine_by_type.bind(Machine.Type.Generator), not Player.Instance.machines.has_machine_of_type(Machine.Type.Generator))
	else:
		# Mine with machine, display machine interactions
		installed_machine.display_interactions()
		interactions_ui.add_interaction("Remove Machine", destroy_machine)
	
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed

func explore_mine(is_player_exploring:bool = true) -> void:
	if explored:
		return
	
	if is_player_exploring:
		Player.Instance.input_disabled = true
		var explore_ui := EXPLORE_UI.instantiate()
		Player.Instance.hud.add_child(explore_ui)
		await  explore_ui.start_exploration(EXPLORATION_TIME)
	else:
		await get_tree().create_timer(EXPLORATION_TIME).timeout
	
	mesh.material_override = load("res://resources/materials/researched_mine.tres")
	
	if is_player_exploring:
		Player.Instance.input_disabled = false
	
	explored = true


func place_machine(machine:MineMachine) -> bool:
	if installed_machine != null:
		return false
	
	installed_machine = machine
	add_child(installed_machine)
	installed_machine.position = mine_machine_spot.position
	installed_machine.on_install(self)
	
	return true


func destroy_machine() -> void:
	if installed_machine == null:
		return
	
	installed_machine.on_destroy()
	installed_machine = null
	


func has_a_drill() -> bool:
	return installed_machine != null and installed_machine is Drill


func extract_special_material() -> void:
	if not MATERIALS.is_special_material(material_id):
		return
	
	var player_mat :MaterialContainer = Player.Instance.materials
	if (player_mat.max_weight - player_mat.current_weight) >= MATERIALS.search_by_id(material_id).weight:
		# Player gets the material and mine starts producing basic material
		Player.Instance.materials.add_material(material_id, 1)
		material_id = 1
