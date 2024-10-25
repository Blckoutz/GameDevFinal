extends CharacterBody2D

@export var speed: float = 200  # Movement speed
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D  # Reference to NavigationAgent2D node
@onready var detection_radius: Area2D = $AIdetection  # Reference to the detection area (Area2D)
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D  # Reference to the navigation region
@onready var navigation_ready_timer: Timer = $NavigationReadyTimer  # Timer for navigation readiness

var is_tracking: bool = false  # Tracks whether the enemy is following the player
var is_navigation_ready: bool = false  # Tracks whether the navigation map is ready

func _ready() -> void:
	$AnimatedSprite2D.play("idle")  # Start with idle animation
	connect_signals()  # Connect signals for player detection
	NavigationServer2D.map_changed.connect(Callable(self, "_on_map_changed"))  # Correct signal connection
	navigation_ready_timer.connect("timeout", Callable(self, "_on_navigation_ready_timeout"))  # Correct signal connection
	navigation_ready_timer.wait_time = 0.5  # Set a half-second delay
	navigation_ready_timer.autostart = false  # Don't start the timer automatically

func connect_signals() -> void:
	# Connect signals for entering and exiting the detection radius
	detection_radius.body_entered.connect(Callable(self, "_on_player_detected"))
	detection_radius.body_exited.connect(Callable(self, "_on_player_lost"))

# Called when the navigation map is changed
func _on_map_changed(new_map: RID) -> void:  # Accept the RID argument
	is_navigation_ready = true  # Mark navigation as ready
	navigation_ready_timer.start()  # Start the timer to delay navigation queries

# Timer timeout function to confirm navigation readiness
func _on_navigation_ready_timeout() -> void:
	is_navigation_ready = true  # Confirm navigation is ready

# When the player enters the detection radius, start tracking
func _on_player_detected(body: Node) -> void:
	if body.name == "Player":  # Check if the detected body is the player
		is_tracking = true  # Start tracking the player
		print("Player detected!")  # Debug statement

# When the player leaves the detection radius, stop tracking
func _on_player_lost(body: Node) -> void:
	if body.name == "Player":  # Check if the lost body is the player
		is_tracking = false  # Stop tracking the player
		print("Player lost!")  # Debug statement

func _physics_process(delta: float) -> void:
	if is_tracking:
		_track_player()  # Follow the player with pathfinding
	else:
		_wander()  # Wander around randomly

# Function to get a random point within the navigation region bounds
func get_random_point_in_navigation_region() -> Vector2:
	if navigation_region:  # Ensure the navigation region is valid
		var nav_polygon = navigation_region.navigation_polygon
		var vertices = nav_polygon.get_vertices()
		var polygon_count = nav_polygon.get_polygon_count()
		if vertices.size() > 0 and polygon_count > 0:  # Check if the polygon has any points and polygons
			# Get a random polygon index and random point index within that polygon
			var random_polygon_index = randi() % polygon_count
			var polygon_points = nav_polygon.get_polygon(random_polygon_index)
			var random_point_index = randi() % polygon_points.size()
			return vertices[polygon_points[random_point_index]]
	return Vector2.ZERO  # Return a default value if navigation region is invalid

# Wander using NavigationAgent2D (avoiding walls and obstacles)
func _wander() -> void:
	if is_navigation_ready:  # Only proceed if the navigation map is ready
		if navigation_agent and navigation_agent.is_navigation_finished():  # Ensure navigation_agent is valid and navigation is done
			var random_pos = get_random_point_in_navigation_region()  # Get a random point in the navigation region
			navigation_agent.set_target_position(random_pos)  # Set the target position to the random point

		# Move towards the next path position
		if navigation_agent:  # Ensure navigation_agent is valid before accessing
			var wander_direction = navigation_agent.get_next_path_position() - global_position
			if wander_direction.length() > 0:  # Only move if there’s a valid direction
				velocity = wander_direction.normalized() * speed
				move_and_slide()  # Apply movement
				update_animation(velocity)

# Track the player using NavigationAgent2D for pathfinding
func _track_player() -> void:
	if is_navigation_ready:  # Only proceed if the navigation map is ready
		if navigation_agent and navigation_agent.is_navigation_finished():  # Ensure navigation_agent is valid and navigation is done
			var target_position = GameGlobals.player_position  # Get the player's position from the global variable
			navigation_agent.set_target_position(target_position)  # Update target to player’s position
			var next_position = navigation_agent.get_next_path_position()
			var direction_to_target = (next_position - global_position).normalized()
			if direction_to_target.length() > 0:  # Only move if there's a direction to move
				velocity = direction_to_target * speed
				move_and_slide()  # Apply movement
				update_animation(velocity)
			else:
				print("Enemy reached the target position!")

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
