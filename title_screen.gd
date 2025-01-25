extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	print("Start game Pressed")
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://Scenes/World.tscn")
	pass # Replace with function body.
