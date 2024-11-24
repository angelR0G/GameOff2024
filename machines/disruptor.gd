class_name Disruptor extends Machine

func _init() -> void:
	# Disruptor parameters
	_type = Machine.Type.Disruptor
	machine_name = "Disruptor"
	description = "Deactivates barriers to unlock new areas."
	energy_cost = 0
	can_be_placed_on_world = false
	place_instructions = "Use in a barrier."
	active = false
