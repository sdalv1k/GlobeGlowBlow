extends Node3D

#@onready var hit_rect = $UI/ColorRect
#
#func _on_player_player_hit() -> void:
	#hit_rect.visible = true
	#await get_tree().create_timer(0.2).timeout
	#hit_rect.visible = false
	
var paused = false
	
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("esc"):
		if paused:
			unpause()
		else:
			pause()
		


func pause():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$pauseMenu.show()
	pass
	
func unpause():
	$pauseMenu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	pass
	
func game_over():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$GameOver.show()
