### HUD.gd

extends CanvasLayer

# Node refs
@onready var score_label = $Score/ReferenceRect/Label
@onready var level_time_label = $Time/ReferenceRect/Label
@onready var jump_boost_label = $Jump/ReferenceRect/Label

func _ready():
	Global.score_updated.connect(_update_score)
	Global.level_time_updated.connect(_update_time)
	Global.jump_boost_updated.connect(_update_jump_boost)
	_update_score()
	_update_time()
	_update_jump_boost()
	
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

