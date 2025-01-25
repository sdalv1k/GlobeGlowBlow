extends CharacterBody3D

var speed = 1.0
const WALK_SPEED = 5.0
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.1

const HEAD_FREQ = 2.0
const HEAD_AMP = 0.06
var head_t = 0.0

@onready var camera_base: Node3D = $CameraBase
@onready var camera_pitch: Node3D = $CameraBase/CameraPitch
@onready var camera: Camera3D = $Head/CameraPitch/Camera3D

@onready var camera_pos = camera_base.global_transform.origin
@onready var camera_relative_pos = camera_pos - self.global_transform.origin

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

signal player_hit

# Orb stuff:
var trow_force:float = 5
var picked_up = null
@onready var collider = $"../orb"
var pickup_cooldown_time = 0
var pickup_cooldown = 0

var mouse_delta = Vector2()
var movement_input = Vector3()
var jump_input = false
var cam_movement = Vector3()

const MIN_Y_ROTATION = -89
const MAX_Y_ROTATION = 89

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	_handle_mouse_input(event)
	_handle_movement_input()
	_handle_mousemode_input(event)
	
func _handle_mouse_input(event):
	if event is InputEventMouseMotion:
		mouse_delta += event.relative
		
func _handle_movement_input():
	movement_input.z = int(Input.is_action_pressed("up")) - int(Input.is_action_pressed("down"))
	movement_input.x = int(Input.is_action_pressed("left")) - int(Input.is_action_pressed("right"))
	jump_input = Input.is_action_pressed("jump")
	
	movement_input = movement_input.normalized()
	
func _handle_mousemode_input(event):
	if event.is_action_pressed('toggle_mousemode'):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#camera_base.rotate_y(-event.relative.x * SENSITIVITY)
		#camera_base.rotate_x(event.relative.y * SENSITIVITY)
		## camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))
		#camera_pitch.rotation_degrees.x = clamp(camera_pitch.rotation_degrees.x, MIN_Y_ROTATION, MAX_Y_ROTATION)

func _physics_process(delta: float) -> void:
	if !picked_up && pickup_cooldown >= 0:
		pickup_cooldown -= delta
		if pickup_cooldown < 0:
			pickup_cooldown = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (camera_base.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Camera
	_handle_camera_rotation(delta)
	_handle_movement(delta)
	_handle_body_rotation(delta)
	
	camera_base.global_transform.origin = self.global_transform.origin + camera_relative_pos.rotated(Vector3.UP, self.global_transform.basis.get_euler().y)

	#if is_on_floor():
		#if direction:
			#velocity.x = direction.x * speed
			#velocity.z = direction.z * speed
		#else:
			#velocity.x = move_toward(velocity.x, direction.x * speed, 20.0 * delta)
			#velocity.z = move_toward(velocity.z, direction.z * speed, 20.0 * delta)
	#else:
		#velocity.x = move_toward(velocity.x, direction.x * speed, 8.0 * delta)
		#velocity.z = move_toward(velocity.z, direction.z * speed, 8.0 * delta)

	# Head Shake
	
	
	#head_t += velocity.length() * float(is_on_floor()) * delta
	#camera.transform.origin = _headshake(head_t)
#
	## FOV
	#var velocity_clamped = clamp(velocity.length(), 0.5, RUN_SPEED * 4)
	#var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	#camera.fov = lerp(camera.fov, target_fov, 8.0 * delta)
	
	# Orb stuff:
	
	
	if Input.is_action_just_pressed("throw"):
		pickup_cooldown = pickup_cooldown_time
		if !picked_up: return
		picked_up.let_go(-$Head/Camera3D/hand3d/Pivot.global_transform.basis.z * trow_force)
		picked_up = null

func _handle_body_rotation(delta):
	var cam_basis = camera_base.global_transform.basis
	var body_basis = self.global_transform.basis
	
	var signed_angle = acos(body_basis.x.dot(cam_basis.z))
	var threshold = 35
	
	var move_basis = Basis(Vector3.UP.cross(cam_movement), Vector3.UP, cam_movement).orthonormalized()
	var angle = acos(clamp(cam_basis.z.dot(move_basis.z), -1, 1))
	
	if signed_angle > deg_to_rad(90+threshold):
		var amt = -(signed_angle - deg_to_rad(90+threshold))
		self.rotation.y = lerp_angle(self.rotation.y, self.rotation.y+amt, 5*delta)
	elif signed_angle < deg_to_rad(90-threshold):
		var amt = -(signed_angle - deg_to_rad(90-threshold))
		self.rotation.y = lerp_angle(self.rotation.y, self.rotation.y+amt, 5*delta)
		
	if velocity:
		if angle < deg_to_rad(60):
			self.global_transform.basis = self.global_transform.basis.slerp(move_basis, 5*delta)
		else:
			pass

func _handle_camera_rotation(delta):
	camera_base.rotate_y(-mouse_delta.x * SENSITIVITY * delta)
	camera_pitch.rotate_x(-mouse_delta.y * SENSITIVITY * delta)
	camera_pitch.rotation_degrees.x = clamp(camera_pitch.rotation_degrees.x, MIN_Y_ROTATION, MAX_Y_ROTATION)
	mouse_delta = Vector2()

func _handle_movement(delta):
	var cam_forward = camera_base.global_transform.basis.z
	var cam_right = camera_base.global_transform.basis.x
	var is_grounded = is_on_floor()
	
	cam_movement = (movement_input.x * cam_right + movement_input.z * cam_forward)
	
	velocity.x = -cam_movement.x * speed
	velocity.z = -cam_movement.z * speed
	
	if not is_grounded:
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED
		
	move_and_slide()
	
func _headshake(t: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(t * HEAD_FREQ) * HEAD_AMP
	pos.x = cos(t * HEAD_FREQ * 0.5) * HEAD_AMP
	return pos
	
func hit():
	emit_signal("player_hit")


func pickup_orb():
	print("ENTERED")
	if picked_up: return
	if pickup_cooldown > 0: return
	elif collider.has_method("pick_up"):
		collider.pick_up($Head/Camera3D/hand3d/Pivot)
		picked_up = collider
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	pickup_orb()
	pass # Replace with function body.
