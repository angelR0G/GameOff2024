class_name BuildMode extends Node3D

var machine_to_place:Machine
var machine_placed:bool = false
var build_mode_active:bool = false

@onready var camera 		:Camera3D= $CameraPivot/Camera3D
@onready var preview_machine: MeshInstance3D = $PreviewMachine
@onready var area_placement : Area3D = $Area3D
@onready var collision_shape : CollisionShape3D = $Area3D/CollisionShape3D
@onready var debug_mesh: MeshInstance3D = $Area3D/MeshInstance3D
@onready var build_mode_border: AspectRatioContainer = $AspectRatioContainer
@onready var action_radius_mesh : MeshInstance3D = $ActionRadiusMesh


signal build_mode_exited

func _ready() -> void:
	camera.current = false

func enter_build_mode(machine:Machine):
	machine_to_place = machine
	camera.current = true
	preview_machine.mesh = machine.get_machine_mesh().duplicate()
	machine_placed = false
	build_mode_active = true
	Player.Instance.movement_enabled = false
	build_mode_border.visible = true
	action_radius_mesh.visible = true
	var plane_mesh:PlaneMesh =  action_radius_mesh.mesh
	plane_mesh.size = Vector2(machine.radius*2, machine.radius*2)

func exit_build_mode() -> void:
	preview_machine.mesh = null
	camera.current = false
	machine_placed = true
	build_mode_active = false
	machine_to_place = null
	Player.Instance.movement_enabled = true
	build_mode_border.visible = false
	action_radius_mesh.visible = false
	build_mode_exited.emit()


func _process(_delta: float) -> void:
	if machine_to_place != null && !machine_placed:
		# Place preview machine at the mouse position
		var mouse_position:Vector2 = get_viewport().get_mouse_position()
		var screen_size = get_viewport().size
		var ground_depth:Array = get_ground_position(mouse_position)
		if ground_depth[0]:
			#var new_pos:Vector3 = camera.project_position(mouse_position, ground_depth[1])
			#var position_plane = Vector3(new_pos.x, ground_depth[1], new_pos.z)
			preview_machine.global_position = ground_depth[1]
			action_radius_mesh.global_position = Vector3(ground_depth[1].x, ground_depth[1].y+0.2, ground_depth[1].z)
			# Check if the machine can be place at the current position
			var material :ShaderMaterial = preview_machine.material_override
			var can_place :bool = await check_if_can_be_placed(ground_depth[1])
			material.set_shader_parameter("can_place",can_place)

func _unhandled_input(event: InputEvent) -> void:
	if build_mode_active:
		if event.is_action_pressed("place"):
			await place_machine_at_position(event.position)
		if event.is_action_pressed("back"):
			exit_build_mode()

func get_ground_position(position2D:Vector2) -> Array:
	var ground_depth_status: Array = [false, preview_machine.position]
	var from := camera.project_ray_origin(position2D)
	var to := from + camera.project_ray_normal(position2D) * 10000
	var space := get_world_3d().direct_space_state
	var rayQuery := PhysicsRayQueryParameters3D.new()
	rayQuery.from = from
	rayQuery.to = to
	rayQuery.collision_mask = 0x2
	var collision := space.intersect_ray(rayQuery)
	if collision:
		#print(collision.position)
		ground_depth_status[0] = true
		#ground_depth_status[1] = collision.position.y
		ground_depth_status[1] = collision.position
	return ground_depth_status
	

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


func check_if_can_be_placed(pos:Vector3) -> bool:
	var bodies := await get_bodies_in_area(pos, 5.0)
	for body:CollisionObject3D in bodies:
		if body.collision_layer == 0x1 && body.collision_layer != 0x2:
			return false
	return true


# Returns all bodies inside a sphere of radius "rad" centered in "pos" 
func get_bodies_in_area(pos:Vector3, rad:float = 5.0) -> Array[Node3D]:
	area_placement.global_position = pos
	(collision_shape.shape as SphereShape3D).radius = rad
	await get_tree().physics_frame
	await get_tree().physics_frame
	return area_placement.get_overlapping_bodies()
