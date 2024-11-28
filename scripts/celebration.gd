extends Node2D

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func _on_timer_timeout() -> void:
	GameGlobals.level_number+=1
	GameGlobals.next_level()
