extends Control
## LevelSelect — 关卡选择界面（对应 H5 MenuLevels）
##
## 按钮不再写死在场景里，而是按关卡总数动态生成到 Design/BtnGrid（5 列网格），
## 所以关卡数不再被 15 卡住。
## 按钮底图不含数字（见 sprites/atlas/level_btn_*.png），关卡号由 LevelBtn 的 Label 绘制。

const LEVEL_BTN_SCENE := preload("res://scenes/level_btn.tscn")

@onready var grid: GridContainer = $Design/BtnGrid
@onready var totalScore: Label = $Design/TotalScore

var levelBtns: Array = []


func _ready() -> void:
	Audio.playMusic("music_menu.mp3")
	buildButtons()
	refreshStates()
	totalScore.text = " Total score: %d Pts. " % Game.getTotalPoints()

## 关卡总数 = data/levels.gd 里定义的数量（新增关卡后这里自动跟上，不需要改场景）
static func totalLevelCount() -> int:
	return maxi(ATLevels.LEVELS.size(), Settings.LEVEL_COUNT)


## 按关卡总数生成按钮
func buildButtons() -> void:
	for i in range(totalLevelCount()):
		var btn = LEVEL_BTN_SCENE.instantiate()
		btn.name = "Btn%d" % (i + 1)
		btn.levelNum = i + 1
		btn.clicked.connect(onLevelClicked)
		grid.add_child(btn)
		levelBtns.append(btn)


func refreshStates() -> void:
	# unlocked = 已通关关卡数（0 表示还没玩过第 1 关）
	var unlocked := int(Game.current["game"]["levels"])
	for btn in levelBtns:
		btn.refreshState(unlocked)


func onLevelClicked(index: int) -> void:
	Game.gotoLevel(index)


func onBackPressed() -> void:
	Audio.playButtonDown()
	Game.changeScene(Settings.SCENE_UPGRADES)
