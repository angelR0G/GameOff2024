class_name EnergyStation extends Machine


@export var radius: float
var connected_machines: Array[Machine]

@onready var energy_area:Area3D = $EnergyArea
@onready var energy_collider:CollisionShape3D = $EnergyArea/EnergyCollision
@onready var debug_mesh: MeshInstance3D = $EnergyArea/DebugMesh
@onready var interaction := $InteractionTrigger

func _init() -> void:
	# Energy station parameters
	_type = Machine.Type.EnergyStation
	machine_name = "Energy station"
	description = "Place to take energy from the base"
	energy_cost = 1
	active = false
	can_be_placed_on_world = true

func _ready() -> void:
	interaction.interaction_function = _interaction
	
	var collider:SphereShape3D = SphereShape3D.new()
	collider.set_radius(radius)
	energy_collider.set_shape(collider)
	#connected_machines.append(self)
	
	## Draw energy radius for debug
	#debug_mesh.mesh = energy_collider.shape.get_debug_mesh()
	return

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
		interactions_ui.add_interaction("Turn Off", set_machine_energy_active.bind(false))
	else:
		interactions_ui.add_interaction("Turn On", set_machine_energy_active.bind(true))

func set_machine_energy_active(state:bool)-> void:
	set_machine_active(state)
	for machine in connected_machines:
		#machine.set_machine_active(state)
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
		deactivate_all_connected_machines()


func _on_energy_area_area_shape_exited(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area != null:
		var machine : Machine = area.get_parent()
		print("Machine exited")
		if machine_already_connected(machine) != -1:
			connected_machines.erase(machine)
			machine.set_machine_powered(false)
			print("Removed")

func print_connected_machines(machines:Machine, spacer:int)->void:
	for machine in machines.connected_machines:

		print_rich("[color=green][b]"+ str(spacer)+". "+ machine.machine_name +"[/b][/color]")
		if machine != self:
			if machine._type == Type.EnergyExtender || machine._type == Type.EnergyStation:
				spacer +=1
				print_connected_machines(machine, spacer)
