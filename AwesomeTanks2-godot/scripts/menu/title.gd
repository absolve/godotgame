extends Control
## Title — 主菜单界面（对应 H5 MenuTitle）
## 功能：背景+LOGO+坦克展示+Play/About按钮+右上Sound/Music开关+Credits弹窗

# 音效/音乐开关的两套贴图（toggle 时手动替换 normal）
const TEX_SOUND_ON: Texture2D = preload("res://sprites/menu/title/parts/buttons/sound_on.png.tres")
const TEX_SOUND_OFF: Texture2D = preload("res://sprites/menu/title/parts/buttons/sound_off.png.tres")
const TEX_MUSIC_ON: Texture2D = preload("res://sprites/menu/title/parts/buttons/music_on.png.tres")
const TEX_MUSIC_OFF: Texture2D = preload("res://sprites/menu/title/parts/buttons/music_off.png.tres")

@onready var _sound_btn: TextureButton = $TopRight/SoundBtn
@onready var _music_btn: TextureButton = $TopRight/MusicBtn
@onready var _credits_layer: Control = $CreditsLayer

func _ready() -> void:
	Audio.play_music("music_menu.mp3")
	# 从存档读取 sound/music 开关状态 → 设置 button_pressed + 贴图
	_refresh_sound_btn(bool(Game.current.get("game", {}).get("sound", true)))
	_refresh_music_btn(bool(Game.current.get("game", {}).get("music", true)))

# ---------- 按钮贴图刷新 ----------
func _refresh_sound_btn(on: bool) -> void:
	_sound_btn.button_pressed = on
	_sound_btn.texture_normal = TEX_SOUND_ON if on else TEX_SOUND_OFF

func _refresh_music_btn(on: bool) -> void:
	_music_btn.button_pressed = on
	_music_btn.texture_normal = TEX_MUSIC_ON if on else TEX_MUSIC_OFF

# ---------- 信号回调 ----------
func _on_play_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_UPGRADES)

func _on_sound_toggled() -> void:
	# TextureButton toggle_mode=true：每次点击按下/弹起都会触发一次 toggled
	# 这里读 button_pressed 反推当前想要的新状态（按下=启用？不，我们语义是 pressed=on）
	var want_on: bool = _sound_btn.button_pressed
	_refresh_sound_btn(want_on)
	Audio.set_sound_enabled(want_on)
	Audio.play_button_down()

func _on_music_toggled() -> void:
	var want_on: bool = _music_btn.button_pressed
	_refresh_music_btn(want_on)
	Audio.set_music_enabled(want_on)
	Audio.play_button_down()

func _on_about_pressed() -> void:
	Audio.play_button_down()
	_credits_layer.visible = true

func _on_credits_close_pressed() -> void:
	Audio.play_button_down()
	_credits_layer.visible = false
