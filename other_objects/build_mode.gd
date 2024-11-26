class_name BuildMode extends Node3D

const BUILD_SAFE_RADIUS := 8.0

var machine_to_place:Machine
var machine_placed:bool = false
var build_mode_active:bool = false
var movement_enabled:bool = false

var navigation_reference:NavigationRegion3D = null : set = _set_nav_reference
var navmesh_update_required :bool = false

@export var speed :float = 0.5
@export var distance_from_player:float = 30.0

@onready var preview_machine: MeshInstance3D = $PreviewMachine
@onready var area_placement : Area3D = $Area3D
@onready var collision_shape : CollisionShape3D = $Area3D/CollisionShape3D
@onready var debug_mesh: MeshInstance3D = $Area3D/MeshInstance3D
@onready var build_mode_border: AspectRatioContainer = $AspectRatioContainer
@onready var action_radius_mesh : MeshInstance3D = $ActionRadiusMesh
@onready var camera_target: Node3D = $CameraTarget


signal build_mode_exited(machine_placed:bool)

func _ready() -> void:
	pass

func enter_build_mode(machine:Machine):
	machine_to_place = machine
	preview_machine.mesh = machine.get_machine_mesh().duplicate()
	machine_placed = false
	build_mode_border.visible = true
	build_mode_active = true
	movement_enabled = true
	Player.Instance.movement_enabled = false
	camera_target.transform = Player.Instance.transform
	FollowCamera.Instance.set_target(camera_target)
	
	# Set action radius mesh to the correct size
	action_radius_mesh.visible = true
	var plane_mesh:PlaneMesh =  action_radius_mesh.mesh
	plane_mesh.size = Vector2(machine.radius*2, machine.radius*2)
	
	#Pass to the shader the radius
	var action_radius_shader :ShaderMaterial = action_radius_mesh.get_active_material(0)
	action_radius_shader.set_shader_parameter("rad", machine.radius*2)

func exit_build_mode() -> void:
	preview_machine.mesh = null
	build_mode_active = false
	movement_enabled = true
	machine_to_place = null
	Player.Instance.movement_enabled = true
	build_mode_border.visible = false
	action_radius_mesh.visible = false
	FollowCamera.Instance.set_target(Player.Instance)
	build_mode_exited.emit(machine_placed)


func _set_nav_reference(new_nav_region:NavigationRegion3D) -> void:
	if navigation_reference != null:
		if navigation_reference.bake_finished.is_connected(update_navmesh):
			navigation_reference.bake_finished.disconnect(update_navmesh)
	
	navigation_reference = new_nav_region
	
	if navigation_reference != null:
		navigation_reference.bake_finished.connect(update_navmesh)


func _process(_delta: float) -> void:
	if machine_to_place != null && !machine_placed:
		# Place preview machine at the mouse position
		var mouse_position:Vector2 = get_viewport().get_mouse_position()
		var ground_depth:Array = get_ground_position(mouse_position)
		if ground_depth[0]:
			preview_machine.global_position = ground_depth[1]
			action_radius_mesh.global_position = Vector3(ground_depth[1].x, ground_depth[1].y+0.2, ground_depth[1].z)
			# Check if the machine can be place at the current position
			var material :ShaderMaterial = preview_machine.material_override
			var can_place :bool = await check_if_can_be_placed(ground_depth[1])
			material.set_shader_parameter("can_place",can_place)
			
	var dir := Vector3()
	
	if movement_enabled:
		if Input.is_action_pressed("left"):
			dir.x -= 1.0
		if Input.is_action_pressed("right"):
			dir.x += 1.0
		if Input.is_action_pressed("up"):
			dir.z -= 1.0
		if Input.is_action_pressed("down"):
			dir.z += 1.0
		dir = dir.normalized()


		# Get movement direction and move camera target with the input
		# Limit camera movement from the player
		var target_velocity:= Vector3()
		target_velocity.x = dir.x*speed
		target_velocity.z = dir.z*speed
		var camera_rot := FollowCamera.Instance.get_camera_rotation()
		target_velocity = target_velocity.rotated(Vector3.UP, camera_rot)
		var player_pos = Player.Instance.position
		var new_pos:=camera_target.position + target_velocity
		var difference := Vector3(abs(player_pos.x - new_pos.x), player_pos.y, abs(player_pos.z - new_pos.z))
		if difference.x < distance_from_player && difference.z < distance_from_player :
			camera_target.position+=target_velocity

func _unhandled_input(event: InputEvent) -> void:
	if build_mode_active:
		if event.is_action_pressed("place"):
			await place_machine_at_position(event.position)
		if event.is_action_pressed("back"):
			exit_build_mode()

func get_ground_position(position2D:Vector2) -> Array:
	var ground_depth_status: Array = [false, preview_machine.position]
	var from :=  FollowCamera.Instance.get_camera().project_ray_origin(position2D)
	var to := from + FollowCamera.Instance.get_camera().project_ray_normal(position2D) * 10000
	var space := get_world_3d().direct_space_state
	var rayQuery := PhysicsRayQueryParameters3D.new()
	rayQuery.from = from
	rayQuery.to = to
	rayQuery.collision_mask = 0x2
	var collision := space.intersect_ray(rayQuery)
	if collision:
		ground_depth_status[0] = true
		ground_depth_status[1] = collision.position
	return ground_depth_status
	

func place_machine_at_position(position2D:Vector2) -> bool:
	var from := FollowCamera.Instance.get_camera().project_ray_origin(position2D)
	var to := from + FollowCamera.Instance.get_camera().project_ray_normal(position2D) * 10000
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
			place_machine(machine, collision.position)
			exit_build_mode()
			return true
		return false
	else:
		return false


func place_machine(machine:Machine, pos:Vector3) -> void:
	navigation_reference.add_child(machine)
	machine.global_position = pos
	update_navmesh(true)
	machine_placed = true


func update_navmesh(force_update :bool = false) -> void:
	await get_tree().create_timer(0.5).timeout
	
	if force_update or navmesh_update_required:
		if not navigation_reference.is_baking():
			navmesh_update_required = false
			navigation_reference.bake_navigation_mesh()
		else:
			navmesh_update_required = true


func check_if_can_be_placed(pos:Vector3) -> bool:
	var bodies := await get_bodies_in_area(pos, BUILD_SAFE_RADIUS)
	#if bodies[0] is GridMap:
		#var tile_pos := Vector3(pos.x/bodies[0].cell_size.x, -2, pos.z/bodies[0].cell_size.z)
		#print( bodies[0].get_cell_item(tile_pos))
		#if bodies[0].get_cell_item(tile_pos) != -1:
			#var grid_items :Array = bodies[0].get_mesh_library().get_item_shapes(bodies[0].get_cell_item(tile_pos))
			#for item in grid_items:
				#var body:BoxShape3D = item
				#if body.collision_layer == 0x1 && body.collision_layer != 0x2:
					#return false
			#return true
		#return false
	var start_loop_range = 0
	if bodies[0] is GridMap:
		start_loop_range = 1
	for num in range(start_loop_range, bodies.size()):
		#var body:CollisionShape3D = bodies[num].get_node("CollisionShape3D")
		var body = bodies[num]
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
