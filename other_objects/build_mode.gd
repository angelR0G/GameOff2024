class_name BuildMode extends Node3D

var machine_to_place:Machine
var machine_placed:bool = false
var build_mode_active:bool = false

@onready var camera 		:Camera3D= $Camera3D
@onready var preview_machine: MeshInstance3D = $PreviewMachine
@onready var area_placement : Area3D = $Area3D
@onready var collision_shape : CollisionShape3D = $Area3D/CollisionShape3D
@onready var debug_mesh: MeshInstance3D = $Area3D/MeshInstance3D


signal build_mode_exited

func _ready() -> void:
	camera.current = false

func enter_build_mode(machine:Machine):
	machine_to_place = machine
	camera.current = true
	preview_machine.mesh = machine.get_machine_mesh()
	machine_placed = false
	build_mode_active = true

func exit_build_mode() -> void:
	camera.current = false
	machine_placed = true
	build_mode_active = false
	machine_to_place = null
	build_mode_exited.emit()


func _process(_delta: float) -> void:
	if machine_to_place != null && !machine_placed:
		var mouse_position:Vector2 = get_viewport().get_mouse_position()
		preview_machine.global_position = Vector3(mouse_position.x, 0, mouse_position.y)

func _unhandled_input(event: InputEvent) -> void:
	if build_mode_active:
		if event.is_action_pressed("place"):
			await place_machine_at_position(event.position)
		if event.is_action_pressed("back"):
			exit_build_mode()

func place_machine_at_position(position2D:Vector2) -> bool:
	var from := camera.project_ray_origin(position2D)
	var to := from + camera.project_ray_normal(position2D) * 10000
	var space := get_world_3d().direct_space_state
	var rayQuery := PhysicsRayQueryParameters3D.new()
	rayQuery.from = from
	rayQuery.to = to
	rayQuery.collision_mask = 0x2
	var collision = space.intersect_ray(rayQuery)
	if collision:
		if await check_if_can_be_placed(collision.position):
			var machine :Machine= Player.Instance.machines.remove_machine_by_type(machine_to_place._type)
			# TODO add to the nav mesh region
			get_tree().root.add_child(machine)
			machine.global_position = collision.position
			machine_placed = true
			exit_build_mode()
			return true
		return false
	else:
		return false
	
func check_if_can_be_placed(position:Vector3) -> bool:
	PhysicsServer3D.box_shape_create()
	area_placement.global_position = position
	debug_mesh.mesh = collision_shape.shape.get_debug_mesh()
	await get_tree().physics_frame
	await get_tree().physics_frame
	var bodies := area_placement.get_overlapping_bodies()
	for body:CollisionObject3D in bodies:
		if body.collision_layer == 0x1 && body.collision_layer != 0x2:
			return false
	return true
	
	
