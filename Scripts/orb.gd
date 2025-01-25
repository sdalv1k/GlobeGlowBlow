extends RigidBody3D
# Source for some of this code: https://www.youtube.com/watch?v=aULD8w9mq3s&ab_channel=MrElipteach
@onready var original_parent = get_parent()
@onready var original_collision_layer = collision_layer
@onready var original_colission_mask = collision_mask

var original_transform
var speed = 5.0
var picked_up_by = null
var done_learp = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !picked_up_by: return
	#global_transform.origin = lerp(global_transform.origin, picked_up_by.global_transform.origin, speed * delta)
	global_transform.origin = picked_up_by.global_transform.origin
	pass
	#if is_in_hand:
		#$".".position = $"../Player".position
	
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
	

func let_go(impulse = Vector3(0.0, 0.0, 0.0)):
	print("trowing (letting go)")
	
	if picked_up_by:
		var t = global_transform
		
		picked_up_by.remove_child(self)
		original_parent.add_child(self)
		
		global_transform = t
		#freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		
		#collision_layer = original_colission_mask
		#collision_mask = original_collision_layer
		apply_impulse(impulse, Vector3(0.0, 0.0, 0.0))
		
		
		picked_up_by = null
		
	


func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int, extra_arg_0: NodePath) -> void:
	pick_up(extra_arg_0)
