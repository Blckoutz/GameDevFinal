extends CharacterBody2D

enum MotionMode { Motion_Mode_Floating = 1 }

var FLon = false
const speed = 200
var direction = Vector2.ZERO

func _ready() -> void:
	$AnimatedSprite2D.play("idleFaceFront")
	$FLightBox.disabled = true  # Ensure initial state is off
	$FLightBox/flashlight.enabled = false  # Ensure initial state is off

func _physics_process(delta: float) -> void:
	player_movement(delta)
	flashlight_on()
	flashlight_battery(delta)

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

	move_and_slide()

	update_flashlight()
	play_anim(1 if direction != Vector2.ZERO else 0)

func update_flashlight() -> void:
	if direction != Vector2.ZERO:
		$FLightBox/flashlight.rotation = direction.angle()
		# Update position based on direction (arbitrary values)
		if direction == Vector2.RIGHT:
			$FLightBox/flashlight.position = Vector2(0, 1.5)
		elif direction == Vector2.LEFT:
			$FLightBox/flashlight.position = Vector2(-76.5, 4)
		elif direction == Vector2.DOWN:
			$FLightBox/flashlight.position = Vector2(-41, 36.5)
		elif direction == Vector2.UP:
			$FLightBox/flashlight.position = Vector2(-44, -34)
		elif direction.x > 0 and direction.y > 0:  # Down-Right
			$FLightBox/flashlight.position = Vector2(0, 1.5).lerp(Vector2(-41, 36.5), direction.y)
		elif direction.x < 0 and direction.y > 0:  # Down-Left
			$FLightBox/flashlight.position = Vector2(-76.5, 4).lerp(Vector2(-41, 36.5), direction.y)
		elif direction.x > 0 and direction.y < 0:  # Up-Right
			$FLightBox/flashlight.position = Vector2(0, 1.5).lerp(Vector2(-44, -34), -direction.y)
		elif direction.x < 0 and direction.y < 0:  # Up-Left
			$FLightBox/flashlight.position = Vector2(-76.5, 4).lerp(Vector2(-44, -34), -direction.y)

func play_anim(movement: int) -> void:
	var anim = $AnimatedSprite2D
	anim.flip_h = direction.x < 0  # Simplified horizontal flip logic
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
		print("Flashlight button pressed")  # Debugging statement
		FLon = !FLon  # Toggle the flashlight state
		$FLightBox.disabled = not FLon  # Enable/disable based on state
		$FLightBox/flashlight.enabled = FLon  # Enable/disable the PointLight2D
		print("Flashlight state:", FLon)  # Debugging statement
		print("FLightBox disabled state:", $FLightBox.disabled)  # Debugging statement
		print("Flashlight enabled state:", $FLightBox/flashlight.enabled)  # Debugging statement

func flashlight_battery(_delta: float) -> void:
	if FLon:
		$FLightBox/flashlight/Timer.start()
