extends Control
## Upgrades — 升级商店主菜单（对应 H5 MenuUpgrades）
## 简化版：移除 Tab 切换，中间直接显示武器面板（weapons.png 底图 + 10 武器 Grid）
## 功能：顶栏(Sound/Music+Money) + 武器购买/升级/补弹 + 底栏(Menu/Stats/Difficulty/Play) + 难度/统计弹窗

const WEAPON_KEYS: Array[String] = [
	"minigun", "shotgun", "ricochet", "flamethrower", "cannon",
	"shock", "rockets", "laser", "railgun", "mines"
]

# 资源常量 preload（Sound/Music 开关 + 武器三态按钮 换贴图用）
const TEX_SOUND_ON: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/sound_normal.png.tres")
const TEX_SOUND_OFF: Texture2D = preload("res://sprites/menu/title/parts/buttons/sound_off.png.tres")
const TEX_MUSIC_ON: Texture2D = preload("res://sprites/menu/upgrades/parts/buttons/music_normal.png.tres")
const TEX_MUSIC_OFF: Texture2D = preload("res://sprites/menu/title/parts/buttons/music_off.png.tres")
const TEX_UP: Array[Texture2D] = [
	preload("res://sprites/menu/upgrades/parts/buttons/upgrade_normal.png.tres"),
	preload("res://sprites/menu/upgrades/parts/buttons/upgrade_hover.png.tres"),
	preload("res://sprites/menu/upgrades/parts/buttons/upgrade_down.png.tres"),
]
const TEX_BUY: Array[Texture2D] = [
	preload("res://sprites/menu/upgrades/parts/buttons/buy_normal.png.tres"),
	preload("res://sprites/menu/upgrades/parts/buttons/buy_hover.png.tres"),
	preload("res://sprites/menu/upgrades/parts/buttons/buy_down.png.tres"),
]
const TEX_REFILL: Array[Texture2D] = [
	preload("res://sprites/menu/upgrades/parts/buttons/refill_normal.png.tres"),
	preload("res://sprites/menu/upgrades/parts/buttons/refill_hover.png.tres"),
	preload("res://sprites/menu/upgrades/parts/buttons/refill_down.png.tres"),
]

@onready var _money_label: Label = $TopBar/MoneyLabel
@onready var _sound_btn: TextureButton = $TopBar/SoundBtn
@onready var _music_btn: TextureButton = $TopBar/MusicBtn
@onready var _weapon_grid: GridContainer = $WeaponsCenter/WeaponsPanel/WeaponGrid
@onready var _difficulty_layer: Control = $DifficultyLayer
@onready var _stats_layer: Control = $StatsLayer

var _weapon_cards: Dictionary = {}   # key -> {icon, price_label, action_btn}

func _ready() -> void:
	Audio.play_music("music_menu.mp3")
	_populate_weapon_grid()
	# Sound/Music 状态
	_refresh_sound_btn(bool(Game.current.get("game", {}).get("sound", true)))
	_refresh_music_btn(bool(Game.current.get("game", {}).get("music", true)))
	_refresh()

# ---------- 武器网格动态创建 ----------
func _populate_weapon_grid() -> void:
	for c in _weapon_grid.get_children():
		c.queue_free()
	_weapon_cards.clear()
	for key in WEAPON_KEYS:
		# VBox: Icon + Price + Action(Buy/Upgrade/Refill)
		var card := VBoxContainer.new()
		card.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_theme_constant_override("separation", 6)
		card.custom_minimum_size = Vector2(152, 230)

		# 武器图标（优先 preload 对应图）
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(120, 120)
		var tex_path := "res://sprites/menu/upgrades/parts/%s.png.tres" % key
		if ResourceLoader.exists(tex_path):
			icon.texture = load(tex_path)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card.add_child(icon)

		# 价格 / 弹药 文本（金色）
		var price := Label.new()
		price.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
		price.add_theme_font_size_override("font_size", 18)
		price.text = "$0"
		price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(price)

		# 动作按钮（Buy 未拥有 → Upgrade → 满级后 Refill）
		var action_btn := TextureButton.new()
		action_btn.custom_minimum_size = Vector2(166, 74)
		action_btn.stretch_mode = TextureButton.STRETCH_SCALE
		action_btn.texture_normal = TEX_BUY[0]
		action_btn.texture_hover = TEX_BUY[1]
		action_btn.texture_pressed = TEX_BUY[2]
		action_btn.pressed.connect(_on_weapon_card_action.bind(key))
		card.add_child(action_btn)

		_weapon_grid.add_child(card)
		_weapon_cards[key] = {
			"icon": icon,
			"price": price,
			"btn": action_btn,
		}

