extends Node
## Constants — 全局常量（瓦片字符 / 碰撞层 / 队伍）
## 对应原项目 window.AT.common / window.AT.TILES
## 已注册为 Autoload 全局节点，可直接用 Constants.XXX 访问。

# ============================================================
# 碰撞层（与 project.godot 的 layer_names 一一对应）
# Godot 用层索引（1-based）替代原项目的位掩码
# ============================================================
enum Layer {
	WALL = 1,            # 墙壁
	PLAYER = 2,          # 玩家
	PROJECTILE = 3,     # 子弹/投射物
	OBSTACLE = 4,        # 可破坏障碍物（砖墙/木箱/板条箱/油桶）
	ENEMY_SPAWNER = 5,   # 敌人生成器
	ENEMY = 6,           # 敌人
}

# 常用碰撞掩码工具
static func layer_mask(layers: Array) -> int:
	var mask := 0
	for l in layers:
		mask |= 1 << (l - 1)
	return mask

# ============================================================
# 队伍
# ============================================================
enum Team { PLAYER = 1, CPU = 2 }

# ============================================================
# 瓦片字符（移植自原项目 TILES）
## 关卡 ASCII 地图中每个字符对应一种瓦片/对象
# ============================================================
enum Tile {
	EMPTY,
	WALL,
	SECRET,
	BRICKS_2,
	BRICKS_1,
	GATE,
	WOOD,
	PLAYER,
	BARREL,
	CRATE,
	SPAWNER_1,
	SPAWNER_2,
	SPAWNER_3,
	SPAWNER_4,
	SPAWNER_5,
	SPAWNER_6,
	SPAWNER_7,
	TURRET_MINIGUN,
	TURRET_SHOTGUN,
	TURRET_CANNON,
	TURRET_ROCKETS,
	TURRET_LASER,
	TURRET_FLAMETHROWER,
	TURRET_RAILGUN,
	TURRET_RICOCHET,
	BOSS_SHOTGUN,
	BOSS_CANNON,
	BOSS_ROCKETS,
	BOSS_LASER,
	BOSS_RICOCHET,
	BOSS_FLAMETHROWER,
	BOSS_RAILGUN,
	TANK_MINIGUN,
	TANK_SHOTGUN,
	TANK_CANNON,
	TANK_ROCKETS,
	TANK_LASER,
	TANK_RICOCHET,
	TANK_FLAMETHROWER,
	TANK_RAILGUN,
	TANK_KAMIKAZE,
}

## 字符 -> Tile 枚举 映射（与原项目 TILES 完全一致）
const CHAR_TO_TILE: Dictionary = {
	" ": Tile.EMPTY,
	"█": Tile.WALL,
	"▓": Tile.SECRET,
	"▒": Tile.BRICKS_2,
	"░": Tile.BRICKS_1,
	"◘": Tile.GATE,
	"#": Tile.WOOD,
	"☻": Tile.PLAYER,
	"○": Tile.BARREL,
	"□": Tile.CRATE,
	"1": Tile.SPAWNER_1,
	"2": Tile.SPAWNER_2,
	"3": Tile.SPAWNER_3,
	"4": Tile.SPAWNER_4,
	"5": Tile.SPAWNER_5,
	"6": Tile.SPAWNER_6,
	"7": Tile.SPAWNER_7,
	"m": Tile.TURRET_MINIGUN,
	"s": Tile.TURRET_SHOTGUN,
	"c": Tile.TURRET_CANNON,
	"r": Tile.TURRET_ROCKETS,
	"l": Tile.TURRET_LASER,
	"f": Tile.TURRET_FLAMETHROWER,
	"x": Tile.TURRET_RAILGUN,
	"t": Tile.TURRET_RICOCHET,
	"S": Tile.BOSS_SHOTGUN,
	"C": Tile.BOSS_CANNON,
	"R": Tile.BOSS_ROCKETS,
	"L": Tile.BOSS_LASER,
	"T": Tile.BOSS_RICOCHET,
	"F": Tile.BOSS_FLAMETHROWER,
	"X": Tile.BOSS_RAILGUN,
	"❶": Tile.TANK_MINIGUN,
	"❷": Tile.TANK_SHOTGUN,
	"❸": Tile.TANK_CANNON,
	"❹": Tile.TANK_ROCKETS,
	"❺": Tile.TANK_LASER,
	"❻": Tile.TANK_RICOCHET,
	"❼": Tile.TANK_FLAMETHROWER,
	"❽": Tile.TANK_RAILGUN,
	"❾": Tile.TANK_KAMIKAZE,
}

