extends Control
## Title — 标题界面（对应原项目 MenuTitle）
## 元素：背景 / Logo / 坦克图 / 升级标语 / 音效·音乐开关 / Play / About

@onready var _sound_btn: Button = $Design/TopRight/Sound
@onready var _music_btn: Button = $Design/TopRight/Music

func _ready() -> void:
	Audio.play_music("music_menu.mp3")
	_sound_btn.button_pressed = bool(Game.current["game"]["sound"])
	_music_btn.button_pressed = bool(Game.current["game"]["music"])

func _on_play_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_UPGRADES)

func _on_sound_toggled(on: bool) -> void:
	Audio.set_sound_enabled(on)

func _on_music_toggled(on: bool) -> void:
	Audio.set_music_enabled(on)

func _on_about_pressed() -> void:
	Audio.play_button_down()
	# TODO: 弹出 CreditsAlert 面板
	pass