# ---------- 武器卡点击 ----------
func _on_weapon_card_action(key: String) -> void:
	Audio.play_button_down()
	var level := Game.get_weapon_level(key)
	if level < 0:
		# 未拥有 → 第一次购买
		var price: int = Settings.PRICES[key][0]
		if Game.spend(price):
			Game.set_weapon_level(key, 0)
			Game.set_weapon_ammo(key, Settings.AMMO_LIMITS[key])
			Game.save()
			Audio.play_sfx("buy.mp3")
	elif level < 5:
		# 升级 level→level+1
		var price_idx := level + 1
		var price: int = Settings.PRICES[key][price_idx]
		if Game.spend(price):
			Game.set_weapon_level(key, level + 1)
			Game.save()
			Audio.play_sfx("buy.mp3")
	else:
		# 已满级 → 弹药补满
		var limit: int = Settings.AMMO_LIMITS.get(key, 0)
		if Game.get_weapon_ammo(key) < limit:
			var price: int = max(50, limit / 2)  # 补弹费用暂设
			if Game.spend(price):
				Game.set_weapon_ammo(key, limit)
				Game.save()
				Audio.play_sfx("buy.mp3")
	_refresh()

# ---------- 刷新 ----------
func _refresh() -> void:
	_money_label.text = _format_money(Game.get_money())
	for key in WEAPON_KEYS:
		_refresh_weapon_card(key)

func _refresh_weapon_card(key: String) -> void:
	var c: Dictionary = _weapon_cards.get(key, {})
	if c.is_empty():
		return
	var level := Game.get_weapon_level(key)
	var ammo := Game.get_weapon_ammo(key)
	var limit: int = Settings.AMMO_LIMITS.get(key, 0)
	if level < 0:
		# 未拥有
		c.price.text = "$%d" % Settings.PRICES[key][0]
		c.icon.modulate = Color(0.55, 0.55, 0.55)
		c.btn.disabled = false
		c.btn.texture_normal = TEX_BUY[0]
		c.btn.texture_hover = TEX_BUY[1]
		c.btn.texture_pressed = TEX_BUY[2]
	else:
		c.icon.modulate = Color.WHITE
		if level >= 5:
			# 满级 → 显示弹药 + Refill 按钮
			c.price.text = "Lv MAX  %d/%d" % [ammo, limit]
			var full: bool = ammo >= limit
			c.btn.disabled = full
			c.btn.texture_normal = TEX_REFILL[0]
			c.btn.texture_hover = TEX_REFILL[1]
			c.btn.texture_pressed = TEX_REFILL[2]
		else:
			# 升级
			c.price.text = "Lv%d/%d  $%d" % [level, 5, Settings.PRICES[key][level + 1]]
			c.btn.disabled = false
			c.btn.texture_normal = TEX_UP[0]
			c.btn.texture_hover = TEX_UP[1]
			c.btn.texture_pressed = TEX_UP[2]

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

# ---------- Sound/Music ----------
func _refresh_sound_btn(on: bool) -> void:
	_sound_btn.button_pressed = on
	_sound_btn.texture_normal = TEX_SOUND_ON if on else TEX_SOUND_OFF

func _refresh_music_btn(on: bool) -> void:
	_music_btn.button_pressed = on
	_music_btn.texture_normal = TEX_MUSIC_ON if on else TEX_MUSIC_OFF

func _on_sound_toggled() -> void:
	# TextureButton pressed 信号触发时 button_pressed 已被 toggle_mode 翻转
	var want_on: bool = bool(_sound_btn.button_pressed)
	_refresh_sound_btn(want_on)
	Audio.set_sound_enabled(want_on)
	Audio.play_button_down()

func _on_music_toggled() -> void:
	var want_on: bool = bool(_music_btn.button_pressed)
	_refresh_music_btn(want_on)
	Audio.set_music_enabled(want_on)
	Audio.play_button_down()

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
