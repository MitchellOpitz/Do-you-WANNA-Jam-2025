# class_name makes Player available for type checking.
class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var look_sensitivity : float = 0.5
@export var max_y_look : float = -90.0
@export var min_y_look : float = 45.0

var inventory : Dictionary

# functions with a leading underscore are virtual methods called by the engine.
func _ready() -> void:
	# similar to what an _init function would do, but is called after the scenetree has fully loaded the instance.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _input(event: InputEvent) -> void:
	# most actions that don't require input checking every frame should be called here.
	# for example camera movement is here because it doesn't need to be frame perfect.
	# but inputs for moving the player are better in _physics_process()
	#TODO Add controller support
	if event is InputEventMouseMotion:
		#rotate player left/right based on mouse's x movement.
		self.rotate_y(deg_to_rad(- event.relative.x * look_sensitivity))
		#rotate player's head up/down based on mouse's y movement.
		$HeadControl.rotate_x(deg_to_rad(- event.relative.y * look_sensitivity))
		$HeadControl.rotation.x = clamp($HeadControl.rotation.x, deg_to_rad(max_y_look), deg_to_rad(min_y_look))


# pretty much everything in here is the default script for player controller. All I've added is the basics to a 3rd person controller.
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Godot expects this kind of input checking for frame perfect actions.
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	# swap mouse mode when escape is pressed
	if Input.is_action_just_pressed("cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	move_and_slide()
	
	# Things not related to movement
	$DebugInventory.text = str(inventory)
