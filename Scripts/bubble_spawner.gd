extends Node3D

@onready var spawns: Node3D = $SpawnPoints
@onready var bubbles: Node3D = $Bubbles

var bubble = load("res://Scenes/Bubble.tscn")
var active_spawns = {}

var radius = 20.0
const GRID_COLUMNS = 10
const GRID_ROWS = 10
const OFFSET = 4.0

func _ready() -> void:
	_create_spawn_points()
	# Initialize the dictionary to track which spawn points are occupied
	for spawn_point in spawns.get_children():
		active_spawns[spawn_point] = false
		
func _create_spawn_points() -> void:
	# Create a grid of spawn points
	for row in range(GRID_ROWS):
		for col in range(GRID_COLUMNS):
			var spawn_point = Node3D.new()
			spawn_point.position = Vector3(col * OFFSET, -radius, row * OFFSET)
			spawns.add_child(spawn_point)

func _get_random_free_spawn_point():
	# Filter out spawn points that are already occupied
	var free_spawns = []
	for spawn_point in active_spawns.keys():
		if not active_spawns[spawn_point]:
			free_spawns.append(spawn_point)

	# If no free spawn points are available, return null
	if free_spawns.is_empty():
		return null

	# Return a random free spawn point
	return free_spawns[randi() % free_spawns.size()]


func _on_spawn_timer_timeout() -> void:
	var spawn_point = _get_random_free_spawn_point()
	if spawn_point:
		# Mark the spawn point as occupied
		active_spawns[spawn_point] = true

		# Spawn the bubble
		var instance = bubble.instantiate()
		instance.position = spawn_point.global_position
		bubbles.add_child(instance)
		
		instance.connect("tree_exited", _on_bubble_removed)
	
func _on_bubble_removed(spawn_point):
	# Mark the spawn point as free
	active_spawns[spawn_point] = false
