class_name MaterialIcon extends AspectRatioContainer

const NORMAL_BACKGROUND = preload("res://resources/material_icon_background.tres")
const HIGHLIGHT_BACKGROUND = preload("res://resources/material_icon_highlight.tres")

@onready var background := $Background
@onready var sprite := $Background/Control/MarginContainer/MaterialSprite
@onready var label := $Background/Control/MarginContainer2/Label
var id :int = -1

func set_sprite(texture:Texture2D) -> void:
	sprite.texture = texture


func set_number(num:int) -> void:
	label.text = str(num)


func set_highlighted(new_state:bool) -> void:
	background.add_theme_stylebox_override("panel", HIGHLIGHT_BACKGROUND if new_state else NORMAL_BACKGROUND)
