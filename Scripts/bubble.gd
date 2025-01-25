extends AnimatableBody3D

var speed: float = 0.2
var moved: float = 0.0
var move_end: float = 3.5
var direction: int = 1
@onready var radius: float = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	move_end = radius * 0.5   

func _physics_process(delta: float) -> void:
	var tmp_moved = speed * direction * delta
	moved += tmp_moved
	if moved >= 0.0 and moved <= move_end:
		global_position.y += tmp_moved
		
	if moved <= 0.1 :
		_start_expanding()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _start_expanding():
	direction = 1
	
func _start_shrinking():
	direction = -1

func _on_area_3d_body_entered(body: Node3D) -> void:
	_start_shrinking()