## 判断瓦片是否为静态墙体（不可破坏）
func is_static_wall(tile: int) -> bool:
	return tile == Tile.WALL or tile == Tile.SECRET

## 判断瓦片是否为可破坏障碍物
func is_destructible(tile: int) -> bool:
	return tile in [Tile.BRICKS_1, Tile.BRICKS_2, Tile.WOOD, Tile.CRATE, Tile.BARREL]

## 判断瓦片是否为敌人单位
func is_enemy(tile: int) -> bool:
	return tile in [
		Tile.SPAWNER_1, Tile.SPAWNER_2, Tile.SPAWNER_3, Tile.SPAWNER_4,
		Tile.SPAWNER_5, Tile.SPAWNER_6, Tile.SPAWNER_7,
		Tile.TURRET_MINIGUN, Tile.TURRET_SHOTGUN, Tile.TURRET_CANNON,
		Tile.TURRET_ROCKETS, Tile.TURRET_LASER, Tile.TURRET_FLAMETHROWER,
		Tile.TURRET_RAILGUN, Tile.TURRET_RICOCHET,
		Tile.BOSS_SHOTGUN, Tile.BOSS_CANNON, Tile.BOSS_ROCKETS,
		Tile.BOSS_LASER, Tile.BOSS_RICOCHET, Tile.BOSS_FLAMETHROWER,
		Tile.BOSS_RAILGUN,
		Tile.TANK_MINIGUN, Tile.TANK_SHOTGUN, Tile.TANK_CANNON,
		Tile.TANK_ROCKETS, Tile.TANK_LASER,
		Tile.TANK_RICOCHET, Tile.TANK_FLAMETHROWER, Tile.TANK_RAILGUN,
		Tile.TANK_KAMIKAZE,
	]

## 判断瓦片是否为炮塔（固定）
func is_turret(tile: int) -> bool:
	return tile in [
		Tile.TURRET_MINIGUN, Tile.TURRET_SHOTGUN, Tile.TURRET_CANNON,
		Tile.TURRET_ROCKETS, Tile.TURRET_LASER, Tile.TURRET_FLAMETHROWER,
		Tile.TURRET_RAILGUN, Tile.TURRET_RICOCHET,
	]

## 判断瓦片是否为 Boss
func is_boss(tile: int) -> bool:
	return tile in [
		Tile.BOSS_SHOTGUN, Tile.BOSS_CANNON, Tile.BOSS_ROCKETS,
		Tile.BOSS_LASER, Tile.BOSS_RICOCHET, Tile.BOSS_FLAMETHROWER,
		Tile.BOSS_RAILGUN,
	]

## 判断瓦片是否为生成器
func is_spawner(tile: int) -> bool:
	return tile in [
		Tile.SPAWNER_1, Tile.SPAWNER_2, Tile.SPAWNER_3, Tile.SPAWNER_4,
		Tile.SPAWNER_5, Tile.SPAWNER_6, Tile.SPAWNER_7,
	]

# ============================================================
# 关卡主题
# ============================================================
enum gameTheme { GRASS, SNOW, DESERT }

const THEME_NAMES: Dictionary = {
	"grass": gameTheme.GRASS,
	"snow": gameTheme.SNOW,
	"desert": gameTheme.DESERT,
}
