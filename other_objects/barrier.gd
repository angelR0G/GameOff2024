class_name Barrier extends StaticBody3D

const DESTRUCTION_ANIMATION_TIME := 1.7

@onready var interaction: InteractionCollider = $MainPillar/InteractionTrigger
@onready var disruptor_audio: AudioStreamPlayer = $DisruptorAudio

func _ready() -> void:
	interaction.interaction_function = _interaction

func _interaction() -> void:
	var interactions_ui := InteractionsDisplay.Instance
	var player_has_disruptor := Player.Instance.machines.has_machine_of_type(Machine.Type.Disruptor)
	
	interactions_ui.add_interaction("Deactivate Barrier", deactivate_barrier, not player_has_disruptor)
	interactions_ui.add_close_list_button()
	interactions_ui.show_list()
	
	await interactions_ui.display_closed


func deactivate_barrier() -> void:
	# Destroy the disruptor required
	Player.Instance.machines.remove_machine_by_type(Machine.Type.Disruptor).queue_free()
	disruptor_audio.play()
	
	# Destroy barrier walls
	var tween := get_tree().create_tween().set_parallel()
	for child in get_children():
		if child.name.contains("Wall"):
			var mesh :MeshInstance3D = child.get_child(0)
			var audio :AudioStreamPlayer3D = child.get_child(1)
			var final_pos := Vector3(0, -mesh.scale.x, 0)
			
			audio.stop()
			tween.tween_property(mesh, "position", final_pos, DESTRUCTION_ANIMATION_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tween.tween_property(mesh, "scale", Vector3(0, mesh.scale.y, mesh.scale.z), DESTRUCTION_ANIMATION_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tween.tween_callback(child.queue_free).set_delay(DESTRUCTION_ANIMATION_TIME)
		
	tween.tween_callback(BUILDMODE.update_navmesh.bind(true)).set_delay(DESTRUCTION_ANIMATION_TIME)
	interaction.queue_free()
