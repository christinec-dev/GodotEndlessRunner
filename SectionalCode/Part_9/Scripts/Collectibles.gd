### Collectibles.gd

extends Area3D

var collectible_name 
var collectibles

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# apply effect
		queue_free()

# Instantiate object		
func set_collectible_type(type):
	collectibles = $Collectible
	collectible_name = type
	var collectible_data = Global.collectibles_resources[type]
	var collectible_resource = collectible_data["scene"]
	var collectible_item = collectible_resource.instantiate()
	collectibles.add_child(collectible_item)
