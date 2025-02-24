class_name ContainerManagerUI extends CanvasLayer

const UI_BACK_SOUND = preload("res://assets/sounds/ui_back.mp3")
const UI_ACCEPT_SOUND = preload("res://assets/sounds/ui_accept.mp3")

@onready var player_container: ContainerDisplay = $CenterContainer/Containers/VBoxContainer/ContainerDisplay
@onready var storage_container: ContainerDisplay = $CenterContainer/Containers/VBoxContainer2/ContainerDisplay2
@onready var transfer_buttons: Array[Button] = [
	$CenterContainer/Containers/MarginContainer/VBoxContainer/MoveAllButton,
	$CenterContainer/Containers/MarginContainer/VBoxContainer/MoveHalfButton,
	$CenterContainer/Containers/MarginContainer/VBoxContainer/MoveOneButton,
	]
@onready var close_button: Button = $CenterContainer/Containers/MarginContainer/VBoxContainer/CloseButton
@onready var transfer_direction_icon: TextureRect = $CenterContainer/Containers/MarginContainer/VBoxContainer/TransferDirectionIcon
@onready var audio_player: AudioStreamPlayer = $AudioPlayer

signal request_close

var transfer_from_player :bool = true
var selected_material_id :int = 0

func _ready() -> void:
	set_container_manager_visibility(false)
	player_container.material_selected.connect(_on_material_selected.bind(true))
	storage_container.material_selected.connect(_on_material_selected.bind(false))
	close_button.pressed.connect(func() -> void: request_close.emit())


func open_container_manager(storage:MaterialContainer) -> void:
	if storage == null:
		return
	
	audio_player.set_stream(UI_ACCEPT_SOUND)
	
	player_container.set_container_reference(Player.Instance.materials)
	storage_container.set_container_reference(storage)
	
	disable_transfer_buttons(true)
	
	set_container_manager_visibility(true)
	
	await request_close
	audio_player.set_stream(UI_BACK_SOUND)
	audio_player.play()
	set_container_manager_visibility(false)
	# Deactivate highlight so it is not highlighted next time container is opened
	(player_container if transfer_from_player else storage_container).update_highlighted_icon(null)


func set_container_manager_visibility(new_visibility:bool) -> void:
	visible = new_visibility
	get_child(0).mouse_filter = Control.MOUSE_FILTER_PASS if new_visibility else Control.MOUSE_FILTER_IGNORE


func _on_material_selected(material_id:int, from_player_container:bool) -> void:
	disable_transfer_buttons(false)
	selected_material_id = material_id
	transfer_from_player = from_player_container
	
	transfer_direction_icon.flip_h = from_player_container
	
	# Deactivate highlight in oposite container, just in case a material was selected
	(storage_container if from_player_container else player_container).update_highlighted_icon(null)
	
	audio_player.play()


func disable_transfer_buttons(new_state: bool) -> void:
	for button in transfer_buttons:
		button.disabled = new_state


func transfer_all() -> void:
	var origin_container := player_container if transfer_from_player else storage_container
	var end_container := storage_container if transfer_from_player else player_container
	var material_amount := origin_container.container.get_material_quantity_from_id(selected_material_id)
	
	transfer_materials(origin_container.container, end_container.container, material_amount)


func transfer_half() -> void:
	var origin_container := player_container if transfer_from_player else storage_container
	var end_container := storage_container if transfer_from_player else player_container
	var material_amount := origin_container.container.get_material_quantity_from_id(selected_material_id)
	
	@warning_ignore("integer_division")
	material_amount = material_amount/2 + (0 if material_amount % 2 == 0 else 1)
	
	transfer_materials(origin_container.container, end_container.container, material_amount)

func transfer_one() -> void:
	var origin_container := player_container if transfer_from_player else storage_container
	var end_container := storage_container if transfer_from_player else player_container
	
	transfer_materials(origin_container.container, end_container.container, 1)


func transfer_materials(from_container:MaterialContainer, to_container:MaterialContainer, material_amount:int) -> void:
	if material_amount <= 0 or from_container.get_material_quantity_from_id(selected_material_id) < material_amount:
		return
	
	var transfered_amount := to_container.add_material(selected_material_id, material_amount)
	from_container.remove_material(selected_material_id, transfered_amount)
	
	# Disable transfer buttons if there is not more material in the container
	if from_container.get_material_quantity_from_id(selected_material_id) <= 0:
		disable_transfer_buttons(true)
	
	update_container_manager()
	audio_player.play()


func update_container_manager() -> void:
	if visible:
		player_container.update_display()
		storage_container.update_display()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("back"):
		request_close.emit()
