class_name ATBonusTypes
extends RefCounted
## 奖励拾取物数据表（对应原项目 window.AT.bonus + Crate.getRandomBonus，见 H5 L20949~L21045 / L21229~L21239）
##
## 一个 bonus.tscn 靠 `Kind`（弹药类再带 weapon_key）区分 13 种动画，
## 本表给出：动画名、音效、效果参数、金币价值、箱子掉落权重、各敌人的掉币数量。

enum Kind { COIN, HEALTH, FREEZE, BOMB, AMMO, SMALL_ENEMY }

## 武器槽顺序（与 Level.SLOT_KEYS / ATPlayer.SLOT_KEYS 一致：索引 9 = mines）
const SLOT_KEYS: Array[String] = [
	"minigun", "shotgun", "ricochet", "flamethrower", "cannon",
	"shock", "rockets", "laser", "railgun", "mines",
]

## 末尾淡出时长（秒；H5: alpha = lifespan/333，即最后 0.33s）
const FADE_TIME := 0.33
## 箱子掷中金币时一次掉多少个（H5: spawnBonus(bonus, x, y, 15)）
const COIN_PER_CRATE_ROLL := 15
## 冻结时长（秒；H5: freezeTime = 250/60）
const FREEZE_DURATION := 250.0 / 60.0

## 每种奖励的通用参数（anim = SpriteFrames 动画名；life 不填则用 bonus.life 默认值）
const KINDS: Dictionary = {
	Kind.COIN: {"anim": "coin", "sfx": "coin.mp3", "sfx_db": -5.0},
	Kind.HEALTH: {"anim": "health", "sfx": "health.mp3"},
	Kind.FREEZE: {"anim": "freeze", "sfx": "freeze.mp3"},
	Kind.BOMB: {"anim": "bomb", "sfx": "bomb.mp3", "life": 1.0},   # H5: 炸弹 lifespan = 1s
	Kind.AMMO: {"sfx": "ammo.mp3"},
}

## 弹药类：weapon_key → 动画名 + 拾取量
## 注意拾取量和商店购买量不同（H5 原值）；电枪(shock) 复用激光贴图
const AMMO: Dictionary = {
	"shotgun": {"anim": "ammo_shotgun", "amount": 31},
	"ricochet": {"anim": "ammo_ricochet", "amount": 10},
	"flamethrower": {"anim": "ammo_flamethrower", "amount": 50},
	"cannon": {"anim": "ammo_cannon", "amount": 31},
	"shock": {"anim": "ammo_shock", "amount": 300},
	"rockets": {"anim": "ammo_rockets", "amount": 9},
	"laser": {"anim": "ammo_laser", "amount": 300},
	"railgun": {"anim": "ammo_railgun", "amount": 31},
	"mines": {"anim": "ammo_mines", "amount": 18},
}

## 小敌人：按关卡序号挑一档坦克（H5 bonus["SmallEnemy"] 的 a(t)：1:[雷管/霰弹/反弹] … 13:[…]）
const SMALL_ENEMY_TIERS: Dictionary = {
	1: ["minigun", "shotgun", "ricochet"],
	3: ["shotgun", "ricochet", "flamethrower"],
	5: ["ricochet", "flamethrower", "cannon"],
	7: ["flamethrower", "cannon", "rockets"],
	9: ["cannon", "rockets", "kamikaze"],
	11: ["rockets", "kamikaze", "laser"],
	13: ["kamikaze", "laser", "railgun"],
}

## 小敌人：坦克 key → 关卡瓦片（生成敌人用）
const SMALL_ENEMY_TILE: Dictionary = {
	"minigun": Constants.Tile.TANK_MINIGUN,
	"shotgun": Constants.Tile.TANK_SHOTGUN,
	"ricochet": Constants.Tile.TANK_RICOCHET,
	"flamethrower": Constants.Tile.TANK_FLAMETHROWER,
	"cannon": Constants.Tile.TANK_CANNON,
	"rockets": Constants.Tile.TANK_ROCKETS,
	"kamikaze": Constants.Tile.TANK_KAMIKAZE,
	"laser": Constants.Tile.TANK_LASER,
	"railgun": Constants.Tile.TANK_RAILGUN,
}

## 金币价值（H5 Level.collect： (number<11 ? 12 : 15) * (1 + .8567 * index) * difficulty）
const COIN_BASE := 12.0
const COIN_BASE_LATE := 15.0
const COIN_LEVEL_GAIN := 0.8567
const COIN_LATE_FROM_NUMBER := 11


# ============================================================
# 基础查询
# ============================================================
## 动画名（SpriteFrames 里的名字）
static func anim_name(kind: int, weapon_key: String = "") -> String:
	if kind == Kind.AMMO:
		return str(AMMO.get(weapon_key, {}).get("anim", "ammo_shotgun"))
	return str(KINDS.get(kind, {}).get("anim", "coin"))


## 该 kind 的拾取音效（含音量偏移）→ {file, db}
static func pickup_sfx(kind: int) -> Dictionary:
	var def: Dictionary = KINDS.get(kind, {})
	return {"file": str(def.get("sfx", "")), "db": float(def.get("sfx_db", 0.0))}


