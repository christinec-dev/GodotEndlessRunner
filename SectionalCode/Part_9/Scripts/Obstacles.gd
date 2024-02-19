### Obstacles.gd

extends Area3D

func _ready():
	spawn_obstacle()
	
# Spawn obstacle	
func spawn_obstacle():
	var obstacle_resource = null
	obstacle_resource = Global.obstacle_resources[randi() % Global.obstacle_resources.size()]
	var obstacle_instance = obstacle_resource.instantiate()
	add_child(obstacle_instance)
	
# Player and Obstacle collision
func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Deducting Lives")
		
