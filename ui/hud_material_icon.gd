class_name HudMatIcon extends Container

@onready var texture_rect: TextureRect = $MarginContainer/HudMaterialIcon/TextureRect
@onready var label: Label = $MarginContainer/HudMaterialIcon/Label

func set_texture(texture :Texture2D) -> void:
	texture_rect.texture = texture


func set_quantity(quantity:int) -> void:
	if quantity > 1000000:
		label.text = str(quantity/1000000.0).pad_decimals(1) + "M"
	elif quantity > 10000:
		label.text = str(quantity/1000.0).pad_decimals(1) + "K"
	else:
		label.text = str(quantity)
