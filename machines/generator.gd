class_name Generator extends MineMachine

var material_id :int = 0

func _init() -> void:
	super()
	
	# Drill parameters
	_type = Machine.Type.Generator
	machine_name = "Generator"
	description = "Place in a mine to extract energy."
	energy_cost = 0
	active = false

func on_install(mine:Mine) -> void:
	active = true
	
	# Get mine's material and update global energy
	material_id = mine.material_id
	BaseCamp.Instance.add_substract_energy(MATERIALS.search_by_id(material_id).energy_produced)

func on_destroy() -> void:
	# Update global energy and destroy object
	BaseCamp.Instance.add_substract_energy((-1)*MATERIALS.search_by_id(material_id).energy_produced)
	queue_free()
	
func set_machine_active(new_state:bool) -> void:
	super(new_state)
	var energy_multiplier := 1 if new_state else -1
	BaseCamp.Instance.add_substract_energy(energy_multiplier*MATERIALS.search_by_id(material_id).energy_produced)
