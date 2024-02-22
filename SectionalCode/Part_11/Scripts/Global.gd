### Global.gd

extends Node

# Platform Resources
var platform_resources = [
	preload("res://Resources/Platforms/dirt_platform.tscn"),
	preload("res://Resources/Platforms/grass_platform.tscn"),
	preload("res://Resources/Platforms/wood_platform.tscn")
]

# Air Platform Resources
var air_platforms_resources = [
	preload("res://Resources/Platforms/air_platform.tscn")
]
var air_platform_spawn_chance = 0.5

# Obstacle Resources
var obstacle_resources = [
	preload("res://Resources/Obstacles/crate.tscn"),
	preload("res://Resources/Obstacles/rock_1.tscn"),
	preload("res://Resources/Obstacles/rock_2.tscn"),
	preload("res://Resources/Obstacles/rock_3.tscn"),
	preload("res://Resources/Obstacles/tree_stump.tscn"),
]
var obstacle_scene = preload("res://Scenes/Obstacles.tscn")
var obstacle_spawn_chance = 0.5

# Environmental Resources
var environment_resources = {
	"clouds": [
		preload("res://Resources/Environmentals/cloud_1.tscn"),
		preload("res://Resources/Environmentals/cloud_2.tscn"),
		preload("res://Resources/Environmentals/cloud_3.tscn")
		],
	"ground": [
		preload("res://Resources/Environmentals/lilypad.tscn")
		],
	"water": [
		preload("res://Resources/Environmentals/water_4.tscn")
	]
}

# Collectible resources
var collectibles_resources = {
	"coin": {
		"scene": preload("res://Resources/Collectibles/coin.tscn"),
		"effect": "increase_score",
		"spawn_chance": 0.07
	},
	"gem": {
		"scene": preload("res://Resources/Collectibles/gem.tscn"),
		"effect": "boost_jump",
		"spawn_chance": 0.04
	},
	"flag": {
		"scene": preload("res://Resources/Collectibles/flag.tscn"),
		"effect": "decrease_time",
		"spawn_chance": 0.04
	}
}
var collectible_scene = preload("res://Scenes/Collectibles.tscn")

# Level variables
var score = 0
var level_time = 20
var jump_boost_count = 0
var lives = 3
var level = 1

# Signals
signal score_updated
signal level_time_updated
signal jump_boost_updated
signal lives_updated
signal level_updated
signal update_results

# Progression Variables
var obstacle_spawn_increase_per_level = 0.05
var score_requirement = 0 
var min_score_requirement = 10
var max_score_requirement = 50 
var final_score_requirement = 0
var score_requirement_reached = false
var time_reduction_bonus = 10
var default_level_time = 20  # Starting time for level 1

# Level Pass
func level_up():
	# Increase level and spawn chances
	level += 1
	obstacle_spawn_chance = min(obstacle_spawn_chance + obstacle_spawn_increase_per_level * (level - 1), 1.0)
	# Check if the score in the previous level met the requirement
	if score >= score_requirement:
		score_requirement_reached = true
	# Reset for next level
	reset_default_values()

# Level Fail
func retry_level():
	reset_default_values()
	
# Level Reset
func reset_default_values():
	if score_requirement_reached:
		# Apply time reduction for the next level
		level_time = default_level_time + (level - 1) * 10 - time_reduction_bonus
		score_requirement_reached = false 
	else:
		# Apply time without reduction for the next level
		level_time = default_level_time + (level - 1) * 10
	score_requirement = randi_range(min_score_requirement, max_score_requirement)
	score = 0
	jump_boost_count = 0
	lives = 3
	# Emit signals to update the game state
	score_updated.emit()
	level_time_updated.emit()
	jump_boost_updated.emit()
	lives_updated.emit()
	level_updated.emit()
