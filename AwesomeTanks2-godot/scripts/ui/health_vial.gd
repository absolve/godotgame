extends Control
## HealthVial — H5 血瓶组件（bar_empty + 可裁剪 bar_health + bar_frame）
## 仅负责自身的视觉更新（set_ratio），由使用方(关卡根脚本)摆放与驱动。

const BAR_INSET_X := 2.0
const BAR_W := 106.0
const BAR_H := 21.0

@onready var empty: TextureRect = $Empty
@onready var fill: TextureRect = $Fill
@onready var frame: TextureRect = $Frame

var fillTex: AtlasTexture = null


func _ready() -> void:
	# 克隆 bar_health 的 AtlasTexture，之后只改 region 宽度实现裁剪（对应 H5 crop）
	var base := fill.texture as AtlasTexture
	if base != null:
		fillTex = AtlasTexture.new()
		fillTex.atlas = base.atlas
		fillTex.region = Rect2(base.region.position, Vector2(BAR_W, BAR_H))
		fill.texture = fillTex
	setRatio(1.0)


func setRatio(ratio: float) -> void:
	var p := clampf(ratio, 0.0, 1.0)
	if fillTex == null:
		return
	fillTex.region.size.x = BAR_W * p
	fill.size.x = BAR_W * p
