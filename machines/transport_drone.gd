class_name TransportDrone extends Drone

var materials :MaterialContainer = MaterialContainer.new()

func on_target_enter() -> void:
	moving_to_target = false
	var drone_target := gl_target.get_target_object()
	
	# Collect materials from stations' storage
	if drone_target is CollectorDroneStation:
		materials.transfer_materials((drone_target as CollectorDroneStation).stored_materials)
	elif drone_target == BaseCamp.Instance:
		(drone_target as BaseCamp).store_materials(materials)
	
	if drone_target == station:
		# Notify the station, which will update its target if necessary
		drone_arrived_to_station.emit()
	else:
		return_to_station()
		moving_to_target = true
