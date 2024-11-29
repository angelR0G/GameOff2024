class_name EnergyExtender extends EnergyStation


func _init() -> void:
	# Energy station parameters
	_type = Machine.Type.EnergyExtender
	machine_name = "Energy extender"
	description = "Placed close to an energy source, it provides energy to nearby machines."
	energy_cost = 0
	active = true
	can_be_placed_on_world = true


func _ready() -> void:
	interaction.interaction_function = _interaction
	powered = false
	active = true
	update_energy_radius()


func _on_upgrade() -> void:
	radius += 2.0
	
	update_energy_radius()


func _on_energy_area_area_shape_entered(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	var machine : Machine = area.get_parent()
	if machine is EnergyStation:
		connect_energy_source(machine)
	else:
		connect_machine(machine)


func _on_energy_area_area_shape_exited(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area != null:
		var machine : Machine = area.get_parent()
		if machine is EnergyStation:
			disconnect_energy_source(machine)
		else:
			disconnect_machine(machine)


func connect_energy_source(machine:EnergyStation) -> void:
	if machine == null or connected_energy_sources.has(machine):
		return
	
	connected_energy_sources.append(machine)
	machine.energy_supply_state_change.connect(power_state_changed)
	
	if machine.is_working():
		power_state_changed(true)

func disconnect_energy_source(machine:EnergyStation) -> void:
	if machine == null:
		return
	
	var machine_index := connected_energy_sources.find(machine)
	if machine_index != -1:
		connected_energy_sources.remove_at(machine_index)
		machine.energy_supply_state_change.disconnect(power_state_changed)
	
	update_power_supply()


func power_state_changed(new_state:bool) -> void:
	if new_state != powered:
		powered = new_state
		
		if not powered:
			await get_tree().create_timer(0.2).timeout
			update_power_supply()
