class_name DevConsole extends CanvasLayer

var expression = Expression.new()

@onready var line_edit = %line_input
@onready var console = %console
@onready var container = $Container

func _ready():
	line_edit.text_submitted.connect(self._on_text_submitted)

func _on_text_submitted(command):
	var error = expression.parse(command)
	if error != OK:
		print(expression.get_error_text())
		return
	var result = expression.execute([], self)
	if not expression.has_execute_failed():
		console.text = str(result)
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("dev_console_open"):
		container.visible=!container.visible
	
