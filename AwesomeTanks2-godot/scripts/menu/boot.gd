extends Control
## Boot — 加载场景（与 H5 效果图一致）
## 状态 1：Loading... 文字 + 绿色进度条推进
## 状态 2：进度满 → Loading 组隐藏 → Play 按钮显示 → 点按进 Title

# ProgressHolder 宽度 360，BarAmmoClip 左右各 3px 内边距 → 填充宽 354
const _INNER_PAD_LEFT: float = 3.0
const _INNER_WIDTH: float = 354.0
const _PROGRESS_SPEED: float = 1.5

@onready var _ammo_clip: Control = $ProgressHolder/BarAmmoClip
@onready var _loading_group = $ProgressHolder
@onready var _play_btn: TextureButton = $PlayBtn

var _progress: float = 0.0
var _loaded: bool = false

func _ready() -> void:
	# 初始：Loading 组显示，Play 隐藏
	_loading_group.visible = true
	_play_btn.visible = false
	_update_progress_visual(0.0)
	_load_assets()

func _process(delta: float) -> void:
	if not _loaded:
		_progress = min(100.0, _progress + _PROGRESS_SPEED * 60.0 * delta)
		_update_progress_visual(_progress)
		if _progress >= 100.0:
			_loaded = true
			_on_load_finished()

func _update_progress_visual(pct: float) -> void:
	var right: float = _INNER_PAD_LEFT + _INNER_WIDTH * clamp(pct, 0.0, 100.0) / 100.0
	_ammo_clip.offset_right = right

func _on_load_finished() -> void:
	_loading_group.visible = false
	_play_btn.visible = true

func _load_assets() -> void:
	# TODO: ResourceLoader.load_threaded_request 预加载图集/音效
	pass

func _on_play_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_TITLE)
