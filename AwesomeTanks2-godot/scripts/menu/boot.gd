extends Control
## Boot — 加载场景（与 H5 效果图一致）
## 状态 1：Loading... 文字 + 绿色进度条推进
## 状态 2：进度满 → Loading 组隐藏 → Play 按钮显示 → 点按进 Title

# ProgressHolder 宽度 360，BarAmmoClip 左右各 3px 内边距 → 填充宽 354
const INNER_PAD_LEFT: float = 3.0
const INNER_WIDTH: float = 354.0
const PROGRESS_SPEED: float = 1.5

@onready var ammoClip: Control = $ProgressHolder/BarAmmoClip
@onready var loadingGroup = $ProgressHolder
@onready var playBtn: TextureButton = $PlayBtn

var progress: float = 0.0
var loaded: bool = false

func _ready() -> void:
	# 初始：Loading 组显示，Play 隐藏
	loadingGroup.visible = true
	playBtn.visible = false
	updateProgressVisual(0.0)
	loadAssets()

func updateProgressVisual(pct: float) -> void:
	var right: float = INNER_PAD_LEFT + INNER_WIDTH * clamp(pct, 0.0, 100.0) / 100.0
	ammoClip.offset_right = right

func onLoadFinished() -> void:
	loadingGroup.visible = false
	playBtn.visible = true

func loadAssets() -> void:
	# TODO: ResourceLoader.load_threaded_request 预加载图集/音效
	pass

func onPlayPressed() -> void:
	Audio.playButtonDown()
	Game.changeScene(Settings.SCENE_TITLE)

func _process(delta: float) -> void:
	if not loaded:
		progress = min(100.0, progress + PROGRESS_SPEED * 60.0 * delta)
		updateProgressVisual(progress)
		if progress >= 100.0:
			loaded = true
			onLoadFinished()
