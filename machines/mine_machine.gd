class_name MineMachine extends Machine

func _init() -> void:
	can_be_placed_on_world = false

func on_install(_mine:Mine) -> void:
	return

func on_destroy() -> void:
	return
