extends Node3D

# format is event_name : {max_quantity : int, item_ref : resource or node3d, but is a string for now
# (optional, not used yet but might be nice for instantiating.) requirements : {x_resource : int}}
var item_dicts : Dictionary = {
	"honey" : {"max_quantity" : 3, "item_reference" : "honey_resource"},
	"gum" : {"max_quantity" : 5, "item_reference" : "gum_resource"},
	"fabric" : {"max_quantity" : 1, "item_reference" : "fabric_resource"},
	"patch" : {"max_quantity" : 1, "item_reference" : "patch_resource", "requirements": {
		"fabric_resource" : 1, "gum_resource" : 3, "honey_resource" : 2}},
}

func _ready() -> void:
	test_events()
	prepare_loading()


func _on_event_completed(event_name : String, current_event : EventArea) -> void:
	var player_inventory : Dictionary = $Player.inventory
	var item_count = player_inventory.get_or_add(item_dicts[event_name].item_reference, 0)
	var new_item_count = min(item_count + 1, item_dicts[event_name]["max_quantity"])
	player_inventory[item_dicts[event_name].item_reference] = new_item_count


func _on_damage_completed_interaction(event_name: String, current_event : EventArea) -> void:
	current_event.queue_free()


func test_events():
	# Ensures functionality for adding events.
	for c in get_tree().get_nodes_in_group("Events"):
		if c is EventArea:
			if not c.completed_interaction.get_connections():
				push_warning(c.name + " completed_interaction signal is not connected to the world.gd _on_event_completed")
			if c.event_name:
				if c.event_name.is_empty():
					push_warning(c.name + " is an empty string. This could cause an error.")
				elif c.event_name not in item_dicts:
					push_warning(str(c.get_path()) + " " +  c.event_name + " is not a known item. Check that it has a key in world.gd item_dicts.")
				if c.event_requirements:
					if c.event_name in c.event_requirements:
						push_warning(str(c.get_path()) + " " + c.event_name + " is required to get " + c.event_name + ". Make sure this can still be collected.")
					for key in c.event_requirements.keys():
						if c.event_requirements[key] == 0:
							push_warning(str(c.get_path()) + " " + key + " requires 0. Double check this.")


func prepare_loading() -> void:
	Global.load_particles($LoadingScreen/VBoxContainer/Label, $LoadingScreen/VBoxContainer/ProgressBar)
