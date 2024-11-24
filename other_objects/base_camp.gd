class_name BaseCamp extends Node3D

const material_container := preload("res://materials/material_container.gd")

signal materials_stored

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
	mark_stored_materials_as_discovered()
	materials_stored.emit()

func add_substract_energy(energy:int) -> void:
	total_energy+=energy
	return

func _interaction() -> void:
	var motorbike :Motorbike = get_tree().get_first_node_in_group("bike")
	var can_motorbike_be_unload := func() -> bool:
		if motorbike == null or motorbike.stored_materials.current_weight <= 0:
			return false
		
		var d := global_position.distance_to(motorbike.global_position)
		return d < 20.0
	
	var interactions_ui := InteractionsDisplay.Instance
	interactions_ui.add_interaction("Store Materials", store_materials.bind(Player.Instance.materials), Player.Instance.materials.current_weight <= 0)
	interactions_ui.add_interaction("Unload Motorbike", store_materials.bind(motorbike.stored_materials), not can_motorbike_be_unload.call())
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed


func mark_stored_materials_as_discovered() -> void:
	for mat_id in materials.get_all_keys():
		MATERIALS.search_by_id(mat_id).discovered = true
