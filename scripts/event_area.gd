class_name EventArea extends Node3D

@export var event_data : EventResource

var player_in_area : bool = false
var player_inventory : Dictionary
var holding_interact : bool = false
var active_tween : Tween

signal completed_interaction(event_data : EventResource, node_reference : EventArea)

func _ready() -> void:
	self.add_to_group("Events")

	# Prepare resources
	$Sprite3D.texture = event_data.world_sprite
	$Info.text = event_data.event_name


func _input(event: InputEvent) -> void:
	# if this is the first frame we've pushed interact:
	if player_in_area and event.is_action_pressed("interact") and not holding_interact:
		for b in $Area3D.get_overlapping_bodies():
			if b is Player:
				player_inventory = b.inventory
				break

		# don't complete event if requirements not met.
		if not check_requirements(event_data.event_requirements, player_inventory): 
			return

		if not event_data.use_timer:
			completed_interaction.emit(event_data, self)
			# Emit particles if they exist.
			if self.get_child_count() and self.get_child(0) is GPUParticles3D:
				self.get_child(0).emitting = true
			# Deduct items for successful comparison
			for k in event_data.event_requirements.keys():
				player_inventory[k] -= event_data.event_requirements[k]
			return

		var completion_tween = create_tween()
		active_tween = completion_tween
		active_tween.tween_property($Sprite3D, "modulate", Color("000000"), $CompletionTimer.wait_time)
		holding_interact = true
		$CompletionTimer.start()

	if player_in_area and event.is_action_released("interact") and holding_interact:
		holding_interact = false
		$CompletionTimer.stop()
		if active_tween:
			active_tween.kill()
		var reset_tween = create_tween()
		active_tween = reset_tween
		active_tween.tween_property($Sprite3D, "modulate", Color("ffffff"), 0.5)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		player_in_area = true
		var color_tween = create_tween()
		color_tween.tween_property($Sprite3D, "modulate", Color("82ff86"), 0.5)
		active_tween = color_tween


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		player_in_area = false
		$CompletionTimer.stop()
		var color_tween = create_tween()
		color_tween.tween_property($Sprite3D, "modulate", Color("ffffff"), 0.5)
		active_tween = color_tween


func _on_completion_timer_timeout() -> void:
	completed_interaction.emit(event_data, self)
	# Emit particles if they exist.
	if self.get_child_count() and self.get_child(0) is GPUParticles3D:
		self.get_child(0).emitting = true
	for k in event_data.event_requirements.keys():
		player_inventory[k] -= event_data.event_requirements[k]
	


func check_requirements(required_items : Dictionary, items_given : Dictionary) -> bool:
	if required_items.is_empty(): return true
	# Make comparison
	for k in required_items.keys():
		var player_item_count = items_given.get(k)
		if not player_item_count or required_items[k] > player_item_count:
			$Info.text = "You don't have enough %s!" % k
			$InfoTimer.start()
			return false
	return true
	


func _on_info_timer_timeout() -> void:
	$Info.text = event_data.event_name


func get_inventory_sprite() -> CompressedTexture2D:
	return event_data.inventory_sprite
