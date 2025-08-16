extends Control


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/loading_screen.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu/options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
