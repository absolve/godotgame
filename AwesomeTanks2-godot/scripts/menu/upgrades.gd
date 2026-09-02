extends Control
## Upgrades —— 升级商店主菜单（对应 H5 MenuUpgrades）
## 双 Tab：Weapons（武器购买/升级/补弹）、Performance（属性升级）

#const FONT: Font = preload("res://fonts/gunplay.ttf")
const CARD_SCENE: PackedScene = preload("res://scenes/weapon_card.tscn")
const STAT_CARD_SCENE: PackedScene = preload("res://scenes/stat_card.tscn")

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

@onready var _money_label: Label = $Design/TopBar/MoneyLabel
@onready var _sound_btn: TextureButton = $Design/SoundBtn
@onready var _music_btn: TextureButton = $Design/MusicBtn
@onready var _cards: Control = $Design/WeaponsPanel/Cards
@onready var _perf_cards: Control = $Design/PerformancePanel/PerfCards
@onready var _tab_perf: TextureButton = $Design/TabPerformance
@onready var _tab_wp: TextureButton = $Design/TabWeapons
@onready var _weapons_panel: Control = $Design/WeaponsPanel
@onready var _perf_panel: Control = $Design/PerformancePanel
@onready var _difficulty_layer: Control = $DifficultyLayer
@onready var _stats_layer: Control = $StatsLayer
@onready var _weapon_alert: Control = $WeaponAlert

var _cards_by_key: Dictionary = {}   # key -> WeaponCard 实例
var _stats_by_key: Dictionary = {}   # key -> StatCard 实例


func _ready() -> void:
	Audio.play_music("music_menu.mp3")
	#_money_label.add_theme_font_override("font", FONT)
	_populate_cards()
	_populate_stat_cards()
	# 默认显示武器 Tab
	_tab_perf.texture_normal = TAB_PERF
	_tab_perf.texture_hover = TAB_PERF
	_tab_perf.texture_pressed = TAB_PERF
	_tab_wp.texture_normal = TAB_WP_A
	_tab_wp.texture_hover = TAB_WP_A
	_tab_wp.texture_pressed = TAB_WP_A
	_perf_panel.visible = false
	_weapons_panel.visible = true
	# Sound/Music 状态
	_refresh_sound_btn(bool(Game.current.get("game", {}).get("sound", true)))
	_refresh_music_btn(bool(Game.current.get("game", {}).get("music", true)))
	_refresh()
	Game.money_changed.connect(_on_money_changed)
	_weapon_alert.purchased.connect(_on_weapon_alert_purchased)
	_weapon_alert.failed.connect(_on_weapon_alert_failed)


# ---------- Tab 切换 ----------
func _on_performance_tab_pressed() -> void:
	Audio.play_button_down()
	_tab_perf.texture_normal = TAB_PERF_A
	_tab_perf.texture_hover = TAB_PERF_A
	_tab_perf.texture_pressed = TAB_PERF_A
	_tab_wp.texture_normal = TAB_WP
	_tab_wp.texture_hover = TAB_WP
	_tab_wp.texture_pressed = TAB_WP
	_perf_panel.visible = true
	_weapons_panel.visible = false


func _on_weapons_tab_pressed() -> void:
	Audio.play_button_down()
	_tab_perf.texture_normal = TAB_PERF
	_tab_perf.texture_hover = TAB_PERF
	_tab_perf.texture_pressed = TAB_PERF
	_tab_wp.texture_normal = TAB_WP_A
	_tab_wp.texture_hover = TAB_WP_A
	_tab_wp.texture_pressed = TAB_WP_A
	_perf_panel.visible = false
	_weapons_panel.visible = true


# ---------- 属性卡实例化 ----------
func _populate_stat_cards() -> void:
	for key in STAT_KEYS:
		var card = STAT_CARD_SCENE.instantiate()
		card.stat_key = key
		_perf_cards.add_child(card)
		card.position = STAT_POSITIONS[key]
		card.clicked.connect(_on_stat_clicked)
		_stats_by_key[key] = card


# ---------- 属性升级 ----------
func _on_stat_clicked(key: String) -> void:
	var level: int = Game.get_performance_level(key)
	if level >= 5:
		return
	var price: int = int(Settings.PRICES[key][level])
	var stat_card: Control = _stats_by_key.get(key)
	if Game.spend(price):
		Game.set_performance_level(key, level + 1)
		Game.save()
		Audio.play_sfx("buy.mp3")
		FlashFx.flash(_money_label)
		if stat_card != null:
			stat_card.increase()  # 闪烁 + 刷新仪表盘贴图（对应 H5 Gauge.increase）
	else:
		Audio.play_sfx("not_available.mp3")
		FlashFx.flash(_money_label)
		if stat_card != null:
			stat_card.flash_price()  # 闪价签（对应 H5 a(this[key+"Price"])）
	_refresh()


