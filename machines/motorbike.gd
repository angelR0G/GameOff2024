class_name Motorbike extends CharacterBody3D

const ROTATION_SPEED := 4.0
const ACCELERATION := 10.0
const STOP_ACCELERATION := 50.0
const MAX_SPEED := 32.0

@onready var interaction: InteractionCollider = $InteractionTrigger

var player_riding :Player = null
var movement_vector :Vector3 = Vector3.ZERO
var speed :float = 0


func _ready() -> void:
	interaction.interaction_function = _interaction

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
	
	if player_riding != null:
		player_riding.global_position = global_position + Vector3.UP * 2
	#anim.play("walking" if velocity.length() > 0.1 else "idle")


func calculate_horizontal_speed(delta) -> Vector2:
	if player_riding == null:
		return Vector2.ZERO
	
	var dir := Vector3()
	if player_riding.movement_enabled and not player_riding.input_disabled:
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
		var target_rot := Vector3.FORWARD.rotated(Vector3.UP, rotation.y).signed_angle_to(Vector3(dir.x, 0, dir.z), Vector3.UP)
		var angular_speed :float = minf(ROTATION_SPEED * delta, abs(target_rot)) * sign(target_rot)
		rotate_y(angular_speed)
		dir = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
		return Vector2(dir.x, dir.z)
	
	return Vector2.ZERO


func update_movement_vector() -> void:
	# Set the movement direction to the direction it is facing
	var target_direction := Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	movement_vector.x = target_direction.x * speed
	movement_vector.z = target_direction.z * speed


func accelerate(delta:float) -> void:
	speed = minf(speed + ACCELERATION * delta, MAX_SPEED)

func slow_down(delta:float) -> void:
	speed = maxf(0.0, speed - STOP_ACCELERATION * delta)


func update_gravity(delta:float) -> void:
	movement_vector.y = 0 if is_on_floor() else movement_vector.y - (9.8 * delta)


func _interaction() -> void:
	var interactions_ui := InteractionsDisplay.Instance
	
	interactions_ui.add_interaction("Ride Motorbike", func() -> void:
		var player := Player.Instance
		player.visible = false
		player_riding = player)
		
	
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	await interactions_ui.display_closed
