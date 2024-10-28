extends Node

var player_position = Vector2()


func set_canvas_modulate(enabled: bool):
	get_viewport().canvas_modulate = Color(1, 1, 1, 1) if enabled else Color(1, 1, 1, 0)
