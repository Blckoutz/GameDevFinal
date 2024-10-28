extends CharacterBody2D




var is_camera_mode = false
var current_camera_index = 0

func _ready():
	# Set the player camera as active and disable room cameras initially
	$AnimatedSprite2D.play("default")
	# Check if player_camera is valid
	if player_camera:
		player_camera.current = true
	else:
		push_error("player_camera is not assigned!")

	# Check if each room camera is valid
	for cam in room_cameras:
		if cam:
			cam.current = false
		else:
			push_error("One of the room_cameras is not assigned!")

func _process(_delta):
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
		#$AnimatedSprite2D.play("openNclose")
		# Disable canvas modulate via game.gd
		GameGlobals.set_canvas_modulate(false)
	else:
		set_process(true)
		switch_to_camera(player_camera)
		#$AnimatedSprite2D.play_backwards("openNclose")
		# Enable canvas modulate via game.gd
		GameGlobals.set_canvas_modulate(true)

func switch_to_next_camera():
	current_camera_index = (current_camera_index + 1) % room_cameras.size()
	switch_to_camera(room_cameras[current_camera_index])

func switch_to_previous_camera():
	current_camera_index = (current_camera_index - 1 + room_cameras.size()) % room_cameras.size()
	switch_to_camera(room_cameras[current_camera_index])

func switch_to_camera(camera: Camera2D):
	if player_camera:
		player_camera.current = false
	
	for cam in room_cameras:
		if cam:
			cam.current = false

	if camera:
		camera.current = true
	else:
		push_error("Attempted to switch to a camera that is not assigned!")
