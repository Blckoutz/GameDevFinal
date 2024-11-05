# Camera Script
extends Node2D

var player_camera: Camera2D  
var room_cameras: Array[Camera2D]  # Cameras in the different rooms
var current_camera_index = 0

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	var level = get_parent().get_parent()  
	player_camera = level.player_camera
	room_cameras = level.room_cameras

	if player_camera != null:
		player_camera.make_current()
	else:
		push_error("player_camera is not set on the level.")
		
	if room_cameras.size() == 0:
		push_error("room_cameras array is empty on the level.")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Camera"):
		toggle_camera_mode()

	if GameGlobals.is_camera_mode:
		if Input.is_action_just_pressed("switch_cameraNext"):
			switch_to_next_camera()
		elif Input.is_action_just_pressed("switch_cameraPrev"):
			switch_to_previous_camera()

func toggle_camera_mode() -> void:
	GameGlobals.is_camera_mode = !GameGlobals.is_camera_mode  # Toggle camera mode globally
	if GameGlobals.is_camera_mode:
		current_camera_index = 0
		switch_to_camera(room_cameras[current_camera_index])
		$"../../CanvasModulate".visible = false  # Set canvas modulate to transparent
	else:
		switch_to_camera(player_camera)
		$"../../CanvasModulate".visible = true  # Restore canvas modulate to visible

func switch_to_next_camera() -> void:
	current_camera_index = (current_camera_index + 1) % room_cameras.size()
	switch_to_camera(room_cameras[current_camera_index])

func switch_to_previous_camera() -> void:
	current_camera_index = (current_camera_index - 1 + room_cameras.size()) % room_cameras.size()
	switch_to_camera(room_cameras[current_camera_index])

func switch_to_camera(camera: Camera2D) -> void:
	if camera != null:
		camera.make_current()
	else:
		push_error("Attempted to switch to a camera that is not a valid Camera2D instance!")
