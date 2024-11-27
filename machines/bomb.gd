class_name Bomb extends Machine

func _init() -> void:
	# Bomb parameters
	_type = Machine.Type.Bomb
	machine_name = "Land Claimer"
	description = ""
	energy_cost = 0
	can_be_placed_on_world = false
	place_instructions = ""
	active = false
