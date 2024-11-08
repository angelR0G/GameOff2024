class_name BaseCamp extends Node

const material_container := preload("res://materials/material_container.gd")

@export var total_energy: int
@export var materials :MaterialContainer = MaterialContainer.new()

@onready var interaction := $InteractionTrigger

func store_materials(player:Player)->void:
	materials.transfer_materials(player.materials)
	return
	
func add_energy() -> void:
	pass

func _ready() -> void:
	interaction.interaction_function = _interaction

func _interaction() -> void:
	store_materials(Player.Instance)
	return
