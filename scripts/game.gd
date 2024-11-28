# GameGlobals.gd
extends Node

var is_camera_mode = false  # Global flag to check if the game is in camera mode
var player_position = Vector2.ZERO  # Store player position globally
var enemy_detection_radius = 300  # Example global detection radius for enemies
var is_tracking_player = false  # Global flag for whether any enemy is tracking the player
var level_number=0 #Global flag for what level the player is on 

var levels: Array[PackedScene] = [preload("res://scenes/levels/level_1.tscn"), preload("res://scenes/levels/level_2.tscn")]

func next_level():
	var current_level=level_number
	if current_level >= levels.size():
		current_level=0
	get_tree().change_scene_to_packed(levels[current_level])
	
func reset_level_post_JumpScare():
	get_tree().change_scene_to_packed(levels[level_number])
