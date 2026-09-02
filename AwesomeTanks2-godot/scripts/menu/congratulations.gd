extends Control
## Congratulations — 通关祝贺界面（对应 H5 MenuCongratulations）

const FONT: Font = preload("res://fonts/gunplay.ttf")

@onready var _total_score: Label = $Design/TotalScore


func _ready() -> void:
	_total_score.add_theme_font_override("font", FONT)
	var total := Game.get_total_points()
	_total_score.text = " %d Points " % total
	Audio.play_music("music_congratulations.mp3")


func _on_continue_pressed() -> void:
	Audio.play_button_down()
	Audio.stop_music()
	Game.change_scene(Settings.SCENE_TITLE)
