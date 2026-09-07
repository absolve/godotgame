extends Node
## Settings — 全局常量与数值表（移植自原项目 window.AT.SETTINGS）
## 这里集中存放所有可调参数，方便后续平衡性调整。

# ============================================================
# 瓦片尺寸
# ============================================================
const TILE_SIZE: int = 52

# ============================================================
# 难度系数（[0.65, 0.85, 1.0]，分别对应 简单/中等/困难）
# ============================================================
const DIFFICULTIES: Array[float] = [0.65, 0.85, 1.0]

# ============================================================
# 成就达成次数上限
# ============================================================
const ACHIEVEMENTS_LIMITS: Dictionary = {
	"hunter": 15,
	"destroyer": 80,
	"dodger": 15,
	"treasurer": 35,
	"ultracombo": 1,
	"gotcha": 15,
	"fired": 15,
	"nailed": 1,
	"survivor": 1,
}

# ============================================================
# 武器枚举（索引对应玩家 weapons 数组槽位）
# 0=minigun,1=shotgun,2=ricochet,3=flamethrower,4=cannon,
# 5=shock,6=rockets,7=laser,8=railgun；mines 单独管理
# ============================================================
enum Weapon {
	MINIGUN, # 无限弹药，默认武器
	SHOTGUN, # 散射
	RICOCHET, # 弹跳子弹
	FLAMETHROWER, # 火焰
	CANNON, # 等离子弹
	SHOCK, # 闪电链
	ROCKETS, # 追踪火箭
	LASER, # 激光束
	RAILGUN, # 射线穿透
}
const WEAPON_KEYS: Array[String] = [
	"minigun", "shotgun", "ricochet", "flamethrower", "cannon",
	"shock", "rockets", "laser", "railgun"
]
const MINES_KEY: String = "mines"

# ============================================================
# 弹药上限（每种武器最大携带弹药）
# ============================================================
const AMMO_LIMITS: Dictionary = {
	"shotgun": 105,
	"ricochet": 50,
	"flamethrower": 236,
	"cannon": 105,
	"shock": 1500,
	"rockets": 45,
	"laser": 1500,
	"railgun": 105,
	"mines": 20,
}

# ============================================================
# 购买/升级价格表（数组：[购买价, 升级1, 升级2, 升级3, 升级4, 升级5]）
# minigun 不需购买，购买价=0
# ============================================================
const PRICES: Dictionary = {
	"speed": [500, 600, 700, 800, 900],
	"turret": [500, 600, 700, 800, 900],
	"sight": [500, 600, 700, 800, 900],
	"armor": [2000, 4000, 8000, 16000, 20000],
	"minigun": [0, 200, 300, 400, 500, 600],
	"shotgun": [2750, 500, 900, 1300, 1700, 2100],
	"ricochet": [8000, 2500, 3000, 3500, 4000, 4500],
	"flamethrower": [10000, 3000, 4000, 5000, 6000, 7000],
	"cannon": [10000, 3000, 4000, 5000, 6000, 7000],
	"shock": [10000, 3000, 4000, 5000, 6000, 7000],
	"rockets": [10000, 3000, 4000, 5000, 6000, 7000],
	"laser": [28000, 11000, 12000, 13000, 14000, 15000],
	"railgun": [28000, 11000, 12000, 13000, 14000, 15000],
	"mines": [8000, 2500, 3000, 3500, 4000, 4500],
}

# ============================================================
# 弹药补充：每次补充价格 与 补充数量
# ============================================================
const AMMO_PRICES: Dictionary = {
	"shotgun": 50, "ricochet": 100, "flamethrower": 200, "cannon": 200,
	"shock": 200, "rockets": 200, "laser": 300, "railgun": 400, "mines": 300,
}
const AMMO_AMOUNT: Dictionary = {
	"shotgun": 21, "ricochet": 10, "flamethrower": 48, "cannon": 21,
	"shock": 300, "rockets": 9, "laser": 300, "railgun": 21, "mines": 4,
}

