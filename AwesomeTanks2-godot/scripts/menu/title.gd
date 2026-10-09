extends Control
## Title — 主菜单界面（对应 H5 MenuTitle）
## 功能：背景+LOGO+坦克展示+Play/About按钮+右上Sound/Music开关+Credits弹窗

# 音效/音乐开关的两套贴图（toggle 时手动替换 normal）
#const TEX_SOUND_ON: Texture2D = preload("res://sprites/menu/title/parts/buttons/sound_on.png.tres")
#const TEX_SOUND_OFF: Texture2D = preload("res://sprites/menu/title/parts/buttons/sound_off.png.tres")
#const TEX_MUSIC_ON: Texture2D = preload("res://sprites/menu/title/parts/buttons/music_on.png.tres")
#const TEX_MUSIC_OFF: Texture2D = preload("res://sprites/menu/title/parts/buttons/music_off.png.tres")

@onready var creditsLayer: Control = $CreditsLayer

# 开场动画元素（H5 MenuTitle：logo / 坦克 / UPGRADES 依次缩小淡入）
@onready var logo: TextureRect = $Center/Logo
@onready var tank: TextureRect = $Center/TankStage/Tank
@onready var upgrades: TextureRect = $Center/TankStage/UpgradesBadge

func _ready() -> void:
	Audio.playMusic("music_menu.mp3")
	# Sound/Music 开关由 scenes/sound_btn.tscn 组件自己同步（读存档 + 连 Audio 信号）
	playIntro()


# ---------- 开场动画（对应 H5 MenuTitle.create 的逐项入场） ----------
## 依次执行：元素动画 → 播放 mouth_pop → 下一个元素
func playIntro() -> void:
	# 等一帧让容器布局完成，取到元素尺寸作为缩放中心
	await get_tree().process_frame
	await reveal(logo)
	Audio.playSfx("mouth_pop.mp3")
	await reveal(tank)
	Audio.playSfx("mouth_pop.mp3")
	await reveal(upgrades)
	Audio.playSfx("mouth_pop.mp3")


## 单个元素：从 1.5 倍缩小到 1，并 0.2s 内从黑色淡入；动画结束后返回
func reveal(item: TextureRect) -> void:
	item.pivot_offset = item.size * 0.5
	item.modulate = Color(0, 0, 0, 0)
	item.scale = Vector2(1.5, 1.5)
	var tw := create_tween()
	tw.tween_property(item,"visible",true,0.1)
	tw.parallel().tween_property(item, "modulate", Color.WHITE, 0.4)
	tw.parallel().tween_property(item, "scale", Vector2.ONE, 0.4)
	await tw.finished

# ---------- 信号回调 ----------
func onPlayPressed() -> void:
	Audio.playButtonDown()
	Game.changeScene(Settings.SCENE_UPGRADES)

func onAboutPressed() -> void:
	Audio.playButtonDown()
	creditsLayer.visible = true

func onCreditsClosePressed() -> void:
	Audio.playButtonDown()
	creditsLayer.visible = false
