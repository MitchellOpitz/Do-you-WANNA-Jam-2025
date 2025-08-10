extends Node3D

# format is item_name (same as event_name) : {max_item, item_ref : resource or node3d, but is a string for now}
var items_for_patch : Dictionary = {
	"honey" : {"max_quantity" : 3, "item_reference" : "honey_resource"},
	"bubblegum" : {"max_quantity" : 5, "item_reference" : "gum_resource"},
	"fabric" : {"max_quantity" : 1, "item_reference" : "fabric_resource"}
}

func _on_event_completed(event_name : String) -> void:
	var player_inventory : Dictionary = $Player.inventory
	var item_count = player_inventory.get_or_add(items_for_patch[event_name].item_reference, 0)
	var new_item_count = min(item_count + 1, items_for_patch[event_name]["max_quantity"])
	player_inventory[items_for_patch[event_name].item_reference] = new_item_count
