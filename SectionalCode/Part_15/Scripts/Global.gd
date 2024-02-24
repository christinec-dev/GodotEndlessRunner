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
		"spawn_chance": 0.02
	}
}
var collectible_scene = preload("res://Scenes/Collectibles.tscn")

# Advanced Obstacles
var advanced_obstacle_resources = [
	preload("res://Resources/AdvancedObstacles/bee.tscn"),
	preload("res://Resources/AdvancedObstacles/rotating_log.tscn")
]
var advanced_obstacle_spawn_chance = 0

# Level variables
var score = 0
var level_time = 20
var jump_boost_count = 0
var lives = 3
var level = 1
var game_started = false

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

# New Game
func new_game():
	reset_default_values()
	level = 1
	level_time = default_level_time
	obstacle_spawn_chance = 0.5
	advanced_obstacle_spawn_chance = 0
	save_game() 
	
# Level Pass
func level_up():
	# Increase level and spawn chances
	level += 1
	obstacle_spawn_chance = min(obstacle_spawn_chance + obstacle_spawn_increase_per_level * (level - 1), 1.0)
	advanced_obstacle_spawn_chance += obstacle_spawn_increase_per_level
	# Check if the score in the previous level met the requirement
	if score >= score_requirement:
		score_requirement_reached = true
	# Reset for next level
	reset_default_values()
	# Save game
	save_game()

# Level Fail
func retry_level():
	reset_default_values()
	# Save game
	save_game()
	
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
	obstacle_spawn_chance = obstacle_spawn_chance
	advanced_obstacle_spawn_chance = advanced_obstacle_spawn_chance
	# Emit signals to update the game state
	score_updated.emit()
	level_time_updated.emit()
	jump_boost_updated.emit()
	lives_updated.emit()
	level_updated.emit()

# Saving/Loading variables
const SAVE_PATH = "user://dock_roll_save.cfg"
var save_data = ConfigFile.new()

# Save Game Logic
func save_game():
	save_data.clear()  # Clear previous data

	# Store your data under a section and key
	save_data.set_value("game", "score", score)
	save_data.set_value("game", "level_time", level_time)
	save_data.set_value("game", "jump_boost_count", jump_boost_count)
	save_data.set_value("game", "lives", lives)
	save_data.set_value("game", "level", level)
	save_data.set_value("game", "obstacle_spawn_chance", obstacle_spawn_chance)
	save_data.set_value("game", "advanced_obstacle_spawn_chance", advanced_obstacle_spawn_chance)
	save_data.set_value("game", "score_requirement_reached", score_requirement_reached)
	
	# Save game
	var error = save_data.save(SAVE_PATH)
	if error == OK:
		print("Game saved successfully.")
	else:
		print("Failed to save game:", error)

# Load Game Logic
func load_game():
	var error = save_data.load(SAVE_PATH)
	if error == OK:
		score = save_data.get_value("game", "score", 0)
		level_time = save_data.get_value("game", "level_time", default_level_time)
		jump_boost_count = save_data.get_value("game", "jump_boost_count", 0)
		lives = save_data.get_value("game", "lives", 3)
		level = save_data.get_value("game", "level", 1)
		obstacle_spawn_chance = save_data.get_value("game", "obstacle_spawn_chance", 0.5)
		advanced_obstacle_spawn_chance = save_data.get_value("game", "advanced_obstacle_spawn_chance", 0)
		score_requirement_reached = save_data.get_value("game", "score_requirement_reached", false)

		# Emit signals to update HUD and other game elements
		score_updated.emit()
		level_time_updated.emit()
		jump_boost_updated.emit()
		lives_updated.emit()
		level_updated.emit()
		update_results.emit()
		
		print("Game loaded successfully.")
	else:
		print("Failed to load game:", error)