# ============================================================
# 武器每级参数（6 档：索引 0=初始 … 5=满级，对应存档 weaponLevel）
# 数值提取自原项目 awesome_tanks_2.js：
#   - 玩家装配配置 L22379~22475，数组定义 L22513~22534
#   - 语义：rate=每秒射次；life=子弹存活秒；damage=单发/单跳伤害；
#     H5 分数形式（如 60/56）已换算为小数
# 使用：player._level_params(key, level) 取出并覆盖武器场景默认值
# ============================================================
const WEAPON_STATS: Dictionary = {
	# 机枪：射速 8.57→20 发/秒；弹存活 0.267→0.5s；伤害 4（满级 5）
	"minigun": {
		"damage": [4, 4, 4, 4, 4, 5],
		"rate": [8.571, 10, 12, 15, 20, 20],
		"life": [0.267, 0.343, 0.42, 0.5, 0.5, 0.5],
	},
	# 霰弹：弹丸数 4→10；射速 1→1.5；单丸伤害 25→22
	"shotgun": {
		"damage": [25, 22, 22, 22, 22, 22],
		"rate": [1, 1.071, 1.154, 1.25, 1.364, 1.5],
		"life": [1.3, 1.3, 1.3, 1.3, 1.3, 1.3],
		"spawn_count": [4, 5, 6, 8, 9, 10],
	},
	# 反弹（蓄力）：伤害 75→249
	"ricochet": {
		"damage": [75, 110, 145, 180, 215, 249],
	},
	# 火焰：伤害 20→40、射速 12/s、弹存活 1.5→2.33s
	"flamethrower": {
		"damage": [20, 24, 28, 32, 36, 40],
		"rate": [12, 12, 12, 12, 12, 12],
		"life": [1.5, 1.667, 1.833, 2.0, 2.167, 2.333],
	},
	# 加农：伤害 457→1017；射速 1.09→1.71；炮弹存活 1→2s
	"cannon": {
		"damage": [457, 569, 681, 793, 905, 1017],
		"rate": [1.091, 1.176, 1.277, 1.395, 1.538, 1.714],
		"life": [1, 1.333, 1.667, 2, 2, 2],
	},
	# 闪电链：单跳伤害 2→7（H5 K 表）
	"shock": {
		"damage": [2, 3, 4, 5, 6, 7],
	},
	# 火箭：伤害 1000→2500；存活 5→10s；速度因子 0.5→2（实际 px/s≈60×因子）
	"rockets": {
		"damage": [1000, 1300, 1600, 1900, 2200, 2500],
		"life": [5, 6.667, 8.333, 10, 10, 10],
		"velocity": [0.5, 1, 1.5, 2, 2, 2],
	},
	# 激光：瞬时命中伤害 8→28（H5 tt 表；光束侧再按帧换算 DPS）
	"laser": {
		"damage": [8, 12, 16, 20, 24, 28],
	},
	# 轨道炮：伤害 500→750；射速 1→1.5
	"railgun": {
		"damage": [500, 550, 600, 650, 700, 750],
		"rate": [1, 1.071, 1.154, 1.25, 1.364, 1.5],
	},
	# 地雷：伤害固定（H5 取 ot[0]=457），半径 75
	"mines": {
		"damage": [457, 457, 457, 457, 457, 457],
	},
}

# ============================================================
# 玩家性能升级档位（6 级，对应 PRICES 中 5 个升级价：初始 + 5 次升级）
# 来源：原项目 awesome_tanks_2.js L22535
#   ARMOR_LEVELS          — 最大血量
#   SPEED_LEVELS          — 移动速度（像素/秒，原项目基于 Box2D 速度）
#   ACCELERATION_LEVELS   — 加速度系数
#   TURRET_LEVELS         — 炮塔转速档位
#   VIEW_ANGLE_LEVELS     — 视野角度（弧度）
#   VIEW_DISTANCE_LEVELS  — 视野距离（像素）
# ============================================================
const ARMOR_LEVELS: Array[float] = [700.0, 1260.0, 2100.0, 3220.0, 4900.0, 6300.0]
const SPEED_LEVELS: Array[float] = [159.84, 170.88, 182.4, 192.0, 204.96, 216.0]
const ACCELERATION_LEVELS: Array[float] = [0.2, 0.23, 0.26, 0.3, 0.32, 0.34]
const TURRET_LEVELS: Array[float] = [4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
const VIEW_ANGLE_LEVELS: Array[float] = [
	PI / 4.0,
	PI / 3.5,
	PI / 2.5,
	PI / 2.0,
	PI / 1.5,
	PI,
]
const VIEW_DISTANCE_LEVELS: Array[float] = [230.0, 250.0, 270.0, 300.0, 320.0, 350.0]

# ============================================================
# 场景路径
# ============================================================
const SCENE_BOOT = "res://scenes/Boot.tscn"
const SCENE_TITLE = "res://scenes/Title.tscn"
const SCENE_UPGRADES = "res://scenes/Upgrades.tscn"
const SCENE_LEVEL_SELECT = "res://scenes/LevelSelect.tscn"
const SCENE_LEVEL = "res://scenes/Level.tscn"
const SCENE_CONGRATULATIONS = "res://scenes/Congratulations.tscn"
const SCENE_EDITOR = "res://scenes/LevelEditor.tscn"

# 关卡总数（正式关卡）
const LEVEL_COUNT: int = 15

# 自定义关卡目录（编辑器保存的关卡存放处）
const CUSTOM_LEVELS_DIR := "user://custom_levels/"
