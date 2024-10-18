extends Control
var game_node = preload("res://scripts/game.gd")  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Start.grab_focus()
	$AudioStreamPlayer2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	
	
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
	


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/options_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
