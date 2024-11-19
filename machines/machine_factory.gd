class_name MachineFactory extends Node

const machine_scenes :Dictionary = {
	Machine.Type.Drill : preload("res://machines/drill.tscn"),
	Machine.Type.Generator : preload("res://machines/generator.tscn"),
	Machine.Type.EnergyStation : preload("res://machines/energy_station.tscn"),
	Machine.Type.EnergyExtender : preload("res://machines/energy_extender.tscn"),
	Machine.Type.ExplorerDroneStation : preload("res://machines/explorer_drone_station.tscn"),
	Machine.Type.CollectorDroneStation : preload("res://machines/collector_drone_station.tscn"),
	Machine.Type.TransportDroneStation : preload("res://machines/transport_drone_station.tscn"),
}

const machine_build_cost :Dictionary = {
	Machine.Type.Drill : {1:6},
	Machine.Type.Generator : {1:30, 2:10, 3:5},
	Machine.Type.EnergyStation : {2:20, 3:5, 4:5},
	Machine.Type.EnergyExtender : {2:3},
	Machine.Type.ExplorerDroneStation : {1:40, 4:1},
	Machine.Type.CollectorDroneStation : {3:50, 5:15, 6:3},
	Machine.Type.TransportDroneStation : {7:10, 5:15, 6:3},
}

static func new_machine(type:Machine.Type) -> Machine:
	return machine_scenes[type].instantiate()

static func get_machine_build_cost(type:Machine.Type) -> Dictionary:
	return machine_build_cost.get(type, {})
