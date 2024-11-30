class_name CheatMode extends Control

@export var action_list :Array[StringName] = []
@export var message :String = "Cheat active" : set = _set_message
var expected_action_index := 0
var enabled := false
var cheat_callback :Callable = Callable()

@onready var correct_input_audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var label: Label = $CenterContainer/Label

func _ready() -> void:
	label.visible = false
	label.text = message


func _set_message(new_message:String) -> void:
	message = new_message
	if label:
		label.text = message


func _unhandled_key_input(event: InputEvent) -> void:
	if action_list.is_empty() or not enabled:
		return
	
	if event.is_pressed():
		if event.is_action_pressed(action_list[expected_action_index]):
			correct_input_pressed()
		else:
			expected_action_index = 0


func correct_input_pressed() -> void:
	if expected_action_index >= action_list.size() - 1:
		expected_action_index = 0
		if cheat_callback.is_valid():
			if not correct_input_audio.playing:
				correct_input_audio.play()
			label.visible = true
			
			cheat_callback.call()
			
			await get_tree().create_timer(3.0).timeout
			label.visible = false
	else:
		expected_action_index += 1
