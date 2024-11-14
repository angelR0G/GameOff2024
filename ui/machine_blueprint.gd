class_name MachineBlueprint extends Blueprint

@export var machine_scene:PackedScene = null
var machine :Machine

func _ready() -> void:
	var instantiated_scene := _try_to_instantiate_machine()
	if instantiated_scene == null:
		queue_free()
		return
	
	machine = instantiated_scene
	set_blueprint_name(machine.machine_name)
	set_blueprint_description(machine.description)
	set_blueprint_cost(MachineFactory.get_machine_build_cost(machine._type))


func build_machine() -> void:
	if not blueprint_cost_display.has_player_enough_materials():
		return
	
	blueprint_cost_display.remove_cost_from_player()
	Player.Instance.machines.add_machine_by_type(machine._type)


func _try_to_instantiate_machine() -> Node:
	if machine_scene == null:
		return null
	
	var instantiated_scene := machine_scene.instantiate()
	if not instantiated_scene is Machine:
		instantiated_scene.queue_free()
		return null
	
	return instantiated_scene
