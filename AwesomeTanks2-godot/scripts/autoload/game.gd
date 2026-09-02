extends Node
## Game — 全局游戏状态/存档/经济管理单例（移植自原项目 window.AT.profile）
##
## 负责：
##   - 存档的读取/保存/重置（Godot FileAccess + JSON，替代 localStorage）
##   - 玩家进度数据（金钱、关卡、武器等级、弹药、成就、统计）
##   - 场景切换封装

signal profile_changed
signal money_changed(value: int)

# ============================================================
# 默认存档结构（对应原项目 DEFAULT）
# ============================================================
const _DEFAULT: Dictionary = {
	"achievements": {
		"hunter": 0, "destroyer": 0, "dodger": 0, "treasurer": 0,
		"ultracombo": 0, "gotcha": 0, "fired": 0, "nailed": 0, "survivor": 0,
	},
	"stats": {
		"tanksDestroyed": 0, "turretsDestroyed": 0, "spawnersDestroyed": 0,
		"wallsDestroyed": 0, "coinsCollected": 0, "barrelsExploded": 0,
		"cratesDestroyed": 0, "moneyEarned": 0,
	},
	"game": {
		"sound": true,
		"music": true,
		"completed": false,
		"helpMovingShown": false,
		"helpWeaponBought": false,
		"helpMinesBought": false,
		"helpWeaponsShown": false,
		"helpMinesShown": false,
		"weaponTabOpened": false,
		"refillHintDiscarded": false,
		"levels": 0,                       # 已解锁关卡数
		"points": [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],  # 每关最高分
		"difficulty": -1,                  # -1=未选, 0/1/2=简单/中/难
		"money": 0,
		"speed": 0, "turret": 0, "sight": 0, "armor": 0,
		"minigunLevel": 0,
		"shotgunLevel": -1, "shotgunAmmo": 0,
		"ricochetLevel": -1, "ricochetAmmo": 0,
		"flamethrowerLevel": -1, "flamethrowerAmmo": 0,
		"cannonLevel": -1, "cannonAmmo": 0,
		"shockLevel": -1, "shockAmmo": 0,
		"rocketsLevel": -1, "rocketsAmmo": 0,
		"laserLevel": -1, "laserAmmo": 0,
		"railgunLevel": -1, "railgunAmmo": 0,
		"minesLevel": -1, "minesAmmo": 0,
	},
}

# 存档文件名（位置由 _resolve_save_path 动态决定）
const SAVE_FILE_NAME := "save.json"
var SAVE_PATH: String = "user://save.json"

# 运行时数据（深拷贝自 _DEFAULT）
var current: Dictionary = {}

# ============================================================
# 生命周期
# ============================================================
func _ready() -> void:
	SAVE_PATH = _resolve_save_path()
	load_profile()

## 存档路径解析：
## - 编辑器 / H5 网页版：用 Godot 标准 user://（跨平台安全）
## - 桌面导出版（Windows/macOS/Linux）：放在可执行文件同目录，方便备份/分发
func _resolve_save_path() -> String:
	if OS.has_feature("editor") or OS.has_feature("web"):
		return "user://" + SAVE_FILE_NAME
	return OS.get_executable_path().get_base_dir().path_join(SAVE_FILE_NAME)

# ============================================================
# 存档 I/O
# ============================================================
func load_profile() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		reset()
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		current = _merge_defaults(parsed)
	else:
		reset()

func save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("无法写入存档: %s" % SAVE_PATH)
		return
	f.store_string(JSON.stringify(current, "\t"))
	f.close()

func reset() -> void:
	current = _deep_copy(_DEFAULT)
	# 用当前弹药上限填充初始弹药
	var g: Dictionary = current["game"]
	for key in Settings.AMMO_LIMITS:
		g[key + "Ammo"] = Settings.AMMO_LIMITS[key]
	save()

