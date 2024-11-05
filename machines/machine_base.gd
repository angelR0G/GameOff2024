class_name Machine extends Node3D

var machine_name :StringName
var description :String
var energy_cost :int = 0
var active :bool = false
var can_be_placed_on_world :bool = true

func is_powered() -> bool:
	return true
