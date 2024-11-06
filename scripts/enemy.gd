extends CharacterBody2D

@export var speed: float = 200
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_radius: Area2D = $AIdetection
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
@onready var wall_check_timer: Timer = $wallCheck

var is_tracking: bool = false
var is_navigation_ready: bool = false
var stuck_on_wall: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	connect_signals()
	NavigationServer2D.map_changed.connect(Callable(self, "_on_map_ready"))

func connect_signals() -> void:
	detection_radius.body_entered.connect(_on_player_detected)
	detection_radius.body_exited.connect(_on_player_lost)
	wall_check_timer.timeout.connect(_on_wall_check_timeout)

func _on_map_ready(new_map: RID) -> void:
	is_navigation_ready = true

func _on_player_detected(body: Node) -> void:
	if body.name == "Player":
		is_tracking = true
		GameGlobals.is_tracking_player = true  # Update global tracking flag
		print("Player detected!")

func _on_player_lost(body: Node) -> void:
	if body.name == "Player":
		is_tracking = false
		GameGlobals.is_tracking_player = false  # Reset global tracking flag
		print("Player lost!")

func _physics_process(delta: float) -> void:
	if is_tracking:
		_track_player()
	else:
		_wander()

func _on_wall_check_timeout() -> void:
	if stuck_on_wall:
		_choose_new_direction()

func get_random_point_in_navigation_region() -> Vector2:
	if navigation_region and navigation_region.navigation_polygon:
		var nav_polygon = navigation_region.navigation_polygon
		var vertices = nav_polygon.get_vertices()  # All vertices as Vector2 points
		var polygon_count = nav_polygon.get_polygon_count()

		if polygon_count > 0:
			# Get a random polygon index
			var random_polygon_index = randi() % polygon_count
			var polygon_points = nav_polygon.get_polygon(random_polygon_index)  # Indices into vertices array

			# Select a random vertex within the polygon
			if polygon_points.size() > 0:
				var vertex_index = polygon_points[randi() % polygon_points.size()]
				var local_point = vertices[vertex_index]  # Retrieve the actual Vector2 from vertices
				return navigation_region.to_global(local_point)  # Convert to global position
		
	# Default to current position if no valid point is found
	return global_position



func _wander() -> void:
	if is_navigation_ready:
		if navigation_agent.is_navigation_finished():
			var random_pos = get_random_point_in_navigation_region()
			navigation_agent.set_target_position(random_pos)

		var wander_direction = navigation_agent.get_next_path_position() - global_position
		if wander_direction.length() > 0:
			velocity = wander_direction.normalized() * speed
			move_and_slide()
			update_animation(velocity)
			if is_near_wall():
				stuck_on_wall = true
				wall_check_timer.start(0.2)

func _track_player() -> void:
	if is_navigation_ready:
		var target_position = GameGlobals.player_position  # Use global player position
		navigation_agent.set_target_position(target_position)

		var direction_to_target = navigation_agent.get_next_path_position() - global_position
		if direction_to_target.length() > 0:
			velocity = direction_to_target.normalized() * speed
			move_and_slide()
			update_animation(velocity)
		else:
			print("Enemy reached the target!")

func is_near_wall() -> bool:
	return not move_and_collide(velocity * get_physics_process_delta_time())

func _choose_new_direction() -> void:
	if navigation_agent:
		var new_pos = get_random_point_in_navigation_region()
		navigation_agent.set_target_position(new_pos)
		stuck_on_wall = false

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
