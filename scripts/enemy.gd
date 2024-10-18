extends CharacterBody2D

@export var wander_direction : Node2D
@export var pathfinding: PathFinding

func _ready() -> void:
	$AnimatedSprite2D.play("idle")

func _track():
	velocity = pathfinding.direction *200
	move_and_slide()
func _roam():
	velocity = wander_direction.direction * 200
	move_and_slide()
