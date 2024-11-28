class_name Credits extends CanvasLayer

const DISPLAY_VISIBLE_TIME := 5.0
const TRANSITION_TIME := 1.0
@onready var credits_container: MarginContainer = $MarginContainer

func _ready() -> void:
	visible = false
	for child in credits_container.get_children():
		child.visible = false
		child.modulate = Color.TRANSPARENT

func display_credits() -> void:
	if credits_container.get_child_count() == 0:
		return
	
	visible = true
	var tween := get_tree().create_tween()
	
	for index:int in credits_container.get_child_count():
		if index > 0:
			var previous_display := credits_container.get_child(index-1)
			tween.tween_property(previous_display, "modulate", Color.TRANSPARENT, TRANSITION_TIME).set_delay(DISPLAY_VISIBLE_TIME)
			tween.tween_callback(previous_display.set_visible.bind(false))
		
		var next_display := credits_container.get_child(index)
		tween.tween_callback(next_display.set_visible.bind(true))
		tween.tween_property(next_display, "modulate", Color.WHITE, TRANSITION_TIME)
	
	var last_display := credits_container.get_child(-1)
	tween.tween_property(last_display, "modulate", Color.TRANSPARENT, TRANSITION_TIME).set_delay(DISPLAY_VISIBLE_TIME)
	tween.tween_callback(last_display.set_visible.bind(false))
	
	await tween.finished
	visible = false
