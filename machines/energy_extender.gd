class_name EnergyExtender extends EnergyStation


func _init() -> void:
	# Energy station parameters
	_type = Machine.Type.EnergyExtender
	machine_name = "Energy extender"
	description = "Place to extend the energy"
	energy_cost = 0
	active = true
	can_be_placed_on_world = true


func _on_energy_area_area_shape_entered(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	var machine : Machine = area.get_parent()
	if machine._type != Type.EnergyStation:
		print("Machine entered")
		if machine_already_connected(machine) == -1:
			connected_machines.append(machine)
			machine.set_machine_powered(true)
			print("Added")
		deactivate_all_connected_machines()


func _on_energy_area_area_shape_exited(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area != null:
		var machine : Machine = area.get_parent()
		print("Machine exited")
		if machine_already_connected(machine) != -1:
			connected_machines.erase(machine)
			machine.set_machine_powered(false)
			print("Removed")
