class_name BuildMode extends Node3D

var machine_to_place:Machine
var machine_placed:bool = false
var build_mode_active:bool = false

@onready var camera 		:Camera3D= $Camera3D
@onready var preview_machine: MeshInstance3D = $PreviewMachine

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
	build_mode_exited.emit()


func _process(_delta: float) -> void:
	if machine_to_place != null && !machine_placed:
		var mouse_position:Vector2 = get_viewport().get_mouse_position()
		preview_machine.global_position = Vector3(mouse_position.x, 0, mouse_position.y)

func _input(event: InputEvent) -> void:
	if build_mode_active:
		if event is InputEventMouseButton:
			place_machine_at_position(event.position)
		if event.is_action_pressed("back"):
			exit_build_mode()

#TODO: Check if can be placed
func place_machine_at_position(position:Vector2) -> bool:
	machine_placed = true
	var machine :Machine= Player.Instance.machines.remove_machine_by_type(machine_to_place._type)
	get_tree().root.add_child(machine)
	machine_to_place.global_position = Vector3(position.x, 0, position.y)
	exit_build_mode()
	return true
	
