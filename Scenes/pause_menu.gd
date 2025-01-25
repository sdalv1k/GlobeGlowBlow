extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func unpause():
	$".".hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false


func _on_resume_button_down() -> void:
	unpause()
	pass # Replace with function body.


func _on_button_button_down() -> void:
	get_tree().quit()


func _on_restart_button_down() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/World.tscn")
	pass # Replace with function body.
