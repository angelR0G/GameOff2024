class_name MachineFactory extends Node

enum MachineType {
	Drill
}

const machine_scenes :Dictionary = {
	MachineType.Drill : preload("res://machines/drill.tscn")
}

static func new_machine(type:MachineType) -> Machine:
	return machine_scenes[type].instantiate()
