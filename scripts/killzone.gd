extends Node2D


func _on_area_2d_area_entered(area: Area2D) -> void:
	# Trigger jumpscare if the player enters the killzone
	trigger_jumpscare()

func trigger_jumpscare() -> void:
	call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/misc/jumpscare_image.tscn")
