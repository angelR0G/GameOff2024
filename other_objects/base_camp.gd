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
	var interactions_ui := InteractionsDisplay.Instance
	interactions_ui.add_interaction("Store Materials", store_materials.bind(Player.Instance.materials))
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed
