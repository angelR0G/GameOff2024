class_name ExplorerDrone extends Drone

signal drone_explored_mine

func on_target_enter() -> void:
	moving_to_target = false
	var drone_target := gl_target.get_target_object()
	
	# Explore the mine when arrives
	if drone_target is Mine:
		await explore_mine(drone_target)
	
	if drone_target == station:
		# Notify the station, which will update its target if necessary
		drone_arrived_to_station.emit()
	else:
		return_to_station()
		moving_to_target = true


func explore_mine(mine:Mine) -> void:
	if not mine.explored:
		await mine.explore_mine(false)
		drone_explored_mine.emit()
