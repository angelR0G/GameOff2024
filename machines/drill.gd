class_name Drill extends MineMachine

var material_amount :int = 0
var current_weight :int = 0
var max_weight :int = 20
var material_id :int = 0
var mining_speed :float = 1.0

@onready var mining_timer := $MiningTimer

func _init() -> void:
	super()
	
	# Drill parameters
	_type = Machine.Type.Drill
	machine_name = "Drill"
	description = "Place in a mine to extract materials."
	energy_cost = 1
	active = false


func on_install(mine:Mine) -> void:
	# Reset values
	material_amount = 0
	current_weight = 0
	active = true
	
	# Get mine's material and update necessary parameters
	material_id = mine.material_id
	update_mining_time()
	
	# Start mining
	mine_materials()


func collect_materials() -> void:
	#material_amount -= Player.Instance.materials.add_material(material_id, material_amount)
	mine_materials()
	return


func mine_materials() -> void:
	if has_capacity_for_more_materials() and mining_timer.is_stopped():
		mining_timer.start()


func _on_material_extracted() -> void:
	if not has_capacity_for_more_materials():
		return
	
	material_amount += 1
	current_weight += MATERIALS.search_by_id(material_id).weight
	
	# Continues mining materials if has enough capacity
	mine_materials()


func has_capacity_for_more_materials() -> bool:
	var material_weight := MATERIALS.search_by_id(material_id).weight
	
	return current_weight + material_weight <= max_weight


func update_mining_time() -> void:
	var material_mining_time := MATERIALS.search_by_id(material_id).extraction_time
	
	mining_timer.wait_time = material_mining_time / mining_speed


func display_interactions() -> void:
	super()
	
	InteractionsDisplay.Instance.add_interaction("Collect Materials", collect_materials, material_amount == 0)


func set_machine_active(new_state:bool) -> void:
	super(new_state)
	
	mining_timer.paused = not new_state
