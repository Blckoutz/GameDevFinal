extends Node2D

@export var jumpscare_images: Array[Texture2D]
@export var jumpscare_audios: Array[AudioStream]
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var jumpscare_camera: Camera2D = $TextureRect/Camera2D  # Camera node in the killzone scene
@onready var player_camera: Camera2D  # We'll reference this from the level_1 scene

var jumpscare_timer: Timer

func _ready() -> void:
	jumpscare_timer = $Timer
	jumpscare_timer.connect("timeout", Callable(self, "_on_jumpscare_timeout"))
	
	# Reference the player camera from level_1
	player_camera = get_node("/root/level_1/Cameras/Camera/Camera2D")  # Path to the player camera

	# Disable the jumpscare camera at first, and enable the player camera
	if jumpscare_camera != null:
		jumpscare_camera.enabled = false
	if player_camera != null:
		player_camera.enabled = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Trigger jumpscare if the player enters the killzone
	trigger_jumpscare()

func trigger_jumpscare() -> void:
	# Switch cameras: Disable the player camera, enable the jumpscare camera
	if player_camera != null:
		player_camera.enabled = false
	if jumpscare_camera != null:
		jumpscare_camera.enabled = true

	# Randomly pick and display a jumpscare image
	if jumpscare_images.size() > 0:
		var random_image = jumpscare_images[randi() % jumpscare_images.size()]
		show_jumpscare_image(random_image)

	# Randomly pick and play a jumpscare audio
	if jumpscare_audios.size() > 0:
		var random_audio = jumpscare_audios[randi() % jumpscare_audios.size()]
		play_jumpscare_audio(random_audio)

	# Start the timer for the jumpscare
	jumpscare_timer.start(3)  # Set for 12 seconds

func show_jumpscare_image(image: Texture2D) -> void:
	var jumpscare_ui = $TextureRect  # This is the node showing the image
	jumpscare_ui.texture = image
	jumpscare_ui.visible = true

func play_jumpscare_audio(audio: AudioStream) -> void:
	audio_player.stream = audio
	audio_player.play()

# When the timer finishes, return to the player camera and hide the jumpscare image
func _on_jumpscare_timeout() -> void:
	if jumpscare_camera != null:
		jumpscare_camera.enabled = false  # Disable the jumpscare camera
	if player_camera != null:
		player_camera.enabled = true  # Enable the player camera
	$TextureRect.visible = false  # Hide the jumpscare image if it's still visible
	get_tree().reload_current_scene()
