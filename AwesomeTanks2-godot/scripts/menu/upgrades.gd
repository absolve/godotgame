extends Control
## Upgrades —— 升级商店主菜单（对应 H5 MenuUpgrades）
## 双 Tab：Weapons（武器购买/升级/补弹）、Performance（属性升级）

#const FONT: Font = preload("res://fonts/gunplay.ttf")
const CARD_SCENE: PackedScene = preload("res://scenes/weapon_card.tscn")
const STAT_CARD_SCENE: PackedScene = preload("res://scenes/stat_card.tscn")
const STATS_LAYER_SCRIPT := preload("res://scripts/ui/stats_layer.gd")

# 10 张武器卡在 WeaponsPanel(581x309) 内的左上角坐标
const CARD_POSITIONS: Dictionary = {
	"minigun": Vector2(20, 30),
	"shotgun": Vector2(130, 30),
	"ricochet": Vector2(240, 30),
	"flamethrower": Vector2(350, 30),
	"cannon": Vector2(460, 30),
	"shock": Vector2(20, 170),
	"rockets": Vector2(130, 170),
	"laser": Vector2(240, 170),
	"railgun": Vector2(350, 170),
	"mines": Vector2(460, 170),
}

# 4 张属性卡在 PerformancePanel(581x309) 内的左上角坐标
# 参考 H5: armor(60,80), sight(181,80), turret(301,80), speed(421,80)
const STAT_KEYS: Array[String] = ["armor", "sight", "turret", "speed"]
const STAT_POSITIONS: Dictionary = {
	"armor": Vector2(60, 80),
	"sight": Vector2(181, 80),
	"turret": Vector2(301, 80),
	"speed": Vector2(421, 80),
}

# Tab 贴图
const TAB_PERF: Texture2D = preload("res://sprites/menu/upgrades/parts/tab_performance.png.tres")
const TAB_PERF_A: Texture2D = preload("res://sprites/menu/upgrades/parts/tab_performance_active.png.tres")
const TAB_WP: Texture2D = preload("res://sprites/menu/upgrades/parts/tab_weapons.png.tres")
const TAB_WP_A: Texture2D = preload("res://sprites/menu/upgrades/parts/tab_weapons_active.png.tres")

@onready var moneyLabel: Label = $Design/TopBar/MoneyLabel
@onready var cards: Control = $Design/WeaponsPanel/Cards
@onready var perfCards: Control = $Design/PerformancePanel/PerfCards
@onready var tabPerf: TextureButton = $Design/TabPerformance
@onready var tabWp: TextureButton = $Design/TabWeapons
@onready var weaponsPanel: Control = $Design/WeaponsPanel
@onready var perfPanel: Control = $Design/PerformancePanel
@onready var difficultyLayer: Control = $DifficultyLayer
@onready var statsLayer: STATS_LAYER_SCRIPT = $StatsLayer
@onready var weaponAlert: Control = $WeaponAlert

var cardsByKey: Dictionary = {}   # key -> WeaponCard 实例
var statsByKey: Dictionary = {}   # key -> StatCard 实例


func _ready() -> void:
	Audio.playMusic("music_menu.mp3")
	#_money_label.add_theme_font_override("font", FONT)
	populateCards()
	populateStatCards()
	# 默认显示武器 Tab
	tabPerf.texture_normal = TAB_PERF
	tabPerf.texture_hover = TAB_PERF
	tabPerf.texture_pressed = TAB_PERF
	tabWp.texture_normal = TAB_WP_A
	tabWp.texture_hover = TAB_WP_A
	tabWp.texture_pressed = TAB_WP_A
	perfPanel.visible = false
	weaponsPanel.visible = true
	# Sound/Music 开关由 scenes/sound_btn.tscn 组件自己同步（读存档 + 连 Audio 信号）
	refresh()
	Game.moneyChanged.connect(onMoneyChanged)
	weaponAlert.purchased.connect(onWeaponAlertPurchased)
	weaponAlert.failed.connect(onWeaponAlertFailed)


# ---------- Tab 切换 ----------
func onPerformanceTabPressed() -> void:
	Audio.playButtonDown()
	tabPerf.texture_normal = TAB_PERF_A
	tabPerf.texture_hover = TAB_PERF_A
	tabPerf.texture_pressed = TAB_PERF_A
	tabWp.texture_normal = TAB_WP
	tabWp.texture_hover = TAB_WP
	tabWp.texture_pressed = TAB_WP
	perfPanel.visible = true
	weaponsPanel.visible = false


func onWeaponsTabPressed() -> void:
	Audio.playButtonDown()
	tabPerf.texture_normal = TAB_PERF
	tabPerf.texture_hover = TAB_PERF
	tabPerf.texture_pressed = TAB_PERF
	tabWp.texture_normal = TAB_WP_A
	tabWp.texture_hover = TAB_WP_A
	tabWp.texture_pressed = TAB_WP_A
	perfPanel.visible = false
	weaponsPanel.visible = true


