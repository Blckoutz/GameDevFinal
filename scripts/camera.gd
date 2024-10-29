extends CharacterBody2D

var player_camera: Camera2D  
var room_cameras: Array[Camera2D]

var is_camera_mode = false
var current_camera_index = 0


func _ready():
	$AnimatedSprite2D.play("default")
	var level = get_parent().get_parent()
	  
	print(level)

	# Access player_camera and room_cameras directly
	player_camera = level.player_camera
	room_cameras = level.room_cameras

	# Check if player_camera and room_cameras are set up properly
	if player_camera == null:
		push_error("player_camera is not set on the level.")
		return
	if room_cameras.size() == 0:
		push_error("room_cameras array is empty on the level.")
		return

	# Initialize cameras
	player_camera.make_current()  # Use make_current() to activate the player camera
	# No need to set room cameras here since we manage that in the switching function

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
		$"../../CanvasModulate".color=Color(1,0,27,0)
	else:
		set_process(true)
		switch_to_camera(player_camera)
		$"../../CanvasModulate".color=Color(1,0,27,255)

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
		print("Switched to camera:", camera.name)  # Debug output
	else:
		push_error("Attempted to switch to a camera that is not assigned!")
