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


## 纯状态同步（不播任何闪烁效果）：等级 / 仪表盘 / 价格
## 注意：**不要在这里加闪烁**，因为 _refresh_stat_cards() 会遍历所有卡调用本函数，
## 一旦这里闪，点任意一张卡都会让所有卡一起闪（H5 的闪烁是 Gauge.increase 单独负责的）。
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
		_price.text = Game._format_money(int(Settings.PRICES[stat_key][_level]))
		disabled = false


## 升级成功：刷新状态 + 闪一下图标和仪表盘（对应 H5 Gauge.increase）
func increase() -> void:
	refresh()
	FlashFx.flash(_icon)
	FlashFx.flash(_gauge)

func _on_down() -> void:
	Audio.play_button_down()


func _on_up() -> void:
	clicked.emit(stat_key)

func flash_price():
	FlashFx.flash(_price)
