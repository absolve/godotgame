extends Control
## PauseAlert —— 暂停面板（对应 H5 PauseAlert：pause_label + CONTINUE）
## 额外复用项目已有 sound_btn.tscn 提供 音乐/音效 开关（暂停中仍可调）。
## 纯视觉组件：只发信号，由关卡根脚本决定暂停/恢复逻辑。

signal continuePressed
signal musicToggled(on: bool)
signal soundToggled(on: bool)

@onready var musicBtn: TextureButton = $Center/Panel/Toggles/MusicBtn
@onready var soundBtn: TextureButton = $Center/Panel/Toggles/SoundBtn


func _ready() -> void:
	visible = false
	($Center/Panel/ContinueBtn as TextureButton).pressed.connect(onContinue)
	musicBtn.toggled.connect(onMusicToggled)
	soundBtn.toggled.connect(onSoundToggled)


func open() -> void:
	visible = true


func close() -> void:
	visible = false


## 供根脚本同步音乐/音效开关状态（例如从 HUD 主按钮切换后）
func setAudioStates(musicOn: bool, soundOn: bool) -> void:
	musicBtn.set_pressed_no_signal(musicOn)
	soundBtn.set_pressed_no_signal(soundOn)


func onContinue() -> void:
	Audio.playButtonDown()
	continuePressed.emit()


func onMusicToggled(on: bool) -> void:
	musicToggled.emit(on)


func onSoundToggled(on: bool) -> void:
	soundToggled.emit(on)
