### HUD.gd

extends CanvasLayer

# Node refs
@onready var score_label = $Score/ReferenceRect/Label
@onready var level_time_label = $Time/ReferenceRect/Label
@onready var jump_boost_label = $Jump/ReferenceRect/Label
@onready var lives_sprite = $Lives/Sprite2D
@onready var level_label = $Level/ReferenceRect/Label
@onready var level_results_label = $GameOverScreen/Container/Results/Level
@onready var score_results_label = $GameOverScreen/Container/Results/Score

func _ready():
	Global.score_updated.connect(_update_score)
	Global.level_time_updated.connect(_update_time)
	Global.jump_boost_updated.connect(_update_jump_boost)
	Global.lives_updated.connect(_update_lives)
	Global.level_updated.connect(_update_level)
	Global.update_results.connect(_update_results)
	
	_update_score()
	_update_time()
	_update_jump_boost()
	_update_lives()
	_update_level()
	_update_results()
	
# Score UI
func _update_score():
	score_label.text = str(Global.score)
	
# Time UI
func _update_time():
	var minutes = int(Global.level_time) / 60
	var seconds = int(Global.level_time) % 60
	# Format time as MM:SS
	level_time_label.text = "%02d:%02d" % [minutes, seconds]

# Jump UI
func _update_jump_boost():
	jump_boost_label.text = str(Global.jump_boost_count)

# Lives UI
func _update_lives():
	if Global.lives >= 3:
		lives_sprite.texture = preload("res://Assets/Icons/HeartFull.png")
	elif Global.lives == 2:
		lives_sprite.texture = preload("res://Assets/Icons/HeartHalf.png")
	else:
		lives_sprite.texture = preload("res://Assets/Icons/HeartEmpty.png")

# Level UI
func _update_level():
	level_label.text = str("LVL: ", Global.level)

# Game Over Screen UI
func _update_results():
	level_results_label.text = str("Level: ", Global.level)
	score_results_label.text  = str("Score: ", Global.score, " / ", Global.score_requirement)
