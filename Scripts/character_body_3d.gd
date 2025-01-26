extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

const HEAD_FREQ = 2.0
const HEAD_AMP = 0.06
var head_t = 0.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

signal player_hit

# Orb stuff:
var trow_force:float = 5
var picked_up = null
@onready var collider = $"../orb"
var pickup_cooldown_time = 0
var pickup_cooldown = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	#SimpleGrass.set_player_position(global_position)
	if !picked_up && pickup_cooldown >= 0:
		pickup_cooldown -= delta
		if pickup_cooldown < 0:
			pickup_cooldown = 0
	#print(pickup_cooldown) 
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, direction.x * speed, 20.0 * delta)
			velocity.z = move_toward(velocity.z, direction.z * speed, 20.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, direction.x * speed, 8.0 * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, 8.0 * delta)

	# Head Shake
	head_t += velocity.length() * float(is_on_floor()) * delta
	camera.transform.origin = _headshake(head_t)

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, RUN_SPEED * 4)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, 8.0 * delta)

	move_and_slide()
	
	# Orb stuff:
	
	
	if Input.is_action_just_pressed("throw"):
		pickup_cooldown = pickup_cooldown_time
		if !picked_up: return
		picked_up.let_go(-$Head/Camera3D/hand3d/Pivot.global_transform.basis.z * trow_force)
		picked_up = null
		
		
		
	

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
