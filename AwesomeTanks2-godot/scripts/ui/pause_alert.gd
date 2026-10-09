extends Control
## PauseAlert —— 暂停面板（对应 H5 PauseAlert：pause_label + CONTINUE）
## 面板里的 SoundBtn/MusicBtn 是 scenes/sound_btn.tscn 组件，开关逻辑（读存档、写 Audio、
## 状态同步）都在组件自己身上，这里不用管。
## 纯视觉组件：只发信号，由关卡根脚本决定暂停/恢复逻辑。

signal continuePressed


func _ready() -> void:
	visible = false
	($Center/Panel/ContinueBtn as TextureButton).pressed.connect(onContinue)


func open() -> void:
	visible = true


func close() -> void:
	visible = false


func onContinue() -> void:
	Audio.playButtonDown()
	continuePressed.emit()
