extends Node2D

@export var player_camera: Camera2D  # Player's main camera in this scene
@export var room_cameras: Array[Camera2D] # Array of additional Camera2D nodes in rooms

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	levelSwitch()


func levelSwitch ():
	if($LevelTimer.is_stopped()):
		get_tree().change_scene_to_file("res://scenes/misc/celebration.tscn")
	pass
