extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_down() -> void:
	get_tree().quit()


func _on_restart_button_down() -> void:
	print("Restart button")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/World.tscn")
	pass # Replace with function body.
	
func play_game_over_sound():
	$game_over_sound.play()
	
