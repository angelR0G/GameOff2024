class_name InteractionCollider extends Area3D

var interaction_function :Callable

signal on_stop_interaction

func _on_body_entered(body: Node3D) -> void:
	if body == Player.Instance:
		Player.Instance.add_interaction_object(self)

func _on_body_exited(body: Node3D) -> void:
	if body == Player.Instance:
		Player.Instance.remove_interaction_object(self)

func interact() -> void:
	if interaction_function.is_null():
		return
	
	await interaction_function.call()
	on_stop_interaction.emit()
