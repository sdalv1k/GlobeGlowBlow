extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005
const HIT_STAGGER = 8.0

const HEAD_FREQ = 2.0
const HEAD_AMP = 0.06
var head_t = 0.0

# Audio:
@onready var Stupidblowgoblinsblowingmylawn = $"VoiceLines/Stupid blow goblins blowing my lawn"
@onready var get_off_my_lawn = $"VoiceLines/get off my lawn"
@onready var Ihateyouf___ingglowgoblins = $"VoiceLines/I hate you, f___ing glow goblins"
@onready var Ikillyouglowgoblins = $"VoiceLines/I kill you, glow goblins"
@onready var Goawayglowgoblins = $"VoiceLines/Go away, glow goblins"
@onready var Theseglowgoblinsareruiningmylifeandmylawn = $"VoiceLines/These glow goblins are ruining my life and my lawn"
@onready var I_will_pull_the_Sun_Globe = $"VoiceLines/I will pull the Sun Globe"

var time_to_next_voiceline =6


@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var pivot: Node3D = $Head/Camera3D/player/Armature/Skeleton3D/BoneAttachment3D/Pivot
@onready var animation_tree: AnimationTree = $Head/Camera3D/player/AnimationTree
var trow_force = 5.0

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

signal player_hit

# Orb stuff:
var hold_time = 0.0 # Tracks how long the button is held
var max_hold_time = 2.0 # Max time to charge the throw
var base_throw_force = 2.0 # Minimum throw force
var max_throw_force = 10.0 # Maximum throw force

var picked_up = null
@onready var collider = $"../orb"
var pickup_cooldown_time = 0
var pickup_cooldown = 0
var walking_enabled = true

func disable_walking():
	walking_enabled = false
	
func enable_walking():
	walking_enabled = true

var last_voiceline_idx = 1
func play_random_voiceline():
	var all_voicelines = [Stupidblowgoblinsblowingmylawn, get_off_my_lawn,
Ihateyouf___ingglowgoblins, Ikillyouglowgoblins, Goawayglowgoblins, Theseglowgoblinsareruiningmylifeandmylawn, I_will_pull_the_Sun_Globe]


	# Get a random index from the array
	var random_index = randi() % all_voicelines.size()
	if random_index == last_voiceline_idx:
		random_index = (random_index + 1)%all_voicelines.size()
	last_voiceline_idx = random_index

	# Play the voiceline at the random index
	all_voicelines[random_index].play()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	play_random_voiceline()
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if time_to_next_voiceline > 0:
		time_to_next_voiceline -= delta
	
	if !walking_enabled:
		return
	#SimpleGrass.set_player_position(global_position)
	if !picked_up && pickup_cooldown >= 0:
		pickup_cooldown -= delta
		if pickup_cooldown < 0:
			pickup_cooldown = 0
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("pickup"):
		print("pickup")
		if picked_up == null:
			pickup_orb()
			

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
		animation_tree.set("parameters/conditions/throw", true)
		
		
func _throw_finished():
	animation_tree.set("parameters/conditions/throw", false)
	pickup_cooldown = pickup_cooldown_time
	if !picked_up: return
	#var trow_dir = $Head/Camera3D.global_transform.basis
	var trow_dir = -pivot.global_transform.basis.z * trow_force
	if time_to_next_voiceline < 0:
		time_to_next_voiceline = 10
		play_random_voiceline()
	$trow_sound/trow.play()
	picked_up.let_go(trow_dir)
	picked_up = null

func _headshake(t: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(t * HEAD_FREQ) * HEAD_AMP
	pos.x = cos(t * HEAD_FREQ * 0.5) * HEAD_AMP
	return pos
	
func hit(dir):
	emit_signal("player_hit")
	var parent_node = get_parent()
	parent_node.game_over()
	velocity += dir * HIT_STAGGER

func pickup_orb():
	#print("ENTERED")
	if picked_up: return
	if pickup_cooldown > 0: return
	elif collider.has_method("pick_up"):
		collider.pick_up(pivot)
		picked_up = collider

#func _on_area_3d_body_entered(body: Node3D) -> void:
	#pickup_orb()
	#pass # Replace with function body.
	
func set_is_camera_active(is_active: bool):
	$Head/Camera3D.current = is_active
	
