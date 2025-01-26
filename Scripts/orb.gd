extends RigidBody3D
# Source for some of this code: https://www.youtube.com/watch?v=aULD8w9mq3s&ab_channel=MrElipteach
@onready var original_parent = get_parent()
@onready var original_collision_layer = collision_layer
@onready var original_colission_mask = collision_mask

var original_transform
var org_speed = 20.0
var speed = 20.0
var picked_up_by = null
var done_learp = false
@onready var original_pos = global_transform.origin

var physics_enabaled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.cutscene_slow_pickup:
		speed = 5
	pass # Replace with function body.
	
func lock_in_original_place():
	global_transform.origin = original_pos
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !physics_enabaled: 
		lock_in_original_place()
		return
	if !picked_up_by: return

	# Current position
	var current_position = global_transform.origin

	# Target position
	var target_position = picked_up_by.global_transform.origin
	
	if done_learp:
		global_transform.origin = target_position
		return
	
	var distance_to_hand = current_position.distance_to(target_position)
	if distance_to_hand < 0.1:
		done_learp = true
		

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

	
func _move_to_parent(from_parent, to_parent):
	from_parent.remove_child(self)
	to_parent.add_child(self)
		

func pick_up(by):
	print("Picking up")
	
	if picked_up_by == by:
		return
	
	if picked_up_by:
		let_go()
		
	picked_up_by = by
	original_transform = global_transform
	
	#freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	#collision_layer = 0
	#collision_mask = 0
	
	call_deferred("_move_to_parent", original_parent, picked_up_by)
	
		
	
	pass
	#$CollisionShape3D.disabled = true
	#$".".position = $"../Player".position

func disable_all_physics():
	print("Disabled orb physics")
	#freeze_mode = FREEZE_MODE_STATIC
	physics_enabaled = false
	
func enable_all_physics():
	print("Enabled orb physics")
	linear_velocity = Vector3(0,0,0)
	physics_enabaled = true
	
	

func let_go(impulse = Vector3(0.0, 0.0, 0.0)):
	GameManager.cutscene_slow_pickup = false
	speed = org_speed
	print("trowing (letting go)")
	
	done_learp = false
	
	if picked_up_by:
		var t = global_transform
		
		picked_up_by.remove_child(self)
		original_parent.add_child(self)
		
		global_transform = t
		#freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		
		linear_velocity = Vector3(0,0,0)
		
		#collision_layer = original_colission_mask
		#collision_mask = original_collision_layer
		apply_impulse(impulse, Vector3(0.0, 0.0, 0.0))
		
		
		picked_up_by = null
		
	


func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int, extra_arg_0: NodePath) -> void:
	pick_up(extra_arg_0)


func _on_body_entered(body: Node) -> void:
	
	pass # Replace with function body.
