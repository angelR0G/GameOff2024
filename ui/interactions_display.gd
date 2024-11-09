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
	new_interaction.pressed.connect(func () -> void:
		clear_list()
		if function.is_valid():
			await function.call()
		display_closed.emit()
	)

func add_close_list_button() -> void:
	add_interaction("Close", Callable())

func hide_list() -> void:
	interactions_list.visible = false
	interactions_list.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_list() -> void:
	interactions_list.visible = true
	interactions_list.mouse_filter = Control.MOUSE_FILTER_PASS

func clear_list() -> void:
	hide_list()
	for child in interactions_list.get_children():
		child.queue_free()
	

func _unhandled_input(event: InputEvent) -> void:
	if interactions_list.visible and event.is_action_pressed("back"):
		clear_list()
