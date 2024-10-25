extends CharacterBody2D

@export var speed: float = 200  # Movement speed
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D  # Reference to NavigationAgent2D node
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D  # Reference to the navigation region
@onready var wall_check_timer: Timer = $wallCheck  # Reference to the wall check timer node

var is_navigation_ready: bool = false  # Tracks whether the navigation map is ready
var stuck_time: float = 0.2  # Time to consider the enemy stuck against a wall
var stuck_counter: float = 0.0  # Counter to track how long the enemy has been stuck

func _ready() -> void:
	wall_check_timer.wait_time = stuck_time  # Set the timer wait time
	wall_check_timer.start()  # Start the timer

func _physics_process(delta: float) -> void:
	if is_navigation_ready:
		_wander()  # Call the wander function

func _wander() -> void:
	if navigation_agent.is_navigation_finished():  # Ensure navigation_agent is valid and navigation is done
		var random_pos = get_random_point_in_navigation_region()  # Get a random point in the navigation region
		navigation_agent.set_target_position(random_pos)  # Set the target position to the random point
		stuck_counter = 0.0  # Reset stuck counter

	# Move towards the next path position
	var wander_direction = navigation_agent.get_next_path_position() - global_position
	if wander_direction.length() > 0:  # Only move if there’s a valid direction
		velocity = wander_direction.normalized() * speed
		move_and_slide()  # Apply movement

		update_animation(velocity)  # Update animations based on movement

# Function to get a random point within the navigation region bounds
func get_random_point_in_navigation_region() -> Vector2:
	if navigation_region:  # Ensure the navigation region is valid
		var nav_polygon = navigation_region.navigation_polygon
		var vertices = nav_polygon.get_vertices()
		var polygon_count = nav_polygon.get_polygon_count()
		if vertices.size() > 0 and polygon_count > 0:  # Check if the polygon has any points and polygons
			var random_polygon_index = randi() % polygon_count
			var polygon_points = nav_polygon.get_polygon(random_polygon_index)
			var random_point_index = randi() % polygon_points.size()
			return vertices[polygon_points[random_point_index]]
	return Vector2.ZERO  # Return a default value if navigation region is invalid

func _on_wall_check_timeout() -> void:
	if is_colliding():  # Check for collision
		stuck_counter += stuck_time  # Increment the stuck counter
		if stuck_counter >= stuck_time:
			# If stuck for too long, choose a new random direction
			var new_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			navigation_agent.set_target_position(global_position + new_direction * 100)  # Move in the new direction
			stuck_counter = 0.0  # Reset stuck counter
	else:
		stuck_counter = 0.0  # Reset stuck counter if not colliding

func is_colliding() -> bool:
	# Implement your collision detection logic here
	# For example, you can use raycasting or area checks
	return false  # Placeholder for collision check, replace with actual implementation

# Update animations based on movement direction
func update_animation(direction: Vector2) -> void:
	var anim = $AnimatedSprite2D
	anim.flip_h = direction.x < 0

	if direction.length() > 0:
		match direction:
			Vector2.RIGHT, Vector2.LEFT:
				anim.play("walkSide")
			Vector2.DOWN:
				anim.play("walkF")
			Vector2.UP:
				anim.play("walkB")
	else:
		anim.play("idleFaceFront")
