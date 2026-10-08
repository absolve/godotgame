extends Node
## Game — 全局游戏状态/存档/经济管理单例（移植自原项目 window.AT.profile）
##
## 负责：
##   - 存档的读取/保存/重置（Godot FileAccess + JSON，替代 localStorage）
##   - 玩家进度数据（金钱、关卡、武器等级、弹药、成就、统计）
##   - 场景切换封装

signal profileChanged
signal moneyChanged(value: int)

# ============================================================
# 默认存档结构（对应原项目 DEFAULT）
# ============================================================
const DEFAULT_PROFILE: Dictionary = {
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
var savePath: String = "user://save.json"

# 运行时数据（深拷贝自 DEFAULT_PROFILE）
var current: Dictionary = {}
var pendingLevelIndex: int = 0

# ============================================================
# 生命周期
# ============================================================
func _ready() -> void:
	savePath = resolveSavePath()
	loadProfile()

## 存档路径解析：
## - 编辑器 / H5 网页版：用 Godot 标准 user://（跨平台安全）
## - 桌面导出版（Windows/macOS/Linux）：放在可执行文件同目录，方便备份/分发
func resolveSavePath() -> String:
	if OS.has_feature("editor") or OS.has_feature("web"):
		return "user://" + SAVE_FILE_NAME
	return OS.get_executable_path().get_base_dir().path_join(SAVE_FILE_NAME)

# ============================================================
# 存档 I/O
# ============================================================
func loadProfile() -> void:
	var f := FileAccess.open(savePath, FileAccess.READ)
	if f == null:
		reset()
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		current = mergeDefaults(parsed)
	else:
		reset()

func save() -> void:
	var f := FileAccess.open(savePath, FileAccess.WRITE)
	if f == null:
		push_warning("无法写入存档: %s" % savePath)
		return
	f.store_string(JSON.stringify(current, "\t"))
	f.close()

func reset() -> void:
	current = deepCopy(DEFAULT_PROFILE)
	# 用当前弹药上限填充初始弹药
	var g: Dictionary = current["game"]
	for key in Settings.AMMO_LIMITS:
		g[key + "Ammo"] = Settings.AMMO_LIMITS[key]
	save()

func isAchievementCompleted(achievementName: String) -> bool:
	return int(current["achievements"].get(achievementName, 0)) >= Settings.ACHIEVEMENTS_LIMITS.get(name, 1)

func increaseAchievement(achievementName: String) -> bool:
	var a: Dictionary = current["achievements"]
	a[achievementName] = int(a.get(achievementName, 0)) + 1
	return a[achievementName] >= Settings.ACHIEVEMENTS_LIMITS.get(achievementName, 1)

func getTotalPoints() -> int:
	var total := 0
	for p in current["game"]["points"]:
		total += int(p)
	return total

func getAmmoPercent(weaponKey: String) -> float:
	var g: Dictionary = current["game"]
	var ammo := int(g.get(weaponKey + "Ammo", 0))
	var limit: int = Settings.AMMO_LIMITS.get(weaponKey, 1)
	return float(ammo) / float(limit)

# ============================================================
# 经济：金钱 / 购买
# ============================================================
func getMoney() -> int:
	return int(current["game"]["money"])

func addMoney(amount: int) -> void:
	current["game"]["money"] = getMoney() + amount
	current["stats"]["moneyEarned"] += max(amount, 0)
	moneyChanged.emit(getMoney())

func canAfford(price: int) -> bool:
	return getMoney() >= price

func spend(price: int) -> bool:
	if not canAfford(price):
		return false
	current["game"]["money"] = getMoney() - price
	moneyChanged.emit(getMoney())
	return true

## 获取某武器当前等级（-1=未购买）
func getWeaponLevel(weaponKey: String) -> int:
	return int(current["game"].get(weaponKey + "Level", -1))

func setWeaponLevel(weaponKey: String, level: int) -> void:
	current["game"][weaponKey + "Level"] = level

func getWeaponAmmo(weaponKey: String) -> int:
	return int(current["game"].get(weaponKey + "Ammo", 0))

func setWeaponAmmo(weaponKey: String, ammo: int) -> void:
	var limit: int = Settings.AMMO_LIMITS.get(weaponKey, ammo)
	current["game"][weaponKey + "Ammo"] = clamp(ammo, 0, limit)

func getPerformanceLevel(stat: String) -> int:
	return int(current["game"].get(stat, 0))

func setPerformanceLevel(stat: String, level: int) -> void:
	current["game"][stat] = level

## 关卡结算：记录分数、解锁进度
func finishLevel(index: int, points: int, success: bool) -> void:
	var g: Dictionary = current["game"]
	# 关卡数不再固定 15，按需扩展"每关最高分"数组
	var scores: Array = g["points"]
	while scores.size() <= index:
		scores.append(0)
	scores[index] = max(int(scores[index]), points)
	g["levels"] = max(int(g["levels"]), index + 1)
	if index + 1 >= ATLevels.LEVELS.size():
		g["completed"] = true
	save()
	profileChanged.emit()

# ============================================================
# 场景切换
# ============================================================
## 切场景（所有切场景都走这里 → 转发给 SceneTransition 自动加载做擦除过渡）
## SceneTransition 不在时退回引擎直接切，保证任何时候都能切
func changeScene(path: String, duration: float = 0.0) -> void:
	var st := get_node_or_null("/root/SceneTransition")
	if st != null and st.has_method("changeScene"):
		if duration > 0.0:
			st.call("changeScene", path, duration)
		else:
			st.call("changeScene", path)
		return
	get_tree().change_scene_to_file(path)

func gotoLevel(index: int) -> void:
	# 通过资源占位参数把关卡索引传给 Level 场景
	pendingLevelIndex = index
	changeScene(Settings.SCENE_LEVEL)

func consumePendingLevelIndex() -> int:
	var i := pendingLevelIndex
	pendingLevelIndex = 0
	return i

# ---------- 金额格式化 ----------
func formatMoney(v: int) -> String:
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
# 内部工具
# ============================================================
func deepCopy(d: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for k in d:
		var v = d[k]
		if typeof(v) == TYPE_DICTIONARY:
			out[k] = deepCopy(v)
		elif typeof(v) == TYPE_ARRAY:
			out[k] = (v as Array).duplicate(true)
		else:
			out[k] = v
	return out

func mergeDefaults(loaded: Dictionary) -> Dictionary:
	# 以 DEFAULT_PROFILE 为骨架，把 loaded 的值覆盖进来，保证新字段存在
	var out := deepCopy(DEFAULT_PROFILE)
	mergeDict(out, loaded)
	return out

func mergeDict(into: Dictionary, from: Dictionary) -> void:
	for k in from:
		if into.has(k) and typeof(into[k]) == TYPE_DICTIONARY and typeof(from[k]) == TYPE_DICTIONARY:
			mergeDict(into[k], from[k])
		else:
			into[k] = from[k]
