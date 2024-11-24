class_name ExploreUI extends Control

@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $PanelContainer/CenterContainer/VBoxContainer/ProgressBar
@onready var anim: AnimationPlayer = $AnimationPlayer

var started:bool = false

func _process(_delta: float) -> void:
	if started:
		progress_bar.value = 1 - (timer.time_left/timer.wait_time)


func start_exploration(time:float) -> void:
	timer.start(time)
	anim.play("idle")
	started = true
	
	await timer.timeout
	queue_free()
