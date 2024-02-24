### Obstacles.gd

extends Area3D

# Advanced obstacles
var advanced_obstacles = []

# Node Refs
@onready var damage_sfx = $Sounds/DamageSFX

func _ready():
	spawn_obstacle()
	
# Spawn obstacle	
func spawn_obstacle():
	var obstacle_resource = null
	if randf() < Global.advanced_obstacle_spawn_chance:
		obstacle_resource = Global.advanced_obstacle_resources[randi() % Global.advanced_obstacle_resources.size()]
	else:
		obstacle_resource = Global.obstacle_resources[randi() % Global.obstacle_resources.size()]
		
	var obstacle_instance = obstacle_resource.instantiate()
	
	# If it's an advanced obstacle, move it
	if obstacle_resource in Global.advanced_obstacle_resources:
		var height_above_platform = 1.2
		obstacle_instance.transform.origin.y += height_above_platform
		move_obstacle(obstacle_instance)
		
	add_child(obstacle_instance)
	
# Player and Obstacle collision
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if Global.lives > 0:
			Global.lives -= 1
			Global.lives_updated.emit()
			damage_sfx.play()
			print("Deducting Lives")
		else:
			print("Game over")
		
# Move Advanced Obstacles
func move_obstacle(obstacle_instance):
	var speed = -3
	# Store the obstacle instance and its speed in a dictionary
	var obstacle_data = {"instance": obstacle_instance, "speed": speed}
	# Add the obstacle data to an array to keep track of all moving obstacles
	advanced_obstacles.append(obstacle_data)
	
func _process(delta):
	if Global.game_started:
		# Update the position of all moving obstacles
		for obstacle_data in advanced_obstacles:
			var obstacle = obstacle_data["instance"]
			var speed = obstacle_data["speed"]
			obstacle.transform.origin += Vector3(0, 0, speed * delta)
	
