### World.gd

extends StaticBody3D

# Node reference
@onready var platforms = $Platforms
@onready var obstacles = $Obstacles

# Platform vars
var last_platform_position = Vector3()
var last_air_platform_position = Vector3()
var platform_length = 4
var initial_platform_count = 8
var cleanup_object_count = 8
var player

func _ready():
	initialize_game_elements()
	
# Initial game state when level loads
func initialize_game_elements():
	player = get_node_or_null("/root/Main/Player") 
	player.position = Vector3(0, 0, 0)
	last_air_platform_position = Vector3(0, 0, 5)
	# Spawn the initial objects
	for i in range(initial_platform_count):
		spawn_platform_segment()
		spawn_air_platform_segments()
		spawn_obstacle()   
	
# Spawn and cleanup objects
func _on_timer_timeout():
	var player_position = player.global_transform.origin
	# Check if the player is moving by verifying the velocity on the X or Z axis
	if player.velocity.length() > 0 and player_position.z <= last_platform_position.z - initial_platform_count:
		spawn_platform_segment()
		spawn_air_platform_segments()
		spawn_obstacle()   
	cleanup_old_objects()
	
# Spawn platforms
func spawn_platform_segment():
	# Randomly select a platform resource
	var platform_resource = Global.platform_resources[randi() % Global.platform_resources.size()]
	var new_platform = platform_resource.instantiate()
	new_platform.transform.origin = last_platform_position
	platforms.add_child(new_platform)
	# Update the position for the next path segment
	last_platform_position += Vector3(0, 0, platform_length)
	
# Spawn air platforms
func spawn_air_platform_segments():
	# Decide randomly whether to spawn an in-air platform or a series of platforms
	if randf() < Global.air_platform_spawn_chance:
		# Decide the number of platforms to form a path in the air
		var number_of_in_air_platforms = randi_range(3, 5)  
		var y_position = 1.5 # Height above the ground platforms
		# Choose a random X position for the entire sequence
		var x_position = randi_range(-1, 1) 
		for i in range(number_of_in_air_platforms):
			var platform_resource = Global.air_platforms_resources[randi() % Global.air_platforms_resources.size()]
			var new_platform = platform_resource.instantiate()
			var z_position = last_air_platform_position.z + i
			new_platform.transform.origin = Vector3(x_position, y_position, z_position)
			platforms.add_child(new_platform)
		# Update the position to be after the last spawned in-air platform
		last_air_platform_position.z += platform_length * number_of_in_air_platforms
	
# Spawn Obstacles
func spawn_obstacle():
	# Decide how many obstacles to spawn in a row (e.g., 1 to 3)
	var possible_x_positions = [-1, 0, 1]
	possible_x_positions.shuffle()
	var obstacles_in_row = min(randi() % 3 + 1, possible_x_positions.size())
	var spacing = 1.2  # obstacle spacing in between
	# Spawn random obstacles
	if randf() < Global.obstacle_spawn_chance:
		for i in range(obstacles_in_row):
			var obstacle_instance = Global.obstacle_scene.instantiate()
			var x_position_index = i % possible_x_positions.size()
			var x_position = possible_x_positions[x_position_index]
			obstacle_instance.transform.origin = last_platform_position + Vector3(x_position * spacing, 0, platform_length)
			obstacles.add_child(obstacle_instance)
	
# Cleans up platforms & objects behind player
func cleanup_old_objects():
	# Remove platforms
	for platform in platforms.get_children():
		if platform.global_transform.origin.z < player.global_transform.origin.z - cleanup_object_count:
			platform.queue_free() # Remove the platform from the scene
			print("Removed platform: ", platform.name, " at position: ", platform.global_transform.origin.z)

	# Remove obstacles
	for obstacle in obstacles.get_children():
		if obstacle.global_transform.origin.z < player.global_transform.origin.z - cleanup_object_count:
			obstacle.queue_free() # Remove the obstacle from the scene
