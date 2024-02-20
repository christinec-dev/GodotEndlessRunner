### Player.gd

extends CharacterBody3D

# Animation State booleans
var is_jumping = false
var game_starts = false
var game_won = false

# Movement variables
var speed = 5.0
var jump_velocity = 10.0 # how high
const jump_speed = 3.0 # how fast
const gravity = 20

# Node refs
@onready var game_timer = $GameTimer

func _physics_process(delta):
	handle_movement(delta)
	
func handle_movement(delta):
	if game_starts and not game_won:
		# Handle horizontal movement
		var input_right = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		velocity.x = input_right * speed

		# Handle vertical movement (jumping)
		if is_on_floor():
			if Input.is_action_just_pressed("ui_jump"):
				if Global.jump_boost_count > 0:
					jump_velocity = 13
					Global.jump_boost_count -= 1
					Global.jump_boost_updated.emit()
				else: 
					jump_velocity = 10
				velocity.y = jump_velocity
				is_jumping = true
			else:
				is_jumping = false
		else:
			velocity.y -= gravity * delta  # Apply gravity

		# Adjust forward movement if jumping
		velocity.z = jump_speed if is_jumping else speed

		# Move the character
		move_and_slide()

# Start game
func _input(event):
	if event.is_action_pressed("ui_accept"):
		game_starts = true
		game_timer.start()

# Game timer
func _on_game_timer_timeout():
	Global.level_time -= 1
	Global.level_time_updated.emit()
	if Global.level_time <= 0:
		print("game over")
		
# Player effects
func apply_effect(effect_name):
	match effect_name:
		"increase_score":
			Global.score += 1
			Global.score_updated.emit()
			print("Score ", Global.score)
		"boost_jump":
			Global.jump_boost_count += 1
			Global.jump_boost_updated.emit()
			print("Jump Boost ", Global.jump_boost_count)
		"decrease_time":
			if Global.level_time >= 10:
				Global.level_time -= 10
				Global.level_time_updated.emit()
				print("Level Time ", Global.level_time)
