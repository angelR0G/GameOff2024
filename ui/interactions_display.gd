class_name InteractionsDisplay extends CanvasLayer

const INTERACTION_BUTTON := preload("res://ui/interaction_button.tscn")
@onready var interactions_list := $InteractionsList

static var Instance :InteractionsDisplay = null

signal display_closed

func _ready() -> void:
	Instance = self
	interactions_list.visible = false

func add_interaction(text:String, function:Callable, disabled:bool = false) -> void:
	var new_interaction :Button = INTERACTION_BUTTON.instantiate()
	var new_control_node :Control = Control.new()
	
	# Configure control node (button's parent)
	new_control_node.custom_minimum_size = new_interaction.custom_minimum_size
	
	# Add to hierarchy
	interactions_list.add_child(new_control_node)
	new_control_node.add_child(new_interaction)
	
	# Configure interaction button
	new_interaction.text = text
	new_interaction.disabled = disabled
	new_interaction.pressed.connect(func () -> void:
		await clear_list()
		if function.is_valid():
			await function.call()
		display_closed.emit()
	)
	
	# Animate button
	new_interaction.scale = Vector2.ZERO
	var tween := get_tree().create_tween()
	tween.tween_property(new_interaction, "scale", Vector2.ONE, 0.2).set_delay((interactions_list.get_child_count()-1)*0.05).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func add_close_list_button() -> void:
	add_interaction("Close", Callable())

func hide_list() -> void:
	interactions_list.visible = false
	interactions_list.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_list() -> void:
	interactions_list.visible = true
	interactions_list.mouse_filter = Control.MOUSE_FILTER_PASS

func clear_list() -> void:
	var tween := get_tree().create_tween().set_parallel(true)
	for child in interactions_list.get_children():
		var child_button := child.get_child(0)
		tween.tween_property(child_button, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_callback(child.queue_free).set_delay(0.2)
	
	await tween.finished
	hide_list()

func _unhandled_key_input(event: InputEvent) -> void:
	if interactions_list.visible and event.is_action_pressed("back"):
		await clear_list()
		display_closed.emit()
