class_name Drill extends MineMachine

var material_amount :int = 0
var current_weight :int = 0
var max_weight :int = 0
var material_id : int = 0

@onready var mining_timer = $MiningTimer

func _init() -> void:
	super()
	
	# Drill parameters
	machine_name = "Drill"
	description = "Place in a mine to extract materials."
	energy_cost = 1
	active = false


func on_install(mine:Mine) -> void:
	# Reset values
	material_amount = 0
	current_weight = 0
	
	# Get mine's material and update necessary parameters
	#material_id = mine.materialID
	update_mining_time()
	
	# Start mining
	mine_materials()


func collect_materials() -> void:
	return


func mine_materials() -> void:
	if has_capacity_for_more_materials():
		mining_timer.start()


func _on_material_extracted() -> void:
	if not has_capacity_for_more_materials():
		return
	
	material_amount += 1
	#current_weight += material_id.weight
	
	# Continues mining materials if has enough capacity
	mine_materials()


func has_capacity_for_more_materials() -> bool:
	#return current_weight + material_id.weight <= max_weight
	return true


func update_mining_time() -> void:
	#mining_timer.wait_time = material.time
	return
