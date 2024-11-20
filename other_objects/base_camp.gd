class_name BaseCamp extends Node3D

const material_container := preload("res://materials/material_container.gd")

static var Instance :BaseCamp = null

var total_energy: int = 3
var materials :MaterialContainer = MaterialContainer.new()

@onready var interaction := $InteractionTrigger
@onready var game_location: GameLocation = $GameLocation

func _ready() -> void:
	if Instance == null:
		Instance = self
	interaction.interaction_function = _interaction

func _init() -> void:
	materials.max_weight = -1
	return

func store_materials(new_mat:MaterialContainer)->void:
	materials.transfer_materials(new_mat)
	return
	
func add_substract_energy(energy:int) -> void:
	total_energy+=energy
	return

func _interaction() -> void:
	var motorbike :Motorbike = get_tree().get_nodes_in_group("bike")[0]
	var can_motorbike_be_unload := func() -> bool:
		if motorbike.stored_materials.current_weight <= 0:
			return false
		
		var d := global_position.distance_to(motorbike.global_position)
		return d < 20.0
	
	var interactions_ui := InteractionsDisplay.Instance
	interactions_ui.add_interaction("Store Materials", store_materials.bind(Player.Instance.materials), Player.Instance.materials.current_weight <= 0)
	interactions_ui.add_interaction("Unload Motorbike", store_materials.bind(motorbike.stored_materials), not can_motorbike_be_unload.call())
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed
