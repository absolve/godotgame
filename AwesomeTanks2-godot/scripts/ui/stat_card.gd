extends TextureButton
## StatCard —— 单张属性升级卡（对应 H5 Gauge）
## 卡片本身就是按钮：点击升级，有图标+仪表盘+价格

signal clicked(key: String)

@export var stat_key: String = ""

@onready var _icon: TextureRect = $Icon
@onready var _gauge: TextureRect = $Gauge
@onready var _price: Label = $Price

var _level: int = 0


func _ready() -> void:
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	if stat_key != "":
		setup(stat_key)


func setup(key: String) -> void:
	stat_key = key
	var icon_path := "res://sprites/menu/upgrades/parts/%s.png.tres" % key
	if ResourceLoader.exists(icon_path):
		_icon.texture = load(icon_path)
	refresh()


func refresh() -> void:
	_level = Game.get_performance_level(stat_key)
	# 仪表盘：0~5 对应 gauge_0 ~ gauge_5
	var gauge_path := "res://sprites/menu/upgrades/parts/gauge_%d.png.tres" % _level
	if ResourceLoader.exists(gauge_path):
		_gauge.texture = load(gauge_path)
	# 价格：Settings.PRICES[stat_key] 是长度 5 的数组（0~4 升级价）
	# level < 5 时显示下一级价格；level >= 5 显示 "MAX"
	if _level >= 5:
		_price.text = "MAX"
		disabled = true
	else:
		_price.text = _format_money(int(Settings.PRICES[stat_key][_level]))
		disabled = false


func _on_down() -> void:
	Audio.play_button_down()


func _on_up() -> void:
	clicked.emit(stat_key)

func flash_price():
	FlashFx.flash(_price)

static func _format_money(v: int) -> String:
	if v >= 1000000000:
		return "$%.3fb" % (v / 1000000000.0)
	if v >= 100000000:
		return "$%.1fm" % (v / 1000000.0)
	if v >= 1000000:
		return "$%.2fm" % (v / 1000000.0)
	if v >= 100000:
		return "$%.1fk" % (v / 1000.0)
	return "$%d" % v
