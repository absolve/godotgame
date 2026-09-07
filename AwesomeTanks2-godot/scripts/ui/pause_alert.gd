extends Control
## PauseAlert —— 暂停面板（对应 H5 PauseAlert：pause_label + CONTINUE）
## 额外复用项目已有 sound_btn.tscn 提供 音乐/音效 开关（暂停中仍可调）。
## 纯视觉组件：只发信号，由关卡根脚本决定暂停/恢复逻辑。

signal continue_pressed
signal music_toggled(on: bool)
signal sound_toggled(on: bool)

@onready var _music_btn: TextureButton = $Center/Panel/Toggles/MusicBtn
@onready var _sound_btn: TextureButton = $Center/Panel/Toggles/SoundBtn


func _ready() -> void:
	visible = false
	($Center/Panel/ContinueBtn as TextureButton).pressed.connect(_on_continue)
	_music_btn.toggled.connect(_on_music_toggled)
	_sound_btn.toggled.connect(_on_sound_toggled)


func open() -> void:
	visible = true


func close() -> void:
	visible = false


## 供根脚本同步音乐/音效开关状态（例如从 HUD 主按钮切换后）
func set_audio_states(music_on: bool, sound_on: bool) -> void:
	_music_btn.set_pressed_no_signal(music_on)
	_sound_btn.set_pressed_no_signal(sound_on)


func _on_continue() -> void:
	Audio.play_button_down()
	continue_pressed.emit()


func _on_music_toggled(on: bool) -> void:
	music_toggled.emit(on)


func _on_sound_toggled(on: bool) -> void:
	sound_toggled.emit(on)
