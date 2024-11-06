# GameGlobals.gd
extends Node

var is_camera_mode = false  # Global flag to check if the game is in camera mode
var player_position = Vector2.ZERO  # Store player position globally
var enemy_detection_radius = 300  # Example global detection radius for enemies
var is_tracking_player = false  # Global flag for whether any enemy is tracking the player
