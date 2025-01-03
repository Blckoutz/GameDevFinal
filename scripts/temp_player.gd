# Player Script
extends CharacterBody2D

var FLon = false  # Flashlight state
const speed = 250  # Movement speed
var direction = Vector2.ZERO  # Player movement direction
var battery_life = 180.0  # Battery life in seconds

func _ready() -> void:
	$AnimatedSprite2D.play("idleFaceFront")
	$FLightBox/FLightBox.disabled = true  # Flashlight starts off
	$FLightBox/FLightBox/flashlight.enabled = false

func _physics_process(delta: float) -> void:
	# Prevent player movement if in camera mode
	if GameGlobals.is_camera_mode:
		return  # Skip movement logic entirely

	player_movement(delta)
	flashlight_on()
	flashlight_battery(delta)

	# Update the player's global position every frame
	GameGlobals.player_position = global_position

func player_movement(_delta: float) -> void:
	direction = Vector2.ZERO

	if Input.is_action_pressed("moveRight"):
		direction.x += 1
	if Input.is_action_pressed("moveLeft"):
		direction.x -= 1
	if Input.is_action_pressed("moveDown"):
		direction.y += 1
	if Input.is_action_pressed("moveUp"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()  # Use the CharacterBody2D’s native velocity

	update_flashlight()
	play_anim(1 if direction != Vector2.ZERO else 0)

func update_flashlight() -> void:
	if direction != Vector2.ZERO:
		$FLightBox/FLightBox/flashlight.rotation = direction.angle()

	# Adjust flashlight position based on movement direction
	match direction:
		Vector2.RIGHT:
			$FLightBox/FLightBox/flashlight.position = Vector2(0, 1.5)
		Vector2.LEFT:
			$FLightBox/FLightBox/flashlight.position = Vector2(-76.5, 4)
		Vector2.DOWN:
			$FLightBox/FLightBox/flashlight.position = Vector2(-41, 36.5)
		Vector2.UP:
			$FLightBox/FLightBox/flashlight.position = Vector2(-44, -34)
		_:
			if direction.x > 0 and direction.y > 0:  # Down-Right
				$FLightBox/FLightBox/flashlight.position = Vector2(0, 1.5).lerp(Vector2(-20, 36.5), direction.y)
			elif direction.x < 0 and direction.y > 0:  # Down-Left
				$FLightBox/FLightBox/flashlight.position = Vector2(-76.5, 4).lerp(Vector2(-63, 36.5), direction.y)
			elif direction.x > 0 and direction.y < 0:  # Up-Right
				$FLightBox/FLightBox/flashlight.position = Vector2(0, 1.5).lerp(Vector2(-15, -34), -direction.y)
			elif direction.x < 0 and direction.y < 0:  # Up-Left
				$FLightBox/FLightBox/flashlight.position = Vector2(-76.5, 4).lerp(Vector2(-65, -34), -direction.y)

func play_anim(movement: int) -> void:
	var anim = $AnimatedSprite2D
	anim.flip_h = direction.x < 0

	if movement == 0:
		anim.play("idleFaceFront")
	else:
		match direction:
			Vector2.RIGHT, Vector2.LEFT:
				anim.play("walkSide" if movement == 1 else "idleFaceSide")
			Vector2.DOWN:
				anim.play("walkF" if movement == 1 else "idleFaceFront")
			Vector2.UP:
				anim.play("walkB" if movement == 1 else "idleFaceBack")

func flashlight_on() -> void:
	if Input.is_action_just_pressed("flashlight"):
		FLon = !FLon  # Toggle flashlight state
		$FLightBox/FLightBox.disabled = not FLon
		$FLightBox/FLightBox/flashlight.enabled = FLon

func flashlight_battery(delta: float) -> void:
	if FLon:
		battery_life -= delta  # Drain battery over time
		if battery_life <= 0:
			FLon = false
			$FLightBox/FLightBox.disabled = true
			$FLightBox/FLightBox/flashlight.enabled = false
