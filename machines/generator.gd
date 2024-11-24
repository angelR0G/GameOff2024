class_name Generator extends MineMachine

var material_id :int = 0

func _init() -> void:
	super()
	
	# Drill parameters
	_type = Machine.Type.Generator
	machine_name = "Generator"
	description = "Increases energy capacity when placed in a mine."
	energy_cost = 0
	active = false

func on_install(mine:Mine) -> void:
	# Get mine's material and update global energy
	material_id = mine.material_id
	active = true
	powered = true

func on_destroy() -> void:
	active = false
	queue_free()

func increase_base_energy() -> void:
	BaseCamp.Instance.add_substract_energy(MATERIALS.search_by_id(material_id).energy_produced)

func decrease_base_energy() -> void:
	BaseCamp.Instance.add_substract_energy(MATERIALS.search_by_id(material_id).energy_produced * -1)

func _on_start_working() -> void:
	super()
	
	increase_base_energy()

func _on_stop_working() -> void:
	super()
	
	decrease_base_energy()
