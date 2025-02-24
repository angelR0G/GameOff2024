class_name EnergyStation extends Machine

const ENERGY_AREA_SHADER = preload("res://shaders/circle_energy.gdshader")

signal energy_supply_state_change(power:bool)

@export var radius: float
var connected_machines: Array[Machine]

@onready var energy_area:Area3D = $EnergyArea
@onready var energy_collider:CollisionShape3D = $EnergyArea/EnergyCollision
@onready var debug_mesh: MeshInstance3D = $EnergyArea/DebugMesh
@onready var interaction := $InteractionTrigger
@onready var energy_area_plane := $EnergyAreaPlane

func _init() -> void:
	# Energy station parameters
	_type = Machine.Type.EnergyStation
	machine_name = "Energy station"
	description = "Provides energy to surrounding machines."
	energy_cost = 2
	active = false
	can_be_placed_on_world = true


func _ready() -> void:
	interaction.interaction_function = _interaction
	powered = true
	active = true
	update_energy_radius()


func _on_upgrade() -> void:
	radius += 4.0
	
	update_energy_radius()
	set_energy_area_mesh(is_working(), true)


func update_energy_radius() -> void:
	var collider:SphereShape3D = SphereShape3D.new()
	collider.set_radius(radius)
	energy_collider.set_shape(collider)


func machine_already_connected(new_machine:Machine) -> bool:
	return connected_machines.has(new_machine)

func _on_start_working() -> void:
	super()
	
	set_energy_area_mesh(true)
	update_connected_machines()
	energy_supply_state_change.emit(true)
	audio_player.play()

func _on_stop_working() -> void:
	super()
	
	set_energy_area_mesh(false)
	update_connected_machines()
	energy_supply_state_change.emit(false)
	audio_player.stop()

func update_connected_machines() -> void:
	for machine in connected_machines:
		machine.update_power_supply()

func _interaction() -> void:
	var interactions_ui := InteractionsDisplay.Instance

	display_interactions()
	interactions_ui.add_interaction("Remove Machine", destroy_machine)
	
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed


func _on_energy_area_area_shape_entered(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	var machine : Machine = area.get_parent()
	if not machine is EnergyStation:
		connect_machine(machine)


func _on_energy_area_area_shape_exited(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area != null:
		var machine : Machine = area.get_parent()
		if not machine is EnergyStation:
			disconnect_machine(machine)


func connect_machine(machine:Machine) -> void:
	if machine == null or machine_already_connected(machine):
		return
	
	connected_machines.append(machine)
	machine.connected_energy_sources.append(self)
	
	# If energy station is active, supply energy to machine
	if is_working():
		machine.powered = true


func disconnect_machine(machine:Machine) -> void:
	if machine == null:
		return
	
	connected_machines.erase(machine)
	machine.connected_energy_sources.erase(self)
	
	machine.update_power_supply()
	
func set_energy_area_mesh(act:bool, force_update:bool = false) -> void:
	var size := radius*2
	
	energy_area_plane.visible = act
	
	if (act and energy_area_plane.mesh == null) or force_update:
		var plane_mesh:PlaneMesh = PlaneMesh.new()
		plane_mesh.size = Vector2(size, size)
		
		var shader_mat:ShaderMaterial = ShaderMaterial.new()
		shader_mat.shader = ENERGY_AREA_SHADER
		shader_mat.set_shader_parameter("rad", size)
		
		plane_mesh.material = shader_mat
		energy_area_plane.mesh = plane_mesh
