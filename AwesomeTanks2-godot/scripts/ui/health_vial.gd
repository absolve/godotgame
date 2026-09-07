extends Control
## HealthVial — H5 血瓶组件（bar_empty + 可裁剪 bar_health + bar_frame）
## 仅负责自身的视觉更新（set_ratio），由使用方(关卡根脚本)摆放与驱动。

const BAR_INSET_X := 2.0
const BAR_W := 106.0
const BAR_H := 21.0

@onready var _empty: TextureRect = $Empty
@onready var _fill: TextureRect = $Fill
@onready var _frame: TextureRect = $Frame

var _fill_tex: AtlasTexture = null


func _ready() -> void:
	# 克隆 bar_health 的 AtlasTexture，之后只改 region 宽度实现裁剪（对应 H5 crop）
	var base := _fill.texture as AtlasTexture
	if base != null:
		_fill_tex = AtlasTexture.new()
		_fill_tex.atlas = base.atlas
		_fill_tex.region = Rect2(base.region.position, Vector2(BAR_W, BAR_H))
		_fill.texture = _fill_tex
	set_ratio(1.0)


func set_ratio(ratio: float) -> void:
	var p := clampf(ratio, 0.0, 1.0)
	if _fill_tex == null:
		return
	_fill_tex.region.size.x = BAR_W * p
	_fill.size.x = BAR_W * p