# ---------- 武器卡实例化 ----------
func _populate_cards() -> void:
	for key in CARD_POSITIONS:
		var card = CARD_SCENE.instantiate()
		card.weapon_key = key
		_cards.add_child(card)
		card.position = CARD_POSITIONS[key]
		card.clicked.connect(_on_card_clicked)
		card.refill_held.connect(_on_card_refill)
		_cards_by_key[key] = card


# ---------- 武器卡：单击=打开 购买/升级 弹窗（对应 H5 weaponClick→BuyUpgradeAlert） ----------
func _on_card_clicked(key: String) -> void:
	_weapon_alert.open(key)


# ---------- 弹窗购买结果：金额与对应武器卡闪烁（对应 H5 weaponUpgrade/ammoBuy） ----------
func _on_weapon_alert_purchased(key: String, is_refill: bool) -> void:
	_refresh()
	FlashFx.flash(_money_label)
	var card = _cards_by_key.get(key)
	if card == null:
		return
	if is_refill:
		card.flash_ammo()   # 补弹成功：闪卡的弹药条
	else:
		card.flash()        # 购买/升级成功：闪整张武器卡


func _on_weapon_alert_failed(key: String, is_refill: bool) -> void:
	FlashFx.flash(_money_label)
	if not is_refill:
		var card = _cards_by_key.get(key)
		if card != null:
			card.flash_price()  # 购买失败：闪卡的价签


# ---------- 武器卡：长按=补弹（仅拥有且非 minigun） ----------
func _on_card_refill(key: String) -> void:
	var ammo: int = Game.get_weapon_ammo(key)
	var limit: int = int(Settings.AMMO_LIMITS.get(key, 0))
	if ammo >= limit:
		return
	var price: int = int(Settings.AMMO_PRICES.get(key, 0))
	var amount: int = int(Settings.AMMO_AMOUNT.get(key, 0))
	if Game.spend(price):
		Game.set_weapon_ammo(key, ammo + amount)
		Game.save()
		Audio.play_sfx("buy.mp3")
		FlashFx.flash(_money_label)
		if _cards_by_key.has(key):
			_cards_by_key[key].flash_ammo()
	else:
		Audio.play_sfx("not_available.mp3")
		FlashFx.flash(_money_label)
	_refresh()


# ---------- 刷新 ----------
func _refresh() -> void:
	_money_label.text = _format_money(Game.get_money())
	_refresh_cards()
	_refresh_stat_cards()


func _refresh_cards() -> void:
	for key in _cards_by_key:
		_cards_by_key[key].refresh()


func _refresh_stat_cards() -> void:
	for key in _stats_by_key:
		_stats_by_key[key].refresh()


func _on_money_changed(_value: int) -> void:
	_money_label.text = _format_money(Game.get_money())


# ---------- Sound/Music ----------
func _refresh_sound_btn(on: bool) -> void:
	_sound_btn.button_pressed = on


func _refresh_music_btn(on: bool) -> void:
	_music_btn.button_pressed = on


func _on_sound_toggled() -> void:
	var want_on: bool = _sound_btn.button_pressed
	_refresh_sound_btn(want_on)
	Audio.set_sound_enabled(want_on)


func _on_music_toggled() -> void:
	var want_on: bool = _music_btn.button_pressed
	_refresh_music_btn(want_on)
	Audio.set_music_enabled(want_on)


# ---------- 底栏 ----------
func _on_play_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_LEVEL_SELECT)


func _on_menu_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_TITLE)


func _on_editor_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_EDITOR)


func _on_stats_pressed() -> void:
	Audio.play_button_down()
	_stats_layer.visible = true


func _on_stats_close_pressed() -> void:
	Audio.play_button_down()
	_stats_layer.visible = false


func _on_difficulty_pressed() -> void:
	Audio.play_button_down()
	_difficulty_layer.visible = true


func _on_difficulty_close_pressed() -> void:
	Audio.play_button_down()
	_difficulty_layer.visible = false


func _set_difficulty(idx: int) -> void:
	Game.current["game"]["difficulty"] = idx
	Game.save()
	_difficulty_layer.visible = false
	_refresh()


func _on_difficulty_easy_pressed() -> void:
	Audio.play_button_down()
	_set_difficulty(0)


func _on_difficulty_medium_pressed() -> void:
	Audio.play_button_down()
	_set_difficulty(1)


func _on_difficulty_hard_pressed() -> void:
	Audio.play_button_down()
	_set_difficulty(2)


# ---------- 金额格式化 ----------
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
