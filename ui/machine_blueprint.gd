class_name MachineBlueprint extends Blueprint

signal machine_created

var machine_type:Machine.Type
var machine :Machine

func _ready() -> void:
	machine = MachineFactory.new_machine(machine_type)
	update_blueprint_info()


func update_blueprint_info() -> void:
	set_blueprint_name(machine.machine_name)
	set_blueprint_description(machine.description)
	set_blueprint_cost(MachineFactory.get_machine_build_cost(machine._type))


func build_machine() -> void:
	if not blueprint_cost_display.has_player_enough_materials():
		return
	
	blueprint_cost_display.remove_cost_from_player()
	Player.Instance.machines.add_machine_by_type(machine._type)
	machine_created.emit()
