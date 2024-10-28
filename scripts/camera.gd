extends CharacterBody2D

@export var player_camera: Camera2D  # Player's main camera in this scene
@export var room_cameras: Array[Camera2D] # Array of additional Camera2D nodes in rooms
@export var phone_animation: AnimationPlayer  # Animation player for the phone

var is_camera_mode = false
var current_camera_index = 0

func _ready():
	# Set the player camera as active and disable room cameras initially
	$AnimatedSprite2D.play("default")
	player_camera.current = true
	for cam in room_cameras:
		cam.current = false

func _process(delta):
	if Input.is_action_just_pressed("Camera"):
		toggle_camera_mode()

	if is_camera_mode:
		# Handle camera switching with new input names
		if Input.is_action_just_pressed("switch_cameraNext"):
			switch_to_next_camera()
		elif Input.is_action_just_pressed("switch_cameraPrev"):
			switch_to_previous_camera()

func toggle_camera_mode():
	is_camera_mode = !is_camera_mode
	if is_camera_mode:
		set_process(false)  # Locks player movement
		current_camera_index = 0
		switch_to_camera(room_cameras[current_camera_index])
		phone_animation.play("openNclose")
	else:
		set_process(true)
		switch_to_camera(player_camera)
		phone_animation.play_backwards("openNclose")

func switch_to_next_camera():
	current_camera_index = (current_camera_index + 1) % room_cameras.size()
	switch_to_camera(room_cameras[current_camera_index])

func switch_to_previous_camera():
	current_camera_index = (current_camera_index - 1 + room_cameras.size()) % room_cameras.size()
	switch_to_camera(room_cameras[current_camera_index])

func switch_to_camera(camera: Camera2D):
	player_camera.current = false
	for cam in room_cameras:
		cam.current = false
	camera.current = true
