class_name MaterialIcon extends AspectRatioContainer

@onready var sprite := $Background/Control/MarginContainer/MaterialSprite
@onready var label := $Background/Control/MarginContainer2/Label

func set_sprite(texture:Texture2D) -> void:
	sprite.texture = texture


func set_number(num:int) -> void:
	label.text = str(num)
