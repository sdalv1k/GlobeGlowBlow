extends Node3D


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func play_random_child():
	# Ensure the current node has children
	if get_child_count() == 0:
		print("No child nodes to play.")
		return

	# Get a random index within the range of children
	var random_index = randi() % get_child_count()

	# Get the child node at the random index
	var random_child = get_child(random_index)

	# Check if the child has a 'play' method
	if random_child.has_method("play"):
		random_child.play()
	else:
		print("Selected child does not have a 'play' method.")
