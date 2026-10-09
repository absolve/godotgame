extends ATMenuCard
## StatCard —— 单张属性升级卡（对应 H5 Gauge）：点击升级，有图标 + 仪表盘 + 价签
## 点击/长按/闪烁等公共逻辑见 ATMenuCard

@export var statKey: String = ""

@onready var icon: TextureRect = $Icon
@onready var gauge: TextureRect = $Gauge


func cardKey() -> String:
	return statKey


func setup(key: String) -> void:
	statKey = key
	icon.texture = Game.loadTextureOrNull("res://sprites/menu/upgrades/parts/%s.png.tres" % key)
	refresh()


## 纯状态同步（不播任何闪烁效果）：等级 / 仪表盘 / 价格
## 注意：**不要在这里加闪烁**，因为 upgrades.refreshStatCards() 会遍历所有卡调用本函数，
## 一旦这里闪，点任意一张卡都会让所有卡一起闪（H5 的闪烁是 Gauge.increase 单独负责的）。
func refresh() -> void:
	weaponLevel = Game.getPerformanceLevel(statKey)
	# 仪表盘：0~5 对应 gauge_0 ~ gauge_5
	var gaugePath := "res://sprites/menu/upgrades/parts/gauge_%d.png.tres" % weaponLevel
	gauge.texture = Game.loadTextureOrNull(gaugePath)
	# 价格：Settings.PRICES[stat_key] 是长度 5 的数组（0~4 升级价）
	# level < 5 时显示下一级价格；level >= 5 显示 "MAX"
	if weaponLevel >= 5:
		priceLabel.text = "MAX"
		disabled = true
	else:
		priceLabel.text = Game.formatMoney(int(Settings.PRICES[statKey][weaponLevel]))
		disabled = false


## 升级成功：刷新状态 + 闪一下图标和仪表盘（对应 H5 Gauge.increase）
func increase() -> void:
	refresh()
	FlashFx.flash(icon)
	FlashFx.flash(gauge)
