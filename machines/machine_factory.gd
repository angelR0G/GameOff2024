class_name MachineFactory extends Node

const machine_scenes :Dictionary = {
	Machine.Type.Drill : preload("res://machines/drill.tscn"),
	Machine.Type.Generator : preload("res://machines/generator.tscn"),
	Machine.Type.EnergyStation : preload("res://machines/energy_station.tscn"),
	Machine.Type.EnergyExtender : preload("res://machines/energy_extender.tscn")
}

static func new_machine(type:Machine.Type) -> Machine:
	return machine_scenes[type].instantiate()
