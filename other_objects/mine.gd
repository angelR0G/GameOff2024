class_name Mine extends Node3D

var material_id :int = 0
var explored :bool = false
var installed_machine :MineMachine = null

@onready var mesh := $Mesh
@onready var interaction := $InteractionTrigger

func _ready() -> void:
	interaction.on_interact.connect(_interaction)

func _interaction() -> void:
	if not explored:
		Player.Instance.movement_enabled = false
		await explore_mine()
		Player.Instance.movement_enabled = true
	else:
		print("Mining time")

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
	installed_machine.on_install(self)
	
	return true


func destroy_machine() -> void:
	if installed_machine == null:
		return
	
	installed_machine.on_destroy()
	installed_machine = null
	
