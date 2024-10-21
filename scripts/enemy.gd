extends CharacterBody2D

@export var wander_direction : Node2D
@export var pathfinding: PathFinding

func _ready() -> void:
	$AnimatedSprite2D.play("idle")  # Start with idle animation


func _process(delta: float) -> void:
	_on_a_idetection_area_entered($AIdetection)
	_roam()
func _on_a_idetection_area_entered(area: Area2D) -> void:
	_track()

func _track():
	# Set velocity using the pathfinding direction
	velocity = pathfinding.direction * 200
	move_and_slide()

	# Play animation based on direction
	update_animation(pathfinding.direction)


func _roam():
	# Set velocity using the wander direction
	velocity = wander_direction.direction * 200
	move_and_slide()

	# Play animation based on direction
	update_animation(wander_direction.direction)


func update_animation(direction: Vector2):
	# Determine which animation to play based on direction
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = false  # Moving right, do not flip
		$AnimatedSprite2D.play("walkSide")
	elif direction.x < 0:
		$AnimatedSprite2D.flip_h = true   # Moving left, flip the sprite
		$AnimatedSprite2D.play("walkSide")
	elif direction.y > 0:
		$AnimatedSprite2D.play("walkF")   # Moving down
	elif direction.y < 0:
		$AnimatedSprite2D.play("walkB")   # Moving up
	else:
		$AnimatedSprite2D.play("idle")    # Not moving, play idle
