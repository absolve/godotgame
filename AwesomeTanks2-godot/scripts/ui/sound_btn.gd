extends TextureButton
## SoundBtn —— 音效 / 音乐开关按钮（scenes/sound_btn.tscn，被标题、升级、暂停面板复用）
##
## 组件自己负责整件事，界面脚本不用再写 refresh/onToggled：
##   · _ready：按存档状态同步按下状态 + 连到 Audio 的开关信号（别处改了也会自动同步）
##   · 点击：播按键音 → 写 Audio.setSoundEnabled / setMusicEnabled
## kind 指明这个实例是"音效"还是"音乐"（场景里设置，音乐按钮填 1）

enum Kind { SOUND = 0, MUSIC = 1 }

@export var kind: Kind = Kind.SOUND


func _ready() -> void:
	toggle_mode = true
	button_pressed = isEnabled()
	toggled.connect(onToggled)
	# 别处（HUD 图标 / 暂停面板）改了开关 → 同步按下状态
	if kind == Kind.MUSIC:
		Audio.musicToggled.connect(onStateChanged)
	else:
		Audio.soundToggled.connect(onStateChanged)


## 存档里当前是开还是关
func isEnabled() -> bool:
	return Audio.isMusicEnabled() if kind == Kind.MUSIC else Audio.isSoundEnabled()


func onToggled(on: bool) -> void:
	Audio.playButtonDown()
	if kind == Kind.MUSIC:
		Audio.setMusicEnabled(on)
	else:
		Audio.setSoundEnabled(on)


## 外部改了状态：只同步按下状态，不再触发 toggled（set_pressed_no_signal）
func onStateChanged(on: bool) -> void:
	set_pressed_no_signal(on)
