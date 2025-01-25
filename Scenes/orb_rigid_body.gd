extends RigidBody3D
# Source for some of this code: https://www.youtube.com/watch?v=aULD8w9mq3s&ab_channel=MrElipteach
@onready var original_parent = get_parent()
@onready var original_collision_layer = collision_layer
@onready var original_colission_mask = collision_mask

var original_transform
var speed = 5.0
var picked_up_by = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !picked_up_by: return
	global_transform.origin
	pass
	#if is_in_hand:
		#$".".position = $"../Player".position
	


func pick_up():
	pass
	#$CollisionShape3D.disabled = true
	#$".".position = $"../Player".position
	
