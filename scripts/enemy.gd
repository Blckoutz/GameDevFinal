extends CharacterBody2D

@export var speed: float = 200  # Movement speed
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D  # Reference to NavigationAgent2D
@onready var detection_radius: Area2D = $AIdetection  # Reference to the detection area (Area2D)
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D  # Reference to the navigation region
@onready var wall_check_timer: Timer = $wallCheck  # Timer to detect if stuck on a wall


var scriptPick=0
var is_tracking: bool = false  # Tracks whether the enemy is following the player
var is_navigation_ready: bool = false  # Tracks whether the navigation map is ready
var stuck_on_wall: bool = false  # Tracks if the enemy is stuck on a wall

func _ready() -> void:
	$AnimatedSprite2D.play("idle")  # Start with idle animation
	connect_signals()  # Connect signals for player detection
	NavigationServer2D.map_changed.connect(Callable(self, "_on_map_ready"))  # Detect map synchronization

func connect_signals() -> void:
	# Connect signals for entering and exiting the detection radius
	detection_radius.body_entered.connect(Callable(self, "_on_player_detected"))
	detection_radius.body_exited.connect(Callable(self, "_on_player_lost"))

# Handle when the navigation map is ready
func _on_map_ready(new_map: RID) -> void:
	is_navigation_ready = true

# When the player enters the detection radius, start tracking
func _on_player_detected(body: Node) -> void:
	if body.name == "Player":
		is_tracking = true
		print("Player detected!")  # Debug statement

# When the player leaves the detection radius, stop tracking
func _on_player_lost(body: Node) -> void:
	if body.name == "Player":
		is_tracking = false
		print("Player lost!")  # Debug statement

func _physics_process(delta: float) -> void:
	if is_tracking:
		_track_player()  # Follow the player with pathfinding
	else:
		_wander()  # Wander around randomly

# Handle wall detection if stuck for too long
func _on_wall_check_timeout() -> void:
	if stuck_on_wall:
		_choose_new_direction()  # Change direction if stuck on a wall

# Get a random point within the navigation region
func get_random_point_in_navigation_region() -> Vector2:
	if navigation_region:
		var nav_polygon = navigation_region.navigation_polygon
		var vertices = nav_polygon.get_vertices()
		var polygon_count = nav_polygon.get_polygon_count()
		if vertices.size() > 0 and polygon_count > 0:
			var random_polygon_index = randi() % polygon_count
			var polygon_points = nav_polygon.get_polygon(random_polygon_index)
			var random_point_index = randi() % polygon_points.size()
			return vertices[polygon_points[random_point_index]]
	return Vector2.ZERO

# Wander using NavigationAgent2D and detect walls
func _wander() -> void:
	if is_navigation_ready:
		if navigation_agent and navigation_agent.is_navigation_finished():
			var random_pos = get_random_point_in_navigation_region()
			navigation_agent.set_target_position(random_pos)

		var wander_direction = navigation_agent.get_next_path_position() - global_position
		if wander_direction.length() > 0:
			velocity = wander_direction.normalized() * speed
			move_and_slide()  # Apply movement
			update_animation(velocity)
			# Start wall check timer if near a wall
			stuck_on_wall = is_near_wall()
			if stuck_on_wall:
				wall_check_timer.start(0.2)

# Track the player with pathfinding
func _track_player() -> void:
	if is_navigation_ready:
		if navigation_agent and navigation_agent.is_navigation_finished():
			var target_position = GameGlobals.player_position
			navigation_agent.set_target_position(target_position)

		var direction_to_target = navigation_agent.get_next_path_position() - global_position
		if direction_to_target.length() > 0:
			velocity = direction_to_target.normalized() * speed
			move_and_slide()  # Apply movement
			update_animation(velocity)
		else:
			print("Enemy reached the target!")

# Check if the enemy is near a wall (using collision layers)
func is_near_wall() -> bool:
	return test_move(global_transform, Vector2.ZERO)

# Choose a new random direction to avoid getting stuck
func _choose_new_direction() -> void:
	if navigation_agent:
		var new_pos = get_random_point_in_navigation_region()
		navigation_agent.set_target_position(new_pos)
		stuck_on_wall = false

# Update animations based on movement direction
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
