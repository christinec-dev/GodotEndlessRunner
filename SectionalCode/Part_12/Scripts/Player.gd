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
@onready var game_over_screen = $HUD/GameOverScreen
@onready var game_results_label = $HUD/GameOverScreen/Container/Results/Label
@onready var progress_button = $HUD/GameOverScreen/Container/Results/ProgressButton
@onready var world = get_node("/root/Main/World")

# Game State
enum game_state {CONTINUE, RETRY}
var current_state

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
		
		# Check for air platform collision
		if velocity.z == 0:
			check_for_platform_collisions()	

# Air Platform Collisions
func check_for_platform_collisions():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("Air_Platform"):
			# Check if the collision is close to the player's front side
			if collision.get_normal().dot(Vector3(0, 0, -1)) > 0.5: 
				Global.lives = 0
				Global.lives_updated.emit()
				game_over()
				break 
				
# Start game
func _input(event):
	if event.is_action_pressed("ui_accept"):
		game_starts = true
		game_timer.start()
		# set score requirement
		Global.score_requirement = randi_range(Global.min_score_requirement, Global.max_score_requirement)
		
# Game timer
func _on_game_timer_timeout():
	Global.level_time -= 1
	Global.level_time_updated.emit()
	if Global.level_time <= 0 or Global.lives == 0:
		game_over()
		
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

# Level Progression
func game_over():
	game_timer.stop()
	game_starts = false
	# Level Fail
	if Global.lives <= 0:
		game_won = false
		game_over_screen.visible = true
		game_results_label.text = "GAME OVER"
		progress_button.text = "RETRY"
		current_state = game_state.RETRY
	# Level Pass
	elif Global.lives >= 1 and Global.level_time <= 0:
		game_won = true
		game_over_screen.visible = true
		game_results_label.text = "LEVEL UP!"
		progress_button.text = "CONTINUE"
		current_state = game_state.CONTINUE
	Global.update_results.emit()
		
# Reset Game State		
func reset_game_state():
	is_jumping = false
	game_starts = false
	game_won = false
	# Reset UI
	game_over_screen.visible = false
	# Unpause game and load level
	world.reset_world()
	get_tree().paused = false
	
# Progress/ Retry
func _on_progress_button_pressed():
	if current_state == game_state.CONTINUE:
		reset_game_state()
		Global.level_up()
	elif current_state == game_state.RETRY:
		reset_game_state()
		Global.retry_level()
