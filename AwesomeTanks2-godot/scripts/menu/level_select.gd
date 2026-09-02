extends Control
## LevelSelect — 关卡选择界面（对应 H5 MenuLevels）
## 15 个关卡按钮直接在 LevelSelect.tscn 中定义（LevelBtn 实例）
## 按钮状态（normal/active/disabled）由 LevelBtn 脚本根据解锁进度动态刷新

const FONT: Font = preload("res://fonts/gunplay.ttf")

@onready var _total_score: Label = $Design/TotalScore

var _level_btns: Array = []


func _ready() -> void:
	Audio.play_music("music_menu.mp3")
	_total_score.add_theme_font_override("font", FONT)
	# 收集所有关卡按钮（按 level_num 排序）
	for child in $Design.get_children():
		if child.has_method("refresh_state") and child.has_method("get"):
			var num: int = child.level_num
			if num >= 1 and num <= 15:
				_level_btns.append(child)
	_level_btns.sort_custom(func(a, b): return a.level_num < b.level_num)
	# 刷新每个按钮的状态
	var unlocked := int(Game.current["game"]["levels"])
	for btn in _level_btns:
		btn.refresh_state(unlocked)
	_total_score.text = " Total score: %d Pts. " % Game.get_total_points()


func _on_level_clicked(index: int) -> void:
	Game.goto_level(index)


func _on_back_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_UPGRADES)
