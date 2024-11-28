extends "res://scripts/killzone.gd"

@export var jumpscare_images: Array[Texture2D]
@export var jumpscare_audios: Array[AudioStream]
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var jumpscare_ui: TextureRect = $TextureRect
@onready var timer: Timer = $Timer


func _ready():
	pick_jumpscare()

func pick_jumpscare():
	# Randomly pick and display a jumpscare image
	if jumpscare_images.size() > 0:
		var random_image = jumpscare_images[randi() % jumpscare_images.size()]
		show_jumpscare_image(random_image)

	# Randomly pick and play a jumpscare audio
	if jumpscare_audios.size() > 0:
		var random_audio = jumpscare_audios[randi() % jumpscare_audios.size()]
		play_jumpscare_audio(random_audio)

func show_jumpscare_image(image: Texture2D):
	jumpscare_ui.texture = image
	jumpscare_ui.visible = true
	timer.start()

func _on_timer_timeout() -> void:
	jumpscare_ui.visible = false
	GameGlobals.reset_level_post_JumpScare()

func play_jumpscare_audio(audio: AudioStream) -> void:
	audio_player.stream = audio
	audio_player.play()
