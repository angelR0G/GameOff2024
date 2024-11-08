class_name MachineFactory extends Node

const machine_scenes :Dictionary = {
	Machine.Type.Drill : preload("res://machines/drill.tscn"),
	Machine.Type.Generator : preload("res://machines/generator.tscn")
}

static func new_machine(type:Machine.Type) -> Machine:
	return machine_scenes[type].instantiate()
