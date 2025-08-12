class_name EventArea extends Node3D

@export var use_timer : bool = true
@export var event_name : String
@export var event_requirements : Dictionary

var player_in_area : bool = false
var holding_interact : bool = false
var active_tween : Tween

signal completed_interaction(event_name : String)

func _ready() -> void:
	self.add_to_group("Events")

func _input(event: InputEvent) -> void:
	# if this is the first frame we've pushed interact:
	if player_in_area and event.is_action_pressed("interact") and not holding_interact:
		var player_inventory : Dictionary
		for b in $Area3D.get_overlapping_bodies():
			if b is Player:
				player_inventory = b.inventory
				break
		if not use_timer:
			if check_requirements(event_requirements, player_inventory):
				completed_interaction.emit(event_name)
			return
		# get reference to player inventory.
		check_requirements(event_requirements, player_inventory)
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


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		player_in_area = false
		$CompletionTimer.stop()
		var color_tween = create_tween()
		color_tween.tween_property($Sprite3D, "modulate", Color("ffffff"), 0.5)


func _on_completion_timer_timeout() -> void:
	# very temporary. Remove self after completing interaction
	completed_interaction.emit(event_name)
	self.queue_free()


func check_requirements(required_items : Dictionary, items_given : Dictionary) -> bool:
	print("comparing ", required_items, " to ", items_given)
	if required_items.is_empty(): return true
	for k in required_items.keys():
		var player_item_count = items_given.get(k)
		if not player_item_count or required_items[k] > player_item_count:
			return false
	return true
	
