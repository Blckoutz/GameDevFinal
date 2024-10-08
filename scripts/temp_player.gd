extends CharacterBody2D

var FLon=false
const speed=200

var direction="none"






func _ready() -> void:
	$AnimatedSprite2D.play("idleFaceFront")
	$FLightBox.disabled=true
	

func _physics_process(delta: float) -> void:
	player_movement(delta)
	
func player_movement(delta):
	
	if Input.is_action_pressed("moveRight"):
		direction="right"
		play_anim(1)
		velocity.x=speed
		velocity.y=0
	elif Input.is_action_pressed("moveLeft"):
		play_anim(1)
		direction="left"
		velocity.x=-speed
		velocity.y=0 
	elif Input.is_action_pressed("moveDown"):
		play_anim(1)
		direction="down"
		velocity.x=0
		velocity.y=speed 
	elif Input.is_action_pressed("moveUp"):
		play_anim(1)
		direction="up"
		velocity.x=0
		velocity.y=-speed
	elif Input.is_action_pressed("moveLeft") && Input.is_action_pressed("moveDown"):
		play_anim(1)
		direction="left"
		velocity.x=-speed
		velocity.y=speed
	#elif Input.is_action_pressed("moveLeft") && Input.is_action_pressed("moveDown") || Input.is_action_pressed("moveUp"):
	#	play_anim(1)
	#	direction="left"
	#	velocity.x=-speed
	#	if Input.is_action_pressed("moveDown"):
	#		velocity.y=speed
	#	elif Input.is_action_pressed("moveUp"):
	#		velocity.y=-speed
	#elif Input.is_action_pressed("moveRight") && Input.is_action_pressed("moveDown") || Input.is_action_pressed("moveUp"):
	#	play_anim(1)
	#	direction="right"
	#	velocity.x=speed
	#	if Input.is_action_pressed("moveDown"):
	#		velocity.y=speed
	#	elif Input.is_action_pressed("moveUp"):
	#		velocity.y=-speed
	else:
		play_anim(0)
		velocity.x=0
		velocity.y=0
	move_and_slide()
	
	
func play_anim(movement):
	var dir=direction
	var anim =$AnimatedSprite2D
	
	if dir=="right":
		anim.flip_h=false
		if movement==1:
			anim.play("walkSide")
		elif movement ==0:
			anim.play("idleFaceSide")
	elif dir=="left":
		anim.flip_h=true
		if movement ==1:
			anim.play("walkSide")
		elif movement==0:
			anim.play("idleFaceSide")
	elif dir=="down":
		if movement ==1:
			anim.play("walkF")
		elif movement==0:
			anim.play("idleFaceFront")
	elif dir=="up":
		if movement ==1:
			anim.play("walkB")
		elif movement==0:
			anim.play("idleFaceBack")
			
func flashlight_on(delta):
	if (Input.is_action_pressed("flashlight")) && (FLon==false):
		$FLightBox.disbaled=false
		FLon=true
	elif (Input.is_action_pressed("flashlight")) && (FLon==true):
		$FLightBox.disabled=true
		FLon=false
func flashlight_battery(delta):
	$FLightBox/Timer.paused
	while (FLon==true):
		$FLightBox/Timer.start()
