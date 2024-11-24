class_name Barrier extends StaticBody3D

@onready var interaction: InteractionCollider = $MainPillar/InteractionTrigger

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
	
	# Destroy barrier walls
	for child in get_children():
		if child.name.contains("Wall"):
			child.queue_free()
		
	interaction.queue_free()
