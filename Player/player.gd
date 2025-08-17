# class_name makes Player available for type checking.
class_name Player extends CharacterBody3D

const JUMP_VELOCITY = 4.5

@export var sprint_mult : float = 2.5
@export var look_sensitivity : float = 0.5
@export var max_y_look : float = -90.0
@export var min_y_look : float = 45.0

var inventory : Dictionary
var speed : float = 5.0
var sprinting : bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	#TODO Add controller support
	if event is InputEventMouseMotion:
		#rotate player left/right based on mouse's x movement.
		self.rotate_y(deg_to_rad(- event.relative.x * look_sensitivity))
		#rotate player's head up/down based on mouse's y movement.
		$HeadControl.rotate_x(deg_to_rad(- event.relative.y * look_sensitivity))
		$HeadControl.rotation.x = clamp($HeadControl.rotation.x, deg_to_rad(max_y_look), deg_to_rad(min_y_look))
	if event.is_action_pressed("sprint") and not sprinting:
		sprinting = true
	if event.is_action_released("sprint") and sprinting:
		sprinting = false


# pretty much everything in here is the default script for player controller. All I've added is the basics to a 3rd person controller.
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed if not sprinting else direction.x * (speed * sprint_mult)
		velocity.z = direction.z * speed if not sprinting else direction.z * (speed * sprint_mult)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# swap mouse mode when escape is pressed
	if Input.is_action_just_pressed("cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	move_and_slide()


func update_inventory(item_to_display : CompressedTexture2D = null) -> void:
	for k in inventory.keys():
		# if we have some but don't have a display.
		var ui_texture = $UI/HBox.find_child(k, true, false)
		if not ui_texture:
			if not inventory[k]:
				return
			var new_texture = TextureRect.new()
			var new_label = Label.new()
			new_texture.texture = item_to_display
			new_texture.name = k
			
			new_label.text = str(inventory[k])
			$UI/HBox.add_child(new_texture)
			new_texture.add_child(new_label)
		else:
			ui_texture.get_child(0).text = str(inventory[k])
			if not inventory[k]:
					ui_texture.queue_free()
