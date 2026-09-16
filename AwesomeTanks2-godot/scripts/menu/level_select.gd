extends Control
## LevelSelect — 关卡选择界面（对应 H5 MenuLevels）
##
## 按钮不再写死在场景里，而是按关卡总数动态生成到 Design/BtnGrid（5 列网格），
## 所以关卡数不再被 15 卡住。
## 按钮底图不含数字（见 sprites/atlas/level_btn_*.png），关卡号由 LevelBtn 的 Label 绘制。

const LEVEL_BTN_SCENE := preload("res://scenes/level_btn.tscn")

@onready var _grid: GridContainer = $Design/BtnGrid
@onready var _total_score: Label = $Design/TotalScore

var _level_btns: Array = []


func _ready() -> void:
	Audio.play_music("music_menu.mp3")
	_build_buttons()
	_refresh_states()
	_total_score.text = " Total score: %d Pts. " % Game.get_total_points()


## 关卡总数 = data/levels.gd 里定义的数量（新增关卡后这里自动跟上，不需要改场景）
static func total_level_count() -> int:
	return maxi(ATLevels.LEVELS.size(), Settings.LEVEL_COUNT)


## 按关卡总数生成按钮
func _build_buttons() -> void:
	for i in range(total_level_count()):
		var btn = LEVEL_BTN_SCENE.instantiate()
		btn.name = "Btn%d" % (i + 1)
		btn.level_num = i + 1
		btn.clicked.connect(_on_level_clicked)
		_grid.add_child(btn)
		_level_btns.append(btn)


func _refresh_states() -> void:
	# unlocked = 已通关关卡数（0 表示还没玩过第 1 关）
	var unlocked := int(Game.current["game"]["levels"])
	for btn in _level_btns:
		btn.refresh_state(unlocked)


func _on_level_clicked(index: int) -> void:
	Game.goto_level(index)


func _on_back_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_UPGRADES)
