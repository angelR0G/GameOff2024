class_name ExplorerDrone extends Drone



func update_target() -> void:
	pass

func on_target_enter() -> void:
	moving_to_target = false
	var drone_target := gl_target.get_target_object()
	
	# Explore the mine when arrives
	if drone_target is Mine:
		await explore_mine(drone_target)
	
	if drone_target == station:
		# If posible, gets a new target from the station
		request_new_target()
	else:
		return_to_station()
		moving_to_target = true


func explore_mine(mine:Mine) -> void:
	if not mine.explored:
		await mine.explore_mine(false)
		mine.explored_mines_count += 1


func request_new_target() -> void:
	set_target(station.get_new_drone_target())
