class_name Motorbike extends CharacterBody3D

const ROTATION_SPEED := 4.0
const ACCELERATION := 20.0
const STOP_ACCELERATION := 50.0
const MOTORBIKE_SOUND := preload("res://assets/sounds/motorbike2.wav")
const ENGINE_OFF_SOUND := preload("res://assets/sounds/engine_off.wav")

@onready var interaction: InteractionCollider = $InteractionTrigger
@onready var audio_listener: AudioListener3D = $AudioListener3D
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer

var broken:bool = true
var player_riding :Player = null
var movement_vector :Vector3 = Vector3.ZERO
var speed :float = 0
var max_speed :float = 16.0
var stored_materials := MaterialContainer.new()


func _ready() -> void:
	interaction.interaction_function = _interaction
	stored_materials.max_weight = 200


func _process(delta):
	# Updates speed when velocity changes (for example, a collision)
	speed = Vector2(velocity.x, velocity.z).length()
	
	var horizontal_speed := calculate_horizontal_speed(delta)
	if horizontal_speed.length() > 0:
		accelerate(delta)
	else:
		slow_down(delta)
	
	update_movement_vector()
	
	update_gravity(delta)
	
	# Moves the bike
	velocity = movement_vector
	move_and_slide()
	
	audio_listener.global_position = global_position


func calculate_horizontal_speed(delta) -> Vector2:
	if player_riding == null:
		return Vector2.ZERO
	
	var dir := Vector3()
	#if player_riding.movement_enabled and not player_riding.input_disabled:
	# Check input to get character movement direction
	if Input.is_action_pressed("left"):
		dir.x -= 1.0
	if Input.is_action_pressed("right"):
		dir.x += 1.0
	if Input.is_action_pressed("up"):
		dir.z -= 1.0
	if Input.is_action_pressed("down"):
		dir.z += 1.0
	dir = dir.normalized()
	
	# If it is moving, calculate rotation
	if dir.x != 0 or dir.z != 0:
		# Rotate input direction with camera rotation
		var camera_rot := FollowCamera.Instance.get_camera_rotation()
		dir = dir.rotated(Vector3.UP, camera_rot)
		
		# Calculate object's new rotation trying to match desired movement direction
		var target_rot := Vector3.FORWARD.rotated(Vector3.UP, rotation.y).signed_angle_to(Vector3(dir.x, 0, dir.z), Vector3.UP)
		var angular_speed :float = minf(ROTATION_SPEED * delta, abs(target_rot)) * sign(target_rot)
		rotate_y(angular_speed)
		
		# Gets actual movement direction from object's rotation
		dir = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
		return Vector2(dir.x, dir.z)
	
	return Vector2.ZERO


func update_movement_vector() -> void:
	# Set the movement direction to the direction it is facing
	var target_direction := Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	movement_vector.x = target_direction.x * speed
	movement_vector.z = target_direction.z * speed


func accelerate(delta:float) -> void:
	speed = minf(speed + ACCELERATION * delta, max_speed)

func slow_down(delta:float) -> void:
	speed = maxf(0.0, speed - STOP_ACCELERATION * delta)


func update_gravity(delta:float) -> void:
	movement_vector.y = 0.0 if is_on_floor() else movement_vector.y - (9.8 * delta)


func _unhandled_key_input(event: InputEvent) -> void:
	if player_riding != null and event.is_action_pressed("interact"):
		get_off()


func get_off() -> void:
	player_riding.global_position = global_position + Vector3.RIGHT.rotated(Vector3.UP, rotation.y) * 2
	update_player_riding_state(true)
	player_riding = null


func update_player_riding_state(is_getting_off:bool) -> void:
	player_riding.visible = is_getting_off
	player_riding.enable_collision(is_getting_off)
	player_riding.movement_enabled = is_getting_off
	FollowCamera.Instance.set_target((Player.Instance as Node3D) if is_getting_off else (self as Node3D))
	(player_riding.audio_listener if is_getting_off else audio_listener).make_current()
	audio_player.set_stream(ENGINE_OFF_SOUND if is_getting_off else MOTORBIKE_SOUND)
	audio_player.play()


func _interaction() -> void:
	if broken:
		return
	
	var interactions_ui := InteractionsDisplay.Instance
	
	interactions_ui.add_interaction("Ride Motorbike", func() -> void:
		var player := Player.Instance
		player_riding = player
		update_player_riding_state(false)
	, broken)
	interactions_ui.add_interaction("Open Storage", func()-> void:
		await Player.Instance.container_manager.open_container_manager(stored_materials)
	)
	
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed


func _on_upgrade() -> void:
	stored_materials.max_weight += 200
	max_speed += 3.0