## 该 kind 的存活时间（秒）
static func life_of(kind: int, fallback: float) -> float:
	return float(KINDS.get(kind, {}).get("life", fallback))


## 弹药拾取量
static func ammo_amount(weapon_key: String) -> int:
	return int(AMMO.get(weapon_key, {}).get("amount", 0))


## 单枚金币价值（number = 关卡序号从 1 起、index = 从 0 起、difficulty = 难度倍率）
static func coin_value(level_index: int, difficulty: float) -> float:
	var number := level_index + 1
	var base := COIN_BASE if number < COIN_LATE_FROM_NUMBER else COIN_BASE_LATE
	return base * (1.0 + COIN_LEVEL_GAIN * float(level_index)) * difficulty


# ============================================================
# 掉落：敌人 / 箱子
# ============================================================
## 敌人死亡掉多少金币（H5：坦克/炮塔 4~6、Boss 14~16、生成器按已产出数递减、Kamikaze 仅被打死才掉）
static func coin_drop_for_enemy(e: Node) -> int:
	if e == null or not is_instance_valid(e):
		return 0
	var id := str(e.get("enemy_id")) if "enemy_id" in e else ""
	var is_boss := false
	if "is_boss" in e:
		is_boss = bool(e.get("is_boss"))
	if is_boss:
		return 14 + randi() % 3
	if id.begins_with("spawner"):
		var spawned := 0
		if "_spawned" in e and e.get("_spawned") is Array:
			spawned = (e.get("_spawned") as Array).size()
		return int(floor(7.0 + 3.0 * randf() + (4.0 + 3.0 * randf()) * float(6 - spawned)))
	if id.begins_with("turret"):
		return 4 + randi() % 3
	# Kamikaze 自爆时 H5 不给币（this.coins=false）；本项目自爆尚未实现，先都掉
	return 4 + randi() % 3


## 箱子掉落（H5 Crate.getRandomBonus）：权重随血量/弹药动态变化
## 返回 { kind, weapon_key?, amount? }
static func pick_crate_bonus(level: Node, player: Node) -> Dictionary:
	# ① 敌人清空 → 必掉金币；② 血量 < 25% → 必掉医疗包（H5 两条早退规则）
	if level != null and is_instance_valid(level) and int(level.get("enemies_alive")) == 0:
		return {"kind": Kind.COIN}
	var hp := 1.0
	if player != null and is_instance_valid(player) and "health" in player and "max_health" in player:
		hp = clampf(float(player.health) / maxf(float(player.max_health), 1.0), 0.0, 1.0)
	if hp < 0.25:
		return {"kind": Kind.HEALTH}

	var entries: Array = [
		{"kind": Kind.HEALTH, "weight": 2.0 * (1.0 - hp) if hp < 0.75 else 0.0},
		{"kind": Kind.FREEZE, "weight": 1.0},
		{"kind": Kind.COIN, "weight": 1.0},
	]
	for key in AMMO:
		entries.append({"kind": Kind.AMMO, "weapon_key": key, "weight": _ammo_weight(player, key)})
	var first_level := level != null and is_instance_valid(level) and int(level.get("level_index")) == 0
	entries.append({"kind": Kind.BOMB, "weight": 0.0 if first_level else 0.1})
	entries.append({"kind": Kind.SMALL_ENEMY, "weight": 0.1})

	var weights: Array = []
	for e in entries:
		weights.append(float(e["weight"]))
	var idx := weighted_pick(weights)
	var picked: Dictionary = entries[idx]
	if int(picked["kind"]) == Kind.AMMO:
		picked["amount"] = ammo_amount(str(picked["weapon_key"]))
	return picked


## 弹药权重：弹药越少越高；满弹 / 没拥有该武器 = 0（H5 ammoWeightFor）
static func _ammo_weight(player: Node, weapon_key: String) -> float:
	if player == null or not is_instance_valid(player) or not ("weapons" in player):
		return 0.0
	var idx := SLOT_KEYS.find(weapon_key)
	if idx < 0:
		return 0.0
	var weapons: Array = player.get("weapons")
	var w = weapons[idx] if idx < weapons.size() else null
	if w == null or not is_instance_valid(w):
		return 0.0
	var max_ammo := float(w.get("max_ammo"))
	if max_ammo <= 0.0 or max_ammo >= 999999.0:
		return 0.0
	return 2.0 * (1.0 - float(w.get("ammo")) / max_ammo)


## 小敌人要生成的坦克 key（按关卡序号选档，档内等权）
static func small_enemy_tank(level_index: int) -> String:
	var number := level_index + 1
	var tier := 1
	for key in [13, 11, 9, 7, 5, 3, 1]:
		if number >= int(key):
			tier = int(key)
			break
	var pool: Array = SMALL_ENEMY_TIERS[tier]
	return str(pool[randi() % pool.size()])


## 按权重随机取下标（H5 common.weightedChoice）
static func weighted_pick(weights: Array) -> int:
	var total := 0.0
	for w in weights:
		total += maxf(float(w), 0.0)
	if total <= 0.0:
		return 0
	var roll := randf() * total
	var acc := 0.0
	for i in weights.size():
		acc += maxf(float(weights[i]), 0.0)
		if roll <= acc:
			return i
	return weights.size() - 1
