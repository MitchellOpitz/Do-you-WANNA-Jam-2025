extends Control

var scene_name : StringName = "res://scenes/world.tscn"
var progress : Array

func _ready() -> void:
	ResourceLoader.load_threaded_request(scene_name)


func _process(_delta: float) -> void:
	if ResourceLoader.load_threaded_get_status(scene_name) == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_name))
	$VBoxContainer/Label.text = "Loading Particles... "
	ResourceLoader.load_threaded_get_status(scene_name, progress)
	$VBoxContainer/ProgressBar.value = progress[0] * 100
