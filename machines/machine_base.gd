class_name Machine extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer

enum Type {
	Drill,
	Generator,
	EnergyStation,
	EnergyExtender,
	ExplorerDroneStation,
	CollectorDroneStation,
	TransportDroneStation,
	Disruptor,
}

@warning_ignore("unused_private_class_variable")
var _type :Type
var machine_name :StringName
var description :String
var energy_cost :int = 0
var active :bool = false : set = set_machine_active
var powered:bool = false : set = set_machine_powered
var can_be_placed_on_world :bool = true
var place_instructions :String = ""
var build_cost :Dictionary = {}


func is_working() -> bool:
	return active and powered


func set_machine_powered(new_state:bool) -> void:
	if powered != new_state:
		powered = new_state
		_check_machine_new_state(new_state)


func display_interactions() -> void:
	var interactions_ui := InteractionsDisplay.Instance
	
	if active:
		interactions_ui.add_interaction("Turn Off", set_machine_active.bind(false))
	else:
		interactions_ui.add_interaction("Turn On", set_machine_active.bind(true))


func set_machine_active(new_state:bool) -> void:
	if active != new_state:
		active = new_state
		_check_machine_new_state(new_state)


func get_machine_mesh() -> Mesh:
	return get_child(0).mesh


# Check power and active state when they change and emit signals when starts or stops working
func _check_machine_new_state(is_being_activated:bool) -> void:
	if is_being_activated:
		if active and powered:
			_on_start_working()
	else:
		if active != powered:
			_on_stop_working()

# Should be overridden
func _on_start_working() -> void:
	anim.play("working")

func _on_stop_working() -> void:
	anim.stop()
