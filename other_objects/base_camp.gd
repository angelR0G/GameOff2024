class_name BaseCamp extends Node

const material_container := preload("res://materials/material_container.gd")

@export var total_energy: int
@export var materials :MaterialContainer = MaterialContainer.new()

@onready var interaction := $InteractionTrigger

func store_materials(player:Player)->void:
	for key in player.materials.objects.keys():
		var value = player.materials.objects[key]
		if materials.objects.has(key):
			
			materials.objects[key] = materials.objects.get(key)+value
			#print("Added existing value at " + str(key) + " with value " + str(materials.objects[key]))
		else:
			materials.objects[key] = value
			#print("Added new value at " + str(key) + " with value " + str(materials.objects[key]))
	return


func _ready() -> void:
	interaction.on_interact.connect(_interaction)

func _interaction() -> void:
	store_materials(Player.Instance)
	return
