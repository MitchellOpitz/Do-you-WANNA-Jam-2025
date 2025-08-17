extends Node3D

const EVENT_AREA = preload("res://scenes/event_area.tscn")
const DAMAGE_PARTICLES = preload("res://Resources/damage_particles.tscn")
const DAMAGE_RES = preload("res://Resources/damage_res.tres")

@onready var rng = RandomNumberGenerator.new()
@onready var damage_timer: Timer = $DamageTimer
@onready var damages: Node3D = $Damages
@onready var countdown: Label = $TravelTimer/Label
@onready var travel_timer: Timer = $TravelTimer


var damage_spawn_x = Vector2(-15, 15)
var damage_spawn_y = 1
var damage_spawn_z = Vector2(-15, 15)

func _ready() -> void:
	test_events()
	# Load particles and then kill em.
	for c : GPUParticles3D in $ParticlesToLoad.get_children():
		c.emitting = true

	# It's important to copy any particle created to this node to properly take advantage of loading.
	$ParticlesToLoad.queue_free()


func _process(_delta: float) -> void:
	countdown.text = str(round(travel_timer.time_left))
	if damage_timer.is_stopped():
		damage_timer.wait_time = rng.randi_range(10, 30)
		damage_timer.start()
	if damages.get_child_count() >= 5:
		# Super temporary game over screen.
		$EndScreen/Label.text = "You lose! Too much damage!"
		$EndScreen.show()
		get_tree().paused = true


func _on_event_completed(event_data : EventResource, _node_reference : EventArea) -> void:
	var player_inventory : Dictionary = $Player.inventory
	var item_count = player_inventory.get_or_add(event_data.event_name, 0)
	var new_item_count = min(item_count + 1, event_data.max_quantity)
	player_inventory[event_data.event_name] = new_item_count
	$Player.update_inventory(event_data.inventory_sprite)


func _on_damage_completed_interaction(_event_data : EventResource, node_reference : EventArea) -> void:
	node_reference.queue_free()
	$Player.update_inventory()


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


func _on_travel_timer_timeout() -> void:
	# super temporary game over screen.
	$EndScreen/Label.text = "You win! Yo ho ho!"
	$EndScreen.show()
	get_tree().paused = true


func _on_damage_timer_timeout() -> void:
	# Where we spawn new damage
	var new_damage = EVENT_AREA.instantiate()
	new_damage.event_data = DAMAGE_RES
	new_damage.completed_interaction.connect(_on_damage_completed_interaction)
	var new_particles = DAMAGE_PARTICLES.instantiate()
	new_damage.add_child(new_particles)
	
	#pick random position
	var rand_position = Vector3()
	rand_position.x = rng.randf_range(damage_spawn_x.x, damage_spawn_x.y)
	rand_position.y = damage_spawn_y
	rand_position.z = rng.randf_range(damage_spawn_z.x, damage_spawn_z.y)
	$Damages.add_child(new_damage)
	new_damage.global_position = rand_position
