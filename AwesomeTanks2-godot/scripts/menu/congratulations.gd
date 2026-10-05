extends Control
## Congratulations — 通关祝贺界面（对应 H5 MenuCongratulations）

const FONT: Font = preload("res://fonts/gunplay.ttf")

@onready var totalScore: Label = $Design/TotalScore


func _ready() -> void:
	totalScore.add_theme_font_override("font", FONT)
	var total := Game.getTotalPoints()
	totalScore.text = " %d Points " % total
	Audio.playMusic("music_congratulations.mp3")


func onContinuePressed() -> void:
	Audio.playButtonDown()
	Audio.stopMusic()
	Game.changeScene(Settings.SCENE_TITLE)
