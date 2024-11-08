class_name BaseCamp extends Node

const material_container := preload("res://materials/material_container.gd")

static var Instance :BaseCamp = null

var total_energy: int = 10
var materials :MaterialContainer = MaterialContainer.new()

@onready var interaction := $InteractionTrigger

func _ready() -> void:
	if Instance == null:
		Instance = self
	interaction.interaction_function = _interaction

func _init() -> void:
	materials.max_weight = -1
	return

func store_materials(player:Player)->void:
	materials.transfer_materials(player.materials)
	return
	
func add_substract_energy(energy:int) -> void:
	total_energy+=energy
	return

func _interaction() -> void:
	store_materials(Player.Instance)
	return
