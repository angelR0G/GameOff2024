class_name CollectorDrone extends Drone

var materials :MaterialContainer = MaterialContainer.new()

func on_target_enter() -> void:
	moving_to_target = false
	var drone_target := gl_target.get_target_object()
	
	# Collect resources from mines
	if drone_target is Mine:
		if (drone_target as Mine).has_a_drill():
			(drone_target as Mine).installed_machine.collect_materials(materials)
	
	if drone_target == station:
		(station as CollectorDroneStation).stored_materials.transfer_materials(materials)
		# Notify the station, which will update its target if necessary
		drone_arrived_to_station.emit()
	else:
		return_to_station()
		moving_to_target = true
