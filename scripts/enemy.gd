extends CharacterBody2D

@export var speed: float = 200
@export var change_direction_interval: float = 2.0
@onready var wall_check_timer: Timer = $wallCheck
@onready var random_direction_timer: Timer = $randomDirectionTimer

var movement_velocity: Vector2 = Vector2.ZERO
var stuck_on_wall: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	connect_signals()
	set_random_direction()

func connect_signals() -> void:
	wall_check_timer.timeout.connect(_on_wall_check_timeout)
	random_direction_timer.timeout.connect(_on_random_direction_timeout)
	random_direction_timer.start(change_direction_interval)

func _physics_process(delta: float) -> void:
	if not stuck_on_wall:
		var collision = move_and_collide(movement_velocity * delta)
		if collision:
			stuck_on_wall = true
			_bounce_off_wall(collision.get_normal()) # Use `get_normal()` method
			wall_check_timer.start(0.2)
		else:
			update_animation(movement_velocity)

func _on_wall_check_timeout() -> void:
	stuck_on_wall = false

func _on_random_direction_timeout() -> void:
	set_random_direction()

func set_random_direction() -> void:
	# Pick a random direction and set movement_velocity
	var angle = randf_range(0, 2 * PI)
	movement_velocity = Vector2(cos(angle), sin(angle)) * speed
	update_animation(movement_velocity)

func _bounce_off_wall(normal: Vector2) -> void:
	movement_velocity = movement_velocity.bounce(normal).normalized() * speed
	update_animation(movement_velocity)

func update_animation(direction: Vector2) -> void:
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walkSide")
	elif direction.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("walkSide")
	elif direction.y > 0:
		$AnimatedSprite2D.play("walkF")
	elif direction.y < 0:
		$AnimatedSprite2D.play("walkB")
	else:
		$AnimatedSprite2D.play("idle")
