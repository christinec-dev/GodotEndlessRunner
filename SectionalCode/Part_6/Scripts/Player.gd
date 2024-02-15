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
