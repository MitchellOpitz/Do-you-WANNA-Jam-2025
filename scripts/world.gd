extends Node3D

func _ready() -> void:
	test_events()
	# Load particles and then kill em.
	for c : GPUParticles3D in $ParticlesToLoad.get_children():
		c.emitting = true

	# It's important to copy any particle created to this node to properly take advantage of loading.
	$ParticlesToLoad.queue_free()


func _on_event_completed(event_data : EventResource, _node_reference : EventArea) -> void:
	var player_inventory : Dictionary = $Player.inventory
	var item_count = player_inventory.get_or_add(event_data.event_name, 0)
	var new_item_count = min(item_count + 1, event_data.max_quantity)
	player_inventory[event_data.event_name] = new_item_count
	$Player.update_inventory(event_data.inventory_sprite)


func _on_damage_completed_interaction(_event_data : EventResource, node_reference : EventArea) -> void:
	node_reference.queue_free()


func test_events():
	# Ensures functionality for adding events.
	for c in get_tree().get_nodes_in_group("Events"):
		if c is EventArea:
			if not c.completed_interaction.get_connections():
				push_warning(c.name + " completed_interaction signal is not connected to the world.gd _on_event_completed")
			if c.event_data.event_name:
				if c.event_data.event_name.is_empty():
					push_warning(c.name + " is an empty string. This could cause an error.")
				#elif c.event_data.event_name not in item_dicts:
					#push_warning(str(c.get_path()) + " " +  c.event_data.event_name + " is not a known item. Check that it has a key in world.gd item_dicts.")
				if c.event_data.event_requirements:
					if c.event_data.event_name in c.event_data.event_requirements:
						push_warning(str(c.get_path()) + " " + c.event_data.event_name + " is required to get " + c.event_data.event_name + ". Make sure this can still be collected.")
					for key in c.event_data.event_requirements.keys():
						if c.event_data.event_requirements[key] == 0:
							push_warning(str(c.get_path()) + " " + key + " requires 0. Double check this.")
