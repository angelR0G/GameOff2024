class_name InteractionsDisplay extends CanvasLayer

const interaction_button := preload("res://ui/interaction_button.tscn")
@onready var interactions_list := $InteractionsList

static var Instance :InteractionsDisplay = null

signal display_closed

func _ready() -> void:
	Instance = self

func add_interaction(text:String, function:Callable, disabled:bool = false) -> void:
	var new_interaction :Button = interaction_button.instantiate()
	interactions_list.add_child(new_interaction)
	
	new_interaction.text = text
	new_interaction.disabled = disabled
	if function.is_valid():
		new_interaction.pressed.connect(function)
	new_interaction.pressed.connect(clear_list)


func hide_list() -> void:
	interactions_list.visible = false

func show_list() -> void:
	interactions_list.visible = true

func clear_list() -> void:
	hide_list()
	for child in interactions_list.get_children():
		child.queue_free()
	
	display_closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if interactions_list.visible and event.is_action_pressed("back"):
		clear_list()
