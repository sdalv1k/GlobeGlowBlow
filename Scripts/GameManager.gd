extends Node
var goblin_score: int = 0
var game_over = false
var cutscene_slow_pickup = true

func increment_goblin_score():
	goblin_score += 1
	print("incremented goblin score in GameManager")
	
func reset_all_stats():
	goblin_score = 0

func call_game_over():
	game_over = true
