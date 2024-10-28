extends Node

@export var player_camera: Camera2D  # Player's main camera in this scene
@export var room_cameras: Array[Camera2D] # Array of additional Camera2D nodes in rooms

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
