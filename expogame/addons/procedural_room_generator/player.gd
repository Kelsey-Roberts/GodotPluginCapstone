extends CharacterBody3D

var speed: float
const WALK_SPEED = 4.0
const CROUCH_SPEED = 1.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005
const ACCELERATION = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head_target: Node3D = $"../headTarget"
@onready var camera_target: Node3D = $"../headTarget/cameraTarget"
@onready var actual_head: Node3D = $"../actualHead"
@onready var actual_camera: Camera3D = $"../actualHead/actualCamera"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# print("Current Camera: ", get_viewport().get_camera_3d())

#func _process(delta: float) -> void:
	# print("My Position: ", global_transform.origin)
	# print("IsOnFloor: ", is_on_floor())
	# print("velocity.y: ", velocity.y)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head_target.rotate_y(-event.relative.x * SENSITIVITY)
		camera_target.rotate_x(-event.relative.y * SENSITIVITY)
		camera_target.rotation.x = clamp(camera_target.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		# print("InputEventMouseMotion")
func _physics_process(delta):
	# Get controller look input
	var look_x = Input.get_axis("LOOK_LEFT", "LOOK_RIGHT")  # Right Stick X
	var look_y = Input.get_axis("LOOK_UP", "LOOK_DOWN")  # Right Stick Y

	# print("look_x : look_y: ", look_x, " , ", look_y)

	# Apply right stick movement for looking around
	if look_x or look_y:
		head_target.rotate_y(-look_x * SENSITIVITY * 10)
		camera_target.rotate_x(-look_y * SENSITIVITY * 10)
		camera_target.rotation.x = clamp(camera_target.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
	actual_head.position.x = lerp(actual_head.position.x, position.x, ACCELERATION * 5 * delta)
	actual_head.position.z = lerp(actual_head.position.z, position.z, ACCELERATION * 5 * delta)
	actual_camera.rotation.x = lerp_angle(actual_camera.rotation.x, camera_target.rotation.x, ACCELERATION * 3 * delta)
	actual_head.rotation.y = lerp_angle(actual_head.rotation.y, head_target.rotation.y, ACCELERATION * 3 * delta)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("JUMP") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# print("Jump")
	
	if Input.is_action_pressed("CROUCH"):
		speed = CROUCH_SPEED
		actual_head.position.y = lerp(actual_head.position.y, position.y - 0.5, delta * ACCELERATION * 4)
		# print("Crouch")
	elif Input.is_action_pressed("SPRINT"):
		speed = SPRINT_SPEED
		actual_head.position.y = lerp(actual_head.position.y, position.y, delta * ACCELERATION * 4)
		# print("Sprint")
	else:
		speed = WALK_SPEED
		actual_head.position.y = lerp(actual_head.position.y, position.y, delta * ACCELERATION * 4)
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("LEFT", "RIGHT", "FORWARD", "BACKWARD")
	var direction = (actual_head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, ACCELERATION * delta * 2)
			velocity.z = lerp(velocity.z, direction.z * speed, ACCELERATION * delta * 2)
			# print("Moving")
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, ACCELERATION * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, ACCELERATION * delta * 0.5)
		velocity.z = lerp(velocity.z, direction.z * speed, ACCELERATION * delta * 0.5)

	move_and_slide()
