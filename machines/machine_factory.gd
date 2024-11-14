class_name MachineFactory extends Node

const machine_scenes :Dictionary = {
	Machine.Type.Drill : preload("res://machines/drill.tscn"),
	Machine.Type.Generator : preload("res://machines/generator.tscn"),
	Machine.Type.EnergyStation : preload("res://machines/energy_station.tscn"),
	Machine.Type.EnergyExtender : preload("res://machines/energy_extender.tscn")
}

const machine_build_cost :Dictionary = {
	Machine.Type.Drill : {1:6},
	Machine.Type.Generator : {1:6},
	Machine.Type.EnergyStation : {1:6},
	Machine.Type.EnergyExtender : {1:6}
}

static func new_machine(type:Machine.Type) -> Machine:
	return machine_scenes[type].instantiate()

static func get_machine_build_cost(type:Machine.Type) -> Dictionary:
	return machine_build_cost.get(type, {})
