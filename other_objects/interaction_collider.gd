class_name InteractionCollider extends Area3D

signal on_interact
signal on_stop_interaction

func _on_body_entered(body: Node3D) -> void:
	if body == Player.Instance:
		Player.Instance.add_interaction_object(self)

func _on_body_exited(body: Node3D) -> void:
	if body == Player.Instance:
		Player.Instance.remove_interaction_object(self)
