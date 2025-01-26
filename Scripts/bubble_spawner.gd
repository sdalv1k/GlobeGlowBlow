extends Node3D

@onready var world: Node3D = $".."

@onready var topleft: Node3D = $SpawnArea/topleft
@onready var topright: Node3D = $SpawnArea/topright
@onready var bottomleft: Node3D = $SpawnArea/bottomleft
@onready var bottomright: Node3D = $SpawnArea/bottomright

@onready var spawns: Node3D = $SpawnPoints
@onready var bubbles: Node3D = $Bubbles

var bubble = preload("res://Scenes/Bubble.tscn")
var active_spawns = {}

const radius = 20.0
const GRID_COLUMNS = 3
const GRID_ROWS = 3

func _ready() -> void:
	_create_spawn_points()

	# Initialize the dictionary to track which spawn points are occupied
	for spawn_point in spawns.get_children():
		active_spawns[spawn_point] = false

func _create_spawn_points() -> void:
	# Calculate the rectangle's dimensions using the corner points
	var top_left_pos = topleft.global_transform.origin
	var top_right_pos = topright.global_transform.origin
	var bottom_left_pos = bottomleft.global_transform.origin
	
	top_left_pos.x += radius
	top_right_pos.x -= radius
	bottom_left_pos.x += radius
	
	var x_step = (top_right_pos.x - top_left_pos.x) / (GRID_COLUMNS - 1)
	var z_step = (bottom_left_pos.z - top_left_pos.z - 2*radius) / (GRID_ROWS - 1)

	# Generate spawn points within the rectangle
	for row in range(GRID_ROWS):
		for col in range(GRID_COLUMNS):
			var spawn_point = Node3D.new()
			spawn_point.position = Vector3(
				top_left_pos.x + col * x_step,
				top_left_pos.y - radius - 0.6,  # Assume the spawn plane is flat
				top_left_pos.z + row * z_step + radius
			)
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

func _on_spawn_timer_timeout():
	var spawn_point = _get_random_free_spawn_point()
	if spawn_point:
		# Mark the spawn point as occupied
		active_spawns[spawn_point] = true

		# Spawn the bubble
		var instance = bubble.instantiate()
		instance.position = spawn_point.global_position
		bubbles.add_child(instance)

		instance.connect("tree_exited", _on_bubble_removed)
		
		return instance
	else:
		return null

func _on_bubble_removed(spawn_point):
	# Mark the spawn point as free
	active_spawns[spawn_point] = false
