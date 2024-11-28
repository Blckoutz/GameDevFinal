extends "res://scripts/killzone.gd"


func play_Jumpscare(image: TextureRect):
	var jumpscare_ui = $TextureRect  # This is the node showing the image
	jumpscare_ui.texture = image
	jumpscare_ui.visible = true
