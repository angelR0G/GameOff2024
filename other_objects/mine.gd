class_name Mine extends Node3D

@export var material_id :int = 0
var explored :bool = false
var installed_machine :MineMachine = null

@onready var mesh := $Mesh
@onready var interaction := $InteractionTrigger
@onready var mine_machine_spot := $MineMachineSpot

func _ready() -> void:
	interaction.on_interact.connect(_interaction)

func _interaction() -> void:
	if not explored:
		Player.Instance.movement_enabled = false
		await explore_mine()
		Player.Instance.movement_enabled = true
	else:
		if installed_machine == null and not Player.Instance.machines.is_empty():
			var placed_machine :MineMachine = null
			for m in Player.Instance.machines:
				if m is MineMachine:
					placed_machine = m
					break
				
			place_machine(placed_machine)
			Player.Instance.machines.erase(placed_machine)
			return
		

func explore_mine() -> void:
	if explored:
		return
	
	await get_tree().create_timer(10).timeout
	mesh.material_override.albedo_color = Color(255, 0, 255)
	
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
	
