class_name EnergyStation extends Machine


@export var radius: float
var connected_machines: Array[Machine]

@onready var energy_area:Area3D = $Area3D
@onready var energy_collider:CollisionShape3D = $Area3D/CollisionShape3D

func _init() -> void:
	pass

func _ready() -> void:
	var collider:SphereShape3D = SphereShape3D.new()
	collider.set_radius(radius)
	energy_collider.set_shape(collider)
	var machines := energy_area.get_overlapping_areas()
	for machine in machines:
		connected_machines.append(machine.get_parent())
	return

func connect_machine() -> void:
	pass
	
func disconnect_machine() -> void:
	pass
	
func calculate_energy_cost() -> void:
	pass
