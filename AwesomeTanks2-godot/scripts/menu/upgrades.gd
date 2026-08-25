extends Control
## Upgrades — 升级/商店菜单（对应原项目 MenuUpgrades）
## 顶栏：标题/金钱/音效·音乐开关
## 标签：Performance(armor/sight/turret/speed 仪表+价格) | Weapons(10 武器卡)
## 底栏：Menu / Stats / Difficulty / Play

const WEAPON_KEYS: Array[String] = [
	"minigun", "shotgun", "ricochet", "flamethrower", "cannon",
	"shock", "rockets", "laser", "railgun", "mines"
]

@onready var _money: Label = $Design/TopBar/Money
@onready var _sound_btn: Button = $Design/TopBar/Sound
@onready var _music_btn: Button = $Design/TopBar/Music
@onready var _perf_tab: Button = $Design/Tabs/Performance
@onready var _weapons_tab: Button = $Design/Tabs/Weapons
@onready var _perf_panel: VBoxContainer = $Design/TabContent/PerformancePanel
@onready var _weapons_panel: VBoxContainer = $Design/TabContent/WeaponsPanel
@onready var _weapon_grid: GridContainer = $Design/TabContent/WeaponsPanel/WeaponGrid

var _weapon_cards: Dictionary = {}   # key -> Button

func _ready() -> void:
	Audio.play_music("music_menu.mp3")
	_sound_btn.button_pressed = bool(Game.current["game"]["sound"])
	_music_btn.button_pressed = bool(Game.current["game"]["music"])
	_populate_weapon_grid()
	_show_weapons_tab()
	_refresh()

# ============================================================
# 标签切换
# ============================================================
func _on_performance_tab_toggled(on: bool) -> void:
	if on:
		_show_performance_tab()

func _on_weapons_tab_toggled(on: bool) -> void:
	if on:
		_show_weapons_tab()

func _show_performance_tab() -> void:
	_perf_tab.button_pressed = true
	_weapons_tab.button_pressed = false
	_perf_panel.visible = true
	_weapons_panel.visible = false

func _show_weapons_tab() -> void:
	_perf_tab.button_pressed = false
	_weapons_tab.button_pressed = true
	_perf_panel.visible = false
	_weapons_panel.visible = true

# ============================================================
# 武器网格
# ============================================================
func _populate_weapon_grid() -> void:
	for c in _weapon_grid.get_children():
		c.queue_free()
	_weapon_cards.clear()
	for key in WEAPON_KEYS:
		var card := Button.new()
		card.custom_minimum_size = Vector2(100, 80)
		card.text = key.capitalize()
		card.pressed.connect(_on_weapon_card_pressed.bind(key))
		_weapon_grid.add_child(card)
		_weapon_cards[key] = card

func _on_weapon_card_pressed(key: String) -> void:
	Audio.play_button_down()
	# 点击武器卡：购买或升级
	_on_buy_weapon(key)

# ============================================================
# 刷新显示
# ============================================================
func _refresh() -> void:
	_money.text = _format_money(Game.get_money())
	for stat in ["armor", "sight", "turret", "speed"]:
		_refresh_perf(stat)
	for key in WEAPON_KEYS:
		_refresh_weapon_card(key)

func _refresh_perf(stat: String) -> void:
	var panel := _perf_panel.get_node("Gauges/%s" % stat.capitalize()) as VBoxContainer
	if panel == null:
		return
	var level := Game.get_performance_level(stat)
	(panel.get_node("Bar") as ProgressBar).value = float(level)
	(panel.get_node("Price") as Label).text = _upgrade_cost_text(stat, level)
	(panel.get_node("Buy") as Button).disabled = level >= 5

func _refresh_weapon_card(key: String) -> void:
	var card: Button = _weapon_cards.get(key)
	if card == null:
		return
	var level := Game.get_weapon_level(key)
	var ammo := Game.get_weapon_ammo(key)
	var limit: int = Settings.AMMO_LIMITS.get(key, 0)
	if level < 0:
		card.text = "%s\nBuy" % key.capitalize()
		card.modulate = Color(0.6, 0.6, 0.6)
	else:
		card.text = "%s\nLv%d\n%d/%d" % [key.capitalize(), level, ammo, limit]
		card.modulate = Color.WHITE

func _upgrade_cost_text(stat: String, level: int) -> String:
	if level >= 5:
		return "MAX"
	return "$%d" % Settings.PRICES[stat][level]

func _format_money(v: int) -> String:
	if v >= 1000000000:
		return "$%.3fb" % (v / 1000000000.0)
	if v >= 100000000:
		return "$%.1fm" % (v / 1000000.0)
	if v >= 1000000:
		return "$%.2fm" % (v / 1000000.0)
	if v >= 100000:
		return "$%.1fk" % (v / 1000.0)
	return "$%d" % v

# ============================================================
# 购买
# ============================================================
func _on_buy_weapon(key: String) -> void:
	var level := Game.get_weapon_level(key)
	if level >= 5:
		return
	var price_idx := 0 if level == -1 else level + 1
	var price: int = Settings.PRICES[key][price_idx]
	if Game.spend(price):
		Game.set_weapon_level(key, max(0, level) + 1)
		if level == -1:
			Game.set_weapon_ammo(key, Settings.AMMO_LIMITS[key])
		Game.save()
		Audio.play_sfx("buy.mp3")
	_refresh()

func _on_buy_upgrade(stat: String) -> void:
	var level := Game.get_performance_level(stat)
	if level >= 5:
		return
	var price: int = Settings.PRICES[stat][level]
	if Game.spend(price):
		Game.current["game"][stat] = level + 1
		Game.save()
		Audio.play_sfx("buy.mp3")
	_refresh()

# Buy 按钮信号绑定（场景里每个 Buy 按钮连接到对应 stat）
func _on_armor_buy() -> void: _on_buy_upgrade("armor")
func _on_sight_buy() -> void: _on_buy_upgrade("sight")
func _on_turret_buy() -> void: _on_buy_upgrade("turret")
func _on_speed_buy() -> void: _on_buy_upgrade("speed")

# ============================================================
# 底栏按钮
# ============================================================
func _on_play_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_LEVEL_SELECT)

func _on_menu_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_TITLE)

func _on_stats_pressed() -> void:
	Audio.play_button_down()
	# TODO: 弹出 StatsAlert 面板（8 项统计 + 9 项成就）
	pass

func _on_difficulty_pressed() -> void:
	Audio.play_button_down()
	# TODO: 弹出 DifficultyAlert（简单/中/困难）
	pass

func _on_sound_toggled(on: bool) -> void:
	Audio.set_sound_enabled(on)

func _on_music_toggled(on: bool) -> void:
	Audio.set_music_enabled(on)
