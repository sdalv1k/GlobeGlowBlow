extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var body = $"."
var original_size = scale

var orb : RigidBody3D = null
var speed = 12
var size_shrink : float = 1

func disable_character_body():
	body.collision_layer = 0
	body.collision_mask = 0
	body.velocity = Vector3.ZERO


func _physics_process(delta: float) -> void:
	
	if orb:
		
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
			
	# Test movement
	else:
		var direction = Vector3()
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		direction.x = 0.3
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		move_and_slide()
	
	
func goblin_hit_with_orb(orb_connect : RigidBody3D):
	if !orb: # to prevent several hit detections on a single goblin
		print("GOBLIN HITTTTT!!")
		GameManager.increment_goblin_score()
		print("Score is now:", GameManager.goblin_score)
		orb = orb_connect
	
func despawn():
	queue_free()
