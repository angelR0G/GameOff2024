class_name MineMachine extends Machine

func _init() -> void:
	can_be_placed_on_world = false
	place_instructions = "Place in a mine"

func on_install(_mine:Mine) -> void:
	return

func on_destroy() -> void:
	destroy_machine()
