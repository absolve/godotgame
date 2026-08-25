extends Control
## LevelSelect — 关卡选择界面（对应原项目 MenuLevels）
## 5×3 关卡按钮网格（已解锁/当前/锁定）+ 总分 + 返回升级菜单

@onready var _grid: GridContainer = $Design/Grid
@onready var _total_score: Label = $Design/TotalScore

func _ready() -> void:
	Audio.play_music("music_menu.mp3")
	_populate()
	_total_score.text = " Total score: %d Pts. " % Game.get_total_points()

func _populate() -> void:
	for c in _grid.get_children():
		c.queue_free()
	var unlocked := int(Game.current["game"]["levels"])
	for i in Settings.LEVEL_COUNT:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(80, 60)
		btn.text = "%d" % (i + 1)
		var is_unlocked := i < unlocked
		var is_current := i == unlocked
		btn.disabled = not is_unlocked
		if is_current:
			btn.modulate = Color(1, 0.85, 0.3)
		elif not is_unlocked:
			btn.modulate = Color(0.4, 0.4, 0.4)
		if is_unlocked:
			btn.pressed.connect(_on_level_pressed.bind(i))
		_grid.add_child(btn)

func _on_level_pressed(index: int) -> void:
	Audio.play_button_down()
	Game.goto_level(index)

func _on_back_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_UPGRADES)
