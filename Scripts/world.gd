extends Node3D

@onready var hit_rect = $UI/ColorRect

func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
