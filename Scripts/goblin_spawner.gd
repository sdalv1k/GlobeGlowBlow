extends Node

@onready var spawns: Node3D = $SpawnPoints
@onready var goblins: Node3D = $Goblins

var goblin = preload("res://Scenes/goblin.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_random_spawn_point():
	return spawns.get_child(randi() % spawns.get_child_count())

func _on_spawn_timer_timeout():
	var spawn_point = _get_random_spawn_point()
	if spawn_point:
		print("Spawning Goblin")
		var instance = goblin.instantiate()
		instance.position = spawn_point.global_position
		goblins.add_child(instance)
