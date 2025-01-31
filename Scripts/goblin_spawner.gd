extends Node

@onready var spawns: Node3D = $SpawnPoints
@onready var goblins: Node3D = $Goblins

var goblin = preload("res://Scenes/goblin.tscn")
var spawn_timer = 2.0
var timer = 0

func _ready():
	await get_tree().create_timer(1).timeout
	_on_spawn_timer_timeout()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	
	if timer >= spawn_timer:
		timer = 0
		spawn_timer -= 1 * delta
		print(spawn_timer)
		spawn_timer = max(spawn_timer, 1.5)
		_on_spawn_timer_timeout()
		

func _get_random_spawn_point():
	return spawns.get_child(randi() % spawns.get_child_count())

func _on_spawn_timer_timeout():
	var spawn_point = _get_random_spawn_point()
	if spawn_point:
		var instance = goblin.instantiate()
		instance.position = spawn_point.global_position
		goblins.add_child(instance)
