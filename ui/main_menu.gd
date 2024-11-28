class_name MainMenu extends CanvasLayer

const MAIN_MAP = preload("res://other_objects/main_map.tscn")

static var Instance :MainMenu = null

@onready var anim: AnimationPlayer = $AnimationPlayer

var game_instance :Node3D = null
var is_menu_open :bool = false
var restore_progress :bool = true

func _ready() -> void:
	Instance = self
	open_menu(false)


func start_game() -> void:
	if restore_progress and game_instance != null:
		game_instance.free()
		game_instance = null
	
	if game_instance == null:
		restore_progress = false
		game_instance = MAIN_MAP.instantiate()
		get_tree().root.add_child(game_instance)
	
	anim.play_backwards("quick_fade_in")
	await anim.animation_finished
	
	get_tree().paused = false
	is_menu_open = false


func open_menu(play_quick_fade:bool = true) -> void:
	if is_menu_open:
		return
	
	get_tree().paused = true
	anim.play("quick_fade_in" if play_quick_fade else "start_screen")
	is_menu_open = true


func exit_game() -> void:
	get_tree().quit()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("main_menu"):
		if not is_menu_open:
			open_menu()
