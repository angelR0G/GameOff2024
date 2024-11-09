class_name Machine extends Node3D

enum Type {
	Drill,
	Generator,
	EnergyStation,
	EnergyExtender
}

var _type :Type
var machine_name :StringName
var description :String
var energy_cost :int = 0
var active :bool = false
var powered:bool = false
var can_be_placed_on_world :bool = true

func is_powered() -> bool:
	return powered

func set_machine_powered(new_state:bool) -> void:
	powered = new_state

@warning_ignore("unused_parameter")
func on_install(mine:Mine) -> void:
	return

func on_destroy() -> void:
	return

func display_interactions() -> void:
	var interactions_ui := InteractionsDisplay.Instance
	
	if active:
		interactions_ui.add_interaction("Turn Off", set_machine_active.bind(false))
	else:
		interactions_ui.add_interaction("Turn On", set_machine_active.bind(true))

func set_machine_active(new_state:bool) -> void:
	active = new_state
