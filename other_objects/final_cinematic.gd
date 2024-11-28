class_name FinalCinematic extends AnimationPlayer

static var Instance :FinalCinematic = null

func _ready() -> void:
	Instance = self

func play_cinematic() -> void:
	Engine.time_scale = 1.0
	
	var menu := MainMenu.Instance
	var player := Player.Instance
	
	menu.process_mode = Node.PROCESS_MODE_DISABLED
	player.input_disabled = true
	player.hud.visible = false
	
	play("cinematic")
	
	await animation_finished
	
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	menu.restore_progress = true
	menu.open_menu(false)
