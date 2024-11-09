class_name EnergyStation extends Machine


@export var radius: float
var connected_machines: Array[Machine]

@onready var energy_area:Area3D = $Area3D
@onready var energy_collider:CollisionShape3D = $Area3D/CollisionShape3D
@onready var interaction := $InteractionTrigger

func _init() -> void:
	# Energy station parameters
	_type = Machine.Type.EnergyStation
	machine_name = "Energy station"
	description = "Place to take energy from the base"
	energy_cost = 1
	active = true
	can_be_placed_on_world = true

func _ready() -> void:
	interaction.interaction_function = _interaction
	
	var collider:SphereShape3D = SphereShape3D.new()
	collider.set_radius(radius)
	energy_collider.set_shape(collider)
	connected_machines.append(self)
	return

func connect_machine() -> void:
	pass
	
func disconnect_machine() -> void:
	pass

func deactivate_all_connected_machines() -> void:
	if BaseCamp.Instance.total_energy < calculate_energy_cost():
		for machine in connected_machines:
			machine.set_machine_active(false)
			if !self:
				machine.set_machine_powered(false)

	
func calculate_energy_cost() -> int:
	var total_energy = 0
	for machine in connected_machines:
		if machine.active:
			total_energy += machine.energy_cost
	return total_energy
		
	
func machine_already_connected(new_machine:Machine) -> int:
	return connected_machines.find(new_machine)
	
func display_interactions() -> void:
	var interactions_ui := InteractionsDisplay.Instance
	
	if active:
		interactions_ui.add_interaction("Turn Off", set_machine_active.bind(false))
	else:
		interactions_ui.add_interaction("Turn On", set_machine_active.bind(true))

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
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	var machine : Machine = area.get_parent()
	print("Machine entered")
	if machine_already_connected(machine) == -1:
		connected_machines.append(machine)
		machine.set_machine_powered(true)
		print("Added")
	deactivate_all_connected_machines()

func _on_area_3d_area_exited(area: Area3D) -> void:
	var machine : Machine = area.get_parent()
	print("Machine exited")
	if machine_already_connected(machine) != -1:
		connected_machines.erase(machine)
		machine.set_machine_powered(false)
		print("Removed")
