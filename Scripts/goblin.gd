extends CharacterBody3D


const SPEED = 8.0
const ATTACK_RANGE = 2.5
const JUMP_VELOCITY = 4.5
const GRAVITY = 100.0

var follow_node = null
var state_machine
var follow_player = false
var direction_to_target

# Goblin Sounds
#Chatter


@export var player_path : NodePath

@onready var player = $"../Player"
@onready var anim_tree = $AnimationTree
@onready var bubbles: Node3D = $"../Bubbles"

# fra placeholder:
var original_size = scale

var orb : RigidBody3D = null
var speed = 12
var size_shrink : float = 1
@onready var body = $"."

func disable_character_body():
	body.collision_layer = 0
	body.collision_mask = 0
	body.velocity = Vector3.ZERO
	
var time_to_next_chatter = 5

func _ready():
	
	_new_follow_node()
	state_machine = anim_tree.get("parameters/playback")
	await get_tree().create_timer(1).timeout
	
func _new_follow_node():
	if follow_player:
		follow_node = get_node(player_path)
	else:
		follow_node = bubbles._on_spawn_timer_timeout()
		
	var target_point = follow_node.global_position
	direction_to_target = (target_point - global_transform.origin).normalized()

func _follow_orb(delta):
	
	var target_position = orb.global_transform.origin
	var current_position = global_transform.origin
	#top_level = true
	disable_character_body()
	
	
	# Shrink or despawn
	if size_shrink < 0.1:
		despawn()
		return
	else:
		var distance_to = current_position.distance_to(target_position)
		if distance_to < 1:
			size_shrink -= 0.02
			$".".scale = original_size * size_shrink
	
	# Calculate the direction to the target
	var direction = (target_position - current_position).normalized()

	# Move a fixed distance toward the target per frame
	var distance_to_move = speed * delta

	# Check if we're about to overshoot the target
	if current_position.distance_to(target_position) <= distance_to_move:
		# Snap to the target position
		global_transform.origin = target_position
	else:
		# Move toward the target at a constant speed
		global_transform.origin += direction * distance_to_move
		

	
func _process(delta):
	
	velocity = Vector3.ZERO
	if orb:
		_follow_orb(delta)
		return
		
	time_to_next_chatter -= delta
	if time_to_next_chatter < 0:
		time_to_next_chatter = randi() % (10 - 5 + 1)
		var state = state_machine.get_current_node()
		if state == "blow":
			$blow_audio.play_random_child()
		else:
			$Audio_chatter.play_random_child()
	
	match state_machine.get_current_node():
		"run":
			if follow_node:
				var target_point = follow_node.global_position
				var left_vector = direction_to_target.cross(Vector3.UP).normalized()
				var target_fixing = target_point - left_vector * 0.7 - direction_to_target * 0.2
				var distance_to_target = global_position.distance_to(target_fixing)
				
				if distance_to_target < 1.5:
					follow_node = null
					anim_tree.set("parameters/conditions/blow", true)
				
				velocity = (target_fixing - global_transform.origin).normalized()  * SPEED
				look_at(Vector3(global_position.x + velocity.x, global_position.y, 
								global_position.z + velocity.z), Vector3.UP)
		"attack":
			if follow_node: 
				look_at(Vector3(follow_node.global_position.x, global_position.y, follow_node.global_position.z), Vector3.UP)
		"blow":
			pass

	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())

	if not is_on_floor():
		velocity += get_gravity() * 50 * delta
	move_and_slide()
	
func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)
		
func goblin_hit_with_orb(orb_connect : RigidBody3D):
	print("Hello")
	if !orb: # to prevent several hit detections on a single goblin
		$death_sound.play_random_child()
		print("GOBLIN HITTTTT!!")
		GameManager.increment_goblin_score()
		print("Score is now:", GameManager.goblin_score)
		orb = orb_connect
	
func despawn():
	queue_free()
	


func _on_hitbox_body_entered(body: RigidBody3D) -> void:
	print("ENTERED the goblin")
	goblin_hit_with_orb(body)


func _on_hitbox_area_entered(area: Area3D) -> void:
	print("ENTERED the goblin")
	pass # Replace with function body.
