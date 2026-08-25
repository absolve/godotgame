extends Control
## Congratulations — 通关祝贺界面（对应原项目 MenuCongratulations）

@onready var _total_score: Label = $Design/VBox/TotalScore

func _ready() -> void:
	var total := Game.get_total_points()
	_total_score.text = "Total score: %d Pts." % total
	Audio.play_music("music_congratulations.mp3")

func _on_continue_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_TITLE)
