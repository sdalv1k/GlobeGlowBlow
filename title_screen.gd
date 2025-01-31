extends CanvasLayer

var world_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_scene = preload("res://Scenes/World.tscn")
	
	
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	print("Start game Pressed")
	
	
	 #Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#get_tree().change_scene_to_file("res://Scenes/World.tscn")
	get_tree().change_scene_to_packed(world_scene)
	pass # Replace with function body.


func _on_button_mouse_entered() -> void:
	
	pass # Replace with function body.


func _on_button_mouse_exited() -> void:
	pass # Replace with function body.