func is_achievement_completed(name: String) -> bool:
	return int(current["achievements"].get(name, 0)) >= Settings.ACHIEVEMENTS_LIMITS.get(name, 1)

func increase_achievement(name: String) -> bool:
	var a: Dictionary = current["achievements"]
	a[name] = int(a.get(name, 0)) + 1
	return a[name] >= Settings.ACHIEVEMENTS_LIMITS.get(name, 1)

func get_total_points() -> int:
	var total := 0
	for p in current["game"]["points"]:
		total += int(p)
	return total

func get_ammo_percent(weapon_key: String) -> float:
	var g: Dictionary = current["game"]
	var ammo := int(g.get(weapon_key + "Ammo", 0))
	var limit: int = Settings.AMMO_LIMITS.get(weapon_key, 1)
	return float(ammo) / float(limit)

# ============================================================
# 经济：金钱 / 购买
# ============================================================
func get_money() -> int:
	return int(current["game"]["money"])

func add_money(amount: int) -> void:
	current["game"]["money"] = get_money() + amount
	current["stats"]["moneyEarned"] += max(amount, 0)
	money_changed.emit(get_money())

func can_afford(price: int) -> bool:
	return get_money() >= price

func spend(price: int) -> bool:
	if not can_afford(price):
		return false
	current["game"]["money"] = get_money() - price
	money_changed.emit(get_money())
	return true

## 获取某武器当前等级（-1=未购买）
func get_weapon_level(weapon_key: String) -> int:
	return int(current["game"].get(weapon_key + "Level", -1))

func set_weapon_level(weapon_key: String, level: int) -> void:
	current["game"][weapon_key + "Level"] = level

func get_weapon_ammo(weapon_key: String) -> int:
	return int(current["game"].get(weapon_key + "Ammo", 0))

func set_weapon_ammo(weapon_key: String, ammo: int) -> void:
	var limit: int = Settings.AMMO_LIMITS.get(weapon_key, ammo)
	current["game"][weapon_key + "Ammo"] = clamp(ammo, 0, limit)

func get_performance_level(stat: String) -> int:
	return int(current["game"].get(stat, 0))

func set_performance_level(stat: String, level: int) -> void:
	current["game"][stat] = level

## 关卡结算：记录分数、解锁进度
func finish_level(index: int, points: int, success: bool) -> void:
	var g: Dictionary = current["game"]
	if index < g["points"].size():
		g["points"][index] = max(int(g["points"][index]), points)
	g["levels"] = max(int(g["levels"]), index + 1)
	if index + 1 >= Settings.LEVEL_COUNT:
		g["completed"] = true
	save()
	profile_changed.emit()

# ============================================================
# 场景切换
# ============================================================
func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)

func goto_level(index: int) -> void:
	# 通过资源占位参数把关卡索引传给 Level 场景
	_pending_level_index = index
	change_scene(Settings.SCENE_LEVEL)

var _pending_level_index: int = 0
func consume_pending_level_index() -> int:
	var i := _pending_level_index
	_pending_level_index = 0
	return i

# ============================================================
# 内部工具
# ============================================================
func _deep_copy(d: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for k in d:
		var v = d[k]
		if typeof(v) == TYPE_DICTIONARY:
			out[k] = _deep_copy(v)
		elif typeof(v) == TYPE_ARRAY:
			out[k] = (v as Array).duplicate(true)
		else:
			out[k] = v
	return out

func _merge_defaults(loaded: Dictionary) -> Dictionary:
	# 以 _DEFAULT 为骨架，把 loaded 的值覆盖进来，保证新字段存在
	var out := _deep_copy(_DEFAULT)
	_merge_dict(out, loaded)
	return out

func _merge_dict(into: Dictionary, from: Dictionary) -> void:
	for k in from:
		if into.has(k) and typeof(into[k]) == TYPE_DICTIONARY and typeof(from[k]) == TYPE_DICTIONARY:
			_merge_dict(into[k], from[k])
		else:
			into[k] = from[k]
