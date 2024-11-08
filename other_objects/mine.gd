class_name Mine extends Node3D

@export var material_id :int = 0
var explored :bool = false
var installed_machine :MineMachine = null

@onready var mesh := $Mesh
@onready var interaction := $InteractionTrigger
@onready var mine_machine_spot := $MineMachineSpot

func _ready() -> void:
	interaction.interaction_function = _interaction

func _interaction() -> void:
	var interactions_ui := InteractionsDisplay.Instance
	
	if not explored:
		interactions_ui.add_interaction("Explore Mine", explore_mine)
	elif installed_machine == null:
		var place_drill := func() -> void:
			var drill :Machine = Player.Instance.machines.remove_machine_by_type(Machine.Type.Drill)
			if drill != null:
				place_machine(drill)
		
		interactions_ui.add_interaction("Place Drill", place_drill, not Player.Instance.machines.has_machine_of_type(Machine.Type.Drill))
	else:
		interactions_ui.add_interaction("Easter Egg", Callable(), true)
	
	interactions_ui.show_list()
	await interactions_ui.display_closed

func explore_mine() -> void:
	if explored:
		return
	
	Player.Instance.movement_enabled = false
		
	await get_tree().create_timer(10).timeout
	mesh.material_override.albedo_color = Color(255, 0, 255)
	
	Player.Instance.movement_enabled = true
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
	
