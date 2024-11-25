class_name EnergyStation extends Machine


@export var radius: float
var connected_machines: Array[Machine]
var total_energy:int = 0

@onready var energy_area:Area3D = $EnergyArea
@onready var energy_collider:CollisionShape3D = $EnergyArea/EnergyCollision
@onready var debug_mesh: MeshInstance3D = $EnergyArea/DebugMesh
@onready var interaction := $InteractionTrigger

func _init() -> void:
	# Energy station parameters
	_type = Machine.Type.EnergyStation
	machine_name = "Energy station"
	description = "Provides energy to surrounding machines."
	energy_cost = 1
	active = false
	can_be_placed_on_world = true


func _ready() -> void:
	interaction.interaction_function = _interaction
	powered = true
	active = true
	update_energy_radius()


func _on_upgrade() -> void:
	radius += 5.0
	
	update_energy_radius()


func update_energy_radius() -> void:
	var collider:SphereShape3D = SphereShape3D.new()
	collider.set_radius(radius)
	energy_collider.set_shape(collider)


func deactivate_all_connected_machines() -> void:
	if BaseCamp.Instance.total_energy < total_energy:
		for machine in connected_machines:
			if !self && machine.energy_cost > 0:
				machine.set_machine_powered(false)

	
func calculate_energy_cost() -> int:
	total_energy = energy_cost
	for machine in connected_machines:
		if machine.active:
			total_energy += machine.energy_cost
	BaseCamp.Instance.update_required_energy_cost()
	return total_energy
		
	
func get_total_energy_cost() -> int:
	return total_energy

func machine_already_connected(new_machine:Machine) -> int:
	return connected_machines.find(new_machine)
	
#func display_interactions() -> void:
	#var interactions_ui := InteractionsDisplay.Instance
	#
	#if active:
		#interactions_ui.add_interaction("Turn Off", set_machine_energy_active.bind(false))
	#else:
		#interactions_ui.add_interaction("Turn On", set_machine_energy_active.bind(true))

func _on_start_working() -> void:
	super()
	
	set_machine_energy_active(true)

func _on_stop_working() -> void:
	super()
	
	set_machine_energy_active(false)

func set_machine_energy_active(state:bool)-> void:
	for machine in connected_machines:
		machine.set_machine_powered(state)

func _interaction() -> void:
	var interactions_ui := InteractionsDisplay.Instance

	display_interactions()
	interactions_ui.add_interaction("Remove Machine", destroy)
	
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed


func destroy() -> void:
	
	for machine in connected_machines:
		machine.set_machine_powered(false)
	queue_free()
	
func _on_energy_area_area_shape_entered(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	var machine : Machine = area.get_parent()
	if machine._type != Type.EnergyStation:
		print("Machine entered")
		if machine_already_connected(machine) == -1:
			connected_machines.append(machine)
			machine.set_machine_powered(true)
			print("Added")
		calculate_energy_cost()
		deactivate_all_connected_machines()


func _on_energy_area_area_shape_exited(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area != null:
		var machine : Machine = area.get_parent()
		print("Machine exited")
		if machine_already_connected(machine) != -1:
			connected_machines.erase(machine)
			machine.set_machine_powered(false)
			calculate_energy_cost()
			print("Removed")
