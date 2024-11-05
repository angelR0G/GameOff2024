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


# Binds the drill to a mine and start mining
#func place_in_mine(mine:Mine) -> bool:
	#material_id = mine.materialID
	#material_amount = 0
	#current_weight = 0
	#
	#mining_timer.wait_time = material.time
	#mining_timer.start()


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
