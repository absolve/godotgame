extends Control
## Upgrades —— 升级商店主菜单（对应 H5 MenuUpgrades）
## 简化版：移除 Tab 切换，中间直接显示武器面板（weapons.png 底图 + 10 张武器卡）
## 功能：顶栏(Money + Sound/Music) + 武器购买/升级/补弹 + 底栏(Menu/Stats/Difficulty/Play) + 难度/统计弹窗
## 武器卡使用 weapon_card.tscn 实例化（参考 sound_btn.tscn 的"最小场景+脚本+实例化"模式）

#const FONT: Font = preload("res://fonts/gunplay.ttf")
const CARD_SCENE: PackedScene = preload("res://scenes/weapon_card.tscn")

# 10 张武器卡在 WeaponsPanel(581x309) 内的左上角坐标（对应 H5 weapons 组 (10,192) 内的相对坐标）
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

@onready var _money_label: Label = $Design/TopBar/MoneyLabel
@onready var _sound_btn: TextureButton = $Design/TopBar/SoundBtn
@onready var _music_btn: TextureButton = $Design/TopBar/MusicBtn
@onready var _cards: Control = $Design/WeaponsPanel/Cards
@onready var _difficulty_layer: Control = $DifficultyLayer
@onready var _stats_layer: Control = $StatsLayer

var _cards_by_key: Dictionary = {}   # key -> WeaponCard 实例


func _ready() -> void:
	Audio.play_music("music_menu.mp3")
	#_money_label.add_theme_font_override("font", FONT)
	_populate_cards()
	# Sound/Music 状态（SoundBtn 脚本已自带 button_down 音效，此处不再播）
	_refresh_sound_btn(bool(Game.current.get("game", {}).get("sound", true)))
	_refresh_music_btn(bool(Game.current.get("game", {}).get("music", true)))
	_refresh()
	Game.money_changed.connect(_on_money_changed)


# ---------- 武器卡实例化 ----------
func _populate_cards() -> void:
	for key in CARD_POSITIONS:
		# 不强类型为 TextureButton：要访问 weapon_card.gd 自定义成员(weapon_key/clicked/refill_held/refresh)
		var card = CARD_SCENE.instantiate()
		# 先设 weapon_key 再 add_child，_ready() 里会据此调用 setup()
		card.weapon_key = key
		_cards.add_child(card)
		card.position = CARD_POSITIONS[key]
		card.clicked.connect(_on_card_clicked)
		card.refill_held.connect(_on_card_refill)
		_cards_by_key[key] = card
	_refresh_cards()


# ---------- 武器卡：单击=购买/升级 ----------
func _on_card_clicked(key: String) -> void:
	var level: int = Game.get_weapon_level(key)
	if level >= 5:
		return
	var price: int
	if level < 0:
		price = int(Settings.PRICES[key][0])
	else:
		price = int(Settings.PRICES[key][level + 1])
	if Game.spend(price):
		if level < 0:
			Game.set_weapon_level(key, 0)
			Game.set_weapon_ammo(key, int(Settings.AMMO_LIMITS.get(key, 0)))
		else:
			Game.set_weapon_level(key, level + 1)
		Game.save()
		Audio.play_sfx("buy.mp3")
	else:
		Audio.play_sfx("not_available.mp3")
	_refresh()


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
	else:
		Audio.play_sfx("not_available.mp3")
	_refresh()


# ---------- 刷新 ----------
func _refresh() -> void:
	_money_label.text = _format_money(Game.get_money())
	_refresh_cards()


func _refresh_cards() -> void:
	for key in _cards_by_key:
		_cards_by_key[key].refresh()


func _on_money_changed(_value: int) -> void:
	_money_label.text = _format_money(Game.get_money())


# ---------- Sound/Music（贴图靠 toggle 自动显示，_refresh 仅同步 button_pressed） ----------
func _refresh_sound_btn(on: bool) -> void:
	_sound_btn.button_pressed = on


func _refresh_music_btn(on: bool) -> void:
	_music_btn.button_pressed = on


func _on_sound_toggled() -> void:
	# SoundBtn 脚本已播 button_down，此处只切换状态
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
	# 0=Easy 1=Medium 2=Hard，对应 H5 DIFFICULTIES[3] = [0.65, 0.85, 1.0]
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
