### World.gd

extends StaticBody3D

# Node reference
@onready var platforms = $Platforms
@onready var obstacles = $Obstacles
@onready var environment = $Environment

# Platform vars
var last_platform_position = Vector3()
var last_air_platform_position = Vector3()
var platform_length = 4
var initial_platform_count = 8
var cleanup_object_count = 8
var player

# Environmental variables
const min_platform_distance = 10.0
const max_platform_distance = 30.0
const left_side = -1
const right_side = 1
const min_cloud_height = -1.0
const max_cloud_height = 10.0
const ground_position = -1
const water_position = -1.5

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
		spawn_environmental_segment(last_platform_position.z)
		spawn_water(i * platform_length, water_position)
	
# Spawn and cleanup objects
func _on_timer_timeout():
	var player_position = player.global_transform.origin
	# Check if the player is moving by verifying the velocity on the X or Z axis
	if player.velocity.length() > 0 and player_position.z <= last_platform_position.z - initial_platform_count:
		spawn_platform_segment()
		spawn_air_platform_segments()
		spawn_obstacle()   
		spawn_environmental_segment(last_platform_position.z)
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
	
# Spawn water instance
func spawn_water(along_z: float, water_level: float):
	var water_resource = Global.environment_resources["water"][0] # First water scene
	var distance_from_platform = 3.0
	var water_extent = 15

	# Spawn water on the left side
	for i in range(water_extent):
		var water_instance_left = water_resource.instantiate()
		water_instance_left.transform.origin = Vector3(-distance_from_platform - (i * platform_length), water_level, along_z)
		environment.add_child(water_instance_left)

	# Spawn water on the right side
	for i in range(water_extent):
		var water_instance_right = water_resource.instantiate()
		water_instance_right.transform.origin = Vector3(distance_from_platform + (i * platform_length), water_level, along_z)
		environment.add_child(water_instance_right)

func spawn_ground_and_clouds(asset_category, along_z, y_pos):
	var random_index = randi() % asset_category.size()
	var instance = asset_category[random_index].instantiate()
	var side = left_side if randi() % 2 == 0 else right_side
	var distance_from_platform = randf_range(min_platform_distance, max_platform_distance)
	
	# Set the position
	instance.transform.origin = Vector3(
		side * distance_from_platform,  # X position next to platform
		y_pos,                     # Y position
		along_z                    # Z position along the path
	)
	# Add instance to the environment node
	environment.add_child(instance)
	
func spawn_environmental_segment(along_z: float):
	# Spawn clouds
	spawn_ground_and_clouds(
		Global.environment_resources["clouds"],
		along_z,
		randf_range(min_cloud_height, max_cloud_height)
	)
	# Spawn ground instances
	spawn_ground_and_clouds(
		Global.environment_resources["ground"],
		along_z,
		ground_position
	)
	# Spawn water on both sides of the path
	spawn_water(along_z, water_position) 
	
# Cleans up platforms & objects behind player
func cleanup_old_objects():
	# Remove platforms
	for platform in platforms.get_children():
		if platform.global_transform.origin.z < player.global_transform.origin.z - cleanup_object_count:
			platform.queue_free() # Remove the platform from the scene

	# Remove obstacles
	for obstacle in obstacles.get_children():
		if obstacle.global_transform.origin.z < player.global_transform.origin.z - cleanup_object_count:
			obstacle.queue_free() # Remove the obstacle from the scene

	# Remove environmentals
	for element in environment.get_children():
		if element.global_transform.origin.z < player.global_transform.origin.z - cleanup_object_count:
			element.queue_free()
