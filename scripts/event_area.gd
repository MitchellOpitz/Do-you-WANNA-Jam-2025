class_name EventArea extends Node3D

@export var use_timer : bool = true
@export var event_name : String

var player_in_area : bool = false
var holding_interact : bool = false
var active_tween : Tween

signal completed_interaction(event_name : String)

func _input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact") and not holding_interact:
		if not use_timer:
			# signal game manager to resolve event.
			completed_interaction.emit(event_name)
			return
		holding_interact = true
		$CompletionTimer.start()
		var completion_tween = create_tween()
		active_tween = completion_tween
		active_tween.tween_property($Sprite3D, "modulate", Color("000000"), $CompletionTimer.wait_time)
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


func check_requirements(required_items : Array, items_given : Array) -> void:
	pass
