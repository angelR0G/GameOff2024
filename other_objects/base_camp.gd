class_name BaseCamp extends Node3D

const BASE_ENERGY := 4
const material_container := preload("res://materials/material_container.gd")

signal materials_stored
signal energy_updated

static var Instance :BaseCamp = null

var total_energy: int = BASE_ENERGY
var required_energy :int = 0 : set = _set_required_energy
var powered_machines :Array[Machine] = []
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
	total_energy += energy
	
	# If total energy goes below required energy, turn off machines
	while required_energy > total_energy and not powered_machines.is_empty():
		powered_machines.back().active = false
	
	energy_updated.emit()


func _set_required_energy(e : int) -> void:
	required_energy = e
	energy_updated.emit()


func add_machine_to_powered(machine:Machine) -> void:
	if machine == null or machine.energy_cost <= 0:
		return
	
	if not powered_machines.has(machine):
		powered_machines.append(machine)
		required_energy += machine.energy_cost


func remove_machine_from_powered(machine:Machine) -> void:
	var machine_index := powered_machines.find(machine)
	if machine_index == -1:
		return
	
	powered_machines.remove_at(machine_index)
	required_energy -= machine.energy_cost


static func has_enough_energy(extra_cost:int) -> bool:
	if BaseCamp.Instance == null:
		return true
	
	return BaseCamp.Instance.required_energy + extra_cost <= BaseCamp.Instance.total_energy

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
