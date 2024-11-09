class_name BuildMode extends Node3D

var machine_to_place:Machine
var machine_placed:bool = false

@onready var preview_machine: MeshInstance3D = $PreviewMachine

func enter_build_mode(machine:Machine):
	machine_to_place = machine
	preview_machine.mesh = machine.get_machine_mesh()
	machine_placed = false


func _process(_delta: float) -> void:
	if machine_to_place != null && !machine_placed:
		var mouse_position:Vector2 = get_viewport().get_mouse_position()
		preview_machine.global_position = Vector3(mouse_position.x, 0, mouse_position.y)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		place_machine_at_position(event.position)
		
		
func place_machine_at_position(position:Vector2) -> bool:
	machine_placed = true
	machine_to_place.global_position = Vector3(position.x, 0, position.y)
	return true
	
