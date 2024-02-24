### Main.gd

extends Node3D

# Node Refs
@onready var menu = $Menu
@onready var button_start = $Menu/Container/ButtonStart
@onready var level_label = $Menu/Container/LevelLabel

func _ready():
	menu.visible = true
	update_level_label()

# Show last saved lvel
func update_level_label():
	Global.load_game() 
	level_label.text = "last saved level: %d" % Global.level 
	
# Start New/Resume Game
func _on_button_start_pressed():
	if button_start.text == "NEW GAME":
		Global.new_game()
	menu.visible = false
	get_tree().paused = false

# Load Game
func _on_button_load_pressed():
	Global.load_game()
	menu.visible = false
	get_tree().paused = false

# Exit Game
func _on_button_exit_pressed():
	get_tree().quit()

# Pause Menu
func _input(event):
	if event.is_action_pressed("ui_menu"):
		update_level_label() 
		menu.visible = true
		button_start.text = "RESUME LEVEL"
		get_tree().paused = true
