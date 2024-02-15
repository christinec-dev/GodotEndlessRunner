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
