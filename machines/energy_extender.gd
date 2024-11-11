class_name EnergyExtender extends EnergyStation


func _init() -> void:
	# Energy station parameters
	_type = Machine.Type.EnergyExtender
	machine_name = "Energy extender"
	description = "Place to extend the energy"
	energy_cost = 0
	active = true
	can_be_placed_on_world = true
