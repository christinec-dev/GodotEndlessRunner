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

# Signals
signal score_updated
signal level_time_updated
signal jump_boost_updated
