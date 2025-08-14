extends Node

var particle_array : Array[Node3D]

func load_particles(label : Label, progress : ProgressBar) -> void:
	particle_array.append_array(get_tree().get_nodes_in_group("particles"))
	progress.max_value = particle_array.size()
	for i in particle_array.size():
		label.text = "Loading Particles... " + str(i + 1) + " / " + str(particle_array.size())
		var new = particle_array[i].instantiate()
		self.add_child(new)
		await new.ready
	
