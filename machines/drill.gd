class_name Drill extends MineMachine

var material_id :int = 0
var material_amount :int = 0
var current_weight :int = 0
static var max_weight :int = 20
static var mining_speed :float = 1.0

@onready var mining_timer := $MiningTimer

func _init() -> void:
	super()
	
	# Drill parameters
	_type = Machine.Type.Drill
	machine_name = "Drill"
	description = "Extracts materials from mines."
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

func _on_upgraded() -> void:
	update_mining_time()
	
	if mining_timer.is_stopped():
		mine_materials()


func collect_materials(container:MaterialContainer) -> void:
	if container != null and material_amount > 0:
		material_amount -= container.add_material(material_id, material_amount)
		current_weight = MATERIALS.search_by_id(material_id).weight * material_amount
	
	mine_materials()
	return


func mine_materials() -> void:
	if not is_working():
		return
	
	if mining_timer.is_stopped(): 
		if has_capacity_for_more_materials():
			mining_timer.start()
			update_drill_full_state(false)
		else:
			update_drill_full_state(true)


func update_drill_full_state(is_full:bool) -> void:
	if is_full:
		anim.stop()
	else:
		anim.play("working")


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
	
	InteractionsDisplay.Instance.add_interaction("Collect Materials", collect_materials.bind(Player.Instance.materials), material_amount == 0)


func _on_start_working() -> void:
	super()
	
	if mining_timer and mining_timer.paused:
		mining_timer.paused = false
	else:
		mine_materials()

func _on_stop_working() -> void:
	super()
	
	if mining_timer and not mining_timer.is_stopped():
		mining_timer.paused = true
