extends Control
## Boot — 加载场景（对应原项目 MenuLoading）
## 原流程：加载所有图集/音效 → 解码 → 显示 Play 按钮 → 点击进入 Boot(logo 闪现) → Title
## 这里用模拟进度填充，资源就绪后改用 ResourceLoader.load_threaded_request。

@onready var _progress: ProgressBar = $Design/VBox/Progress
@onready var _play: Button = $Design/VBox/Play

var _loaded: bool = false

func _ready() -> void:
	_play.visible = false
	# Play 按钮信号由 Boot.tscn 的 [connection] 自动连接，无需手动 connect
	# 模拟加载（无资源时快速填满）
	_load_assets()

func _process(_delta: float) -> void:
	if not _loaded:
		_progress.value = move_toward(_progress.value, 100.0, 2.0)
		if _progress.value >= 100.0:
			_loaded = true
			_play.visible = true

func _load_assets() -> void:
	# TODO: 用 ResourceLoader.load_threaded_request 预加载图集/音效
	pass

func _on_play_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_TITLE)
