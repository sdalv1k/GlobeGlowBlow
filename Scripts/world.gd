extends Node3D

@onready var hit_rect = $UI/ColorRect

@onready var atmosphere_sound = $sound_ambient/Atmosphere


func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	
var paused = false

var cutscene_state = false
@onready var player_cutscenepos = $Player.global_transform.origin


func _ready() -> void:
	atmosphere_sound.play()
	GameManager.reset_all_stats()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#$"placeholder goblin/Head/Camera3D".current = true
	$Player.set_is_camera_active(true)
	#play_intro_cutscene()
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		$menu_sound.menu1()
		if paused:
			unpause()
		else:
			pause()
	if cutscene_state:
		$Player.global_transform.origin = player_cutscenepos
		if Input.is_action_just_pressed("pickup"):
			intro_cutscene_over()
			$Player.pickup_orb()
		


func pause():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$pauseMenu.show()
	pass
	
func unpause():
	$pauseMenu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	pass
	
func game_over():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$GameOver.show()
	
func intro_cutscene_over():
	cutscene_state = false
	#$Player.set_is_camera_active(true)
	$orb.enable_all_physics()
	enable_player_movement_for_intro()
	
	#$Player.show()
	
func lock_player_movement_for_intro():
	$Player.disable_walking()
	pass
	
func enable_player_movement_for_intro():
	$Player.enable_walking()
	pass
	
func play_intro_cutscene():
	cutscene_state = true
	#$Player.hide()
	$orb.disable_all_physics()
	lock_player_movement_for_intro()
	#$Node3D/Camera3D.current = true
	#intro_cutscene_over()
	
	