# ---------- 属性卡实例化 ----------
func populateStatCards() -> void:
	for key in STAT_KEYS:
		var card = STAT_CARD_SCENE.instantiate()
		card.statKey = key
		perfCards.add_child(card)
		card.position = STAT_POSITIONS[key]
		card.clicked.connect(onStatClicked)
		statsByKey[key] = card


# ---------- 属性升级 ----------
func onStatClicked(key: String) -> void:
	var level: int = Game.getPerformanceLevel(key)
	if level >= 5:
		return
	var price: int = int(Settings.PRICES[key][level])
	var statCard: Control = statsByKey.get(key)
	if Game.spend(price):
		Game.setPerformanceLevel(key, level + 1)
		Game.save()
		Audio.playSfx("buy.mp3")
		FlashFx.flash(moneyLabel)
		if statCard != null:
			statCard.increase()   # 只有这张卡闪（refresh 不播闪烁，见 stat_card.gd）
	else:
		Audio.playSfx("not_available.mp3")
		FlashFx.flash(moneyLabel)
		if statCard != null:
			statCard.flashPrice()  # 闪价签（对应 H5 a(this[key+"Price"])）
	refresh()


# ---------- 武器卡实例化 ----------
func populateCards() -> void:
	for key in CARD_POSITIONS:
		var card = CARD_SCENE.instantiate()
		card.weaponKey = key
		cards.add_child(card)
		card.position = CARD_POSITIONS[key]
		card.clicked.connect(onCardClicked)
		card.refillHeld.connect(onCardRefill)
		cardsByKey[key] = card


# ---------- 武器卡：单击=打开 购买/升级 弹窗（对应 H5 weaponClick→BuyUpgradeAlert） ----------
func onCardClicked(key: String) -> void:
	weaponAlert.open(key)


# ---------- 弹窗购买结果：金额与对应武器卡闪烁（对应 H5 weaponUpgrade/ammoBuy） ----------
func onWeaponAlertPurchased(key: String, isRefill: bool) -> void:
	refresh()
	FlashFx.flash(moneyLabel)
	var card = cardsByKey.get(key)
	if card == null:
		return
	if isRefill:
		card.flashAmmo()   # 补弹成功：闪卡的弹药条
	else:
		card.flash()        # 购买/升级成功：闪整张武器卡


func onWeaponAlertFailed(key: String, isRefill: bool) -> void:
	FlashFx.flash(moneyLabel)
	if not isRefill:
		var card = cardsByKey.get(key)
		if card != null:
			card.flashPrice()  # 购买失败：闪卡的价签


# ---------- 武器卡：长按=补弹（仅拥有且非 minigun） ----------
func onCardRefill(key: String) -> void:
	var ammo: int = Game.getWeaponAmmo(key)
	var limit: int = int(Settings.AMMO_LIMITS.get(key, 0))
	if ammo >= limit:
		return
	var price: int = int(Settings.AMMO_PRICES.get(key, 0))
	var amount: int = int(Settings.AMMO_AMOUNT.get(key, 0))
	if Game.spend(price):
		Game.setWeaponAmmo(key, ammo + amount)
		Game.save()
		Audio.playSfx("buy.mp3")
		FlashFx.flash(moneyLabel)
		if cardsByKey.has(key):
			cardsByKey[key].flashAmmo()
	else:
		Audio.playSfx("not_available.mp3")
		FlashFx.flash(moneyLabel)
	refresh()


# ---------- 刷新 ----------
func refresh() -> void:
	moneyLabel.text = Game.formatMoney(Game.getMoney())
	refreshCards()
	refreshStatCards()


func refreshCards() -> void:
	for key in cardsByKey:
		cardsByKey[key].refresh()


func refreshStatCards() -> void:
	for key in statsByKey:
		statsByKey[key].refresh()


func onMoneyChanged(_value: int) -> void:
	moneyLabel.text = Game.formatMoney(Game.getMoney())


# ---------- 底栏 ----------
func onPlayPressed() -> void:
	Audio.playButtonDown()
	Game.changeScene(Settings.SCENE_LEVEL_SELECT)


func onMenuPressed() -> void:
	Audio.playButtonDown()
	Game.changeScene(Settings.SCENE_TITLE)


func onEditorPressed() -> void:
	Audio.playButtonDown()
	Game.changeScene(Settings.SCENE_EDITOR)


func onStatsPressed() -> void:
	Audio.playButtonDown()
	statsLayer.open()  # 打开时重新读取统计/成就数据


func onDifficultyPressed() -> void:
	Audio.playButtonDown()
	difficultyLayer.visible = true


func onDifficultyClosePressed() -> void:
	Audio.playButtonDown()
	difficultyLayer.visible = false


func setDifficulty(idx: int) -> void:
	Game.current["game"]["difficulty"] = idx
	Game.save()
	difficultyLayer.visible = false
	refresh()


func onDifficultyEasyPressed() -> void:
	Audio.playButtonDown()
	setDifficulty(0)


func onDifficultyMediumPressed() -> void:
	Audio.playButtonDown()
	setDifficulty(1)


func onDifficultyHardPressed() -> void:
	Audio.playButtonDown()
	setDifficulty(2)
