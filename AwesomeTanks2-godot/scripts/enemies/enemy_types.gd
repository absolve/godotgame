class_name ATEnemyTypes
## 敌人类型数据表（炮塔 / 生成器这类"同一形态、只有贴图与参数不同"的敌人）
##
## 背景：坦克 9 种与 Boss 7 种差异较大（车体/炮塔/武器/数值），各自保留独立场景
## （scenes/enemies/Enemy*.tscn、Boss*.tscn）；而炮塔 8 种结构完全一致、生成器 7 种
## 仅贴图与参数不同，因此合并为两个"形态场景"（TurretEnemy / Spawner），
## 具体类型由本表的数据决定（H5 也是这种结构：一个类 + 一组构造参数）。
##
## 数值来源：H5 awesome_tanks_2.js
##   炮塔子类 L21775-21861、别名 L21862-21880
##   生成器 L22299-22362（血量/points/spawnTypes）
## 基准：level.index=0、difficulty=1.0（炮塔血量在 H5 中不随难度缩放）

## 形态场景路径
const TURRET_SCENE := "res://scenes/enemies/TurretEnemy.tscn"
const SPAWNER_SCENE := "res://scenes/enemies/Spawner.tscn"
const WEAPON_DIR := "res://scenes/weapons/"
const TURRET_TEX := "res://sprites/game/turrets/"
const SPAWNER_TEX := "res://sprites/game/spawners/"

## H5 turretRotationSpeed 为 rad/s，本项目 rotate_turret 用 deg/s
const RAD2DEG := 57.29578

## 炮塔定义：类型名 → 参数
##   base/turret：sprites/game/turrets/<key>.png
##   weapon/params：武器场景名 + CPU 专用参数覆盖
const TURRETS: Dictionary = {
	"minigun": {
		"id": "turret_minigun", "base": "minigun_base", "turret": "minigun", "weapon": "minigun",
		"max_health": 400.0, "points": 400, "view_distance": 600.0, "turret_speed": 3.0, "shoot_angle": 10.0,
		"params": {"damage": 10.0, "rate": 6.0, "life": 0.5, "spawn_distance": 22.0},
	},
	"shotgun": {
		"id": "turret_shotgun", "base": "shotgun_base", "turret": "shotgun", "weapon": "shotgun",
		"max_health": 400.0, "points": 500, "view_distance": 600.0, "turret_speed": 3.0, "shoot_angle": 20.0,
		"params": {"damage": 15.0, "rate": 1.5, "life": 1.667, "spawn_count": 6, "spawn_distance": 20.0},
	},
	"cannon": {
		"id": "turret_cannon", "base": "cannon_base", "turret": "cannon", "weapon": "cannon",
		"max_health": 500.0, "points": 800, "view_distance": 600.0, "turret_speed": 3.0, "shoot_angle": 20.0,
		"params": {"damage": 200.0, "rate": 1.5, "life": 1.667, "spawn_distance": 30.0},
	},
	"rockets": {
		"id": "turret_rockets", "base": "rockets_base", "turret": "rockets", "weapon": "rockets",
		"max_health": 1000.0, "points": 900, "view_distance": 400.0, "turret_speed": 3.0, "shoot_angle": 25.0,
		"params": {"damage": 180.0, "rate": 0.5, "life": 3.333, "spawn_distance": 15.0},
	},
	"laser": {
		"id": "turret_laser", "base": "laser_base", "turret": "laser", "weapon": "laser",
		"max_health": 1250.0, "points": 1000, "view_distance": 600.0, "turret_speed": 3.0, "shoot_angle": 15.0,
		"params": {"damage": 6.0, "beam_dps": 360.0, "spawn_distance": 26.0},
	},
	"ricochet": {
		"id": "turret_ricochet", "base": "generic_base", "turret": "ricochet", "weapon": "ricochet",
		"max_health": 2000.0, "points": 600, "view_distance": 600.0, "turret_speed": 3.0, "shoot_angle": 30.0,
		"params": {"damage": 80.0, "rate": 6.0, "life": 1.667, "spawn_distance": 23.0},
	},
	"railgun": {
		"id": "turret_railgun", "base": "generic_base", "turret": "railgun", "weapon": "railgun",
		"max_health": 1500.0, "points": 1100, "view_distance": 400.0, "turret_speed": 1.75, "shoot_angle": 15.0,
		"params": {"damage": 333.0, "rate": 1.091, "spawn_distance": 30.0},
	},
	"flamethrower": {
		"id": "turret_flamethrower", "base": "generic_base", "turret": "flamethrower", "weapon": "flamethrower",
		"max_health": 1250.0, "points": 700, "view_distance": 400.0, "turret_speed": 3.0, "shoot_angle": 25.0,
		"params": {"damage": 1.0, "rate": 10.0, "life": 1.667, "spawn_distance": 26.0},
	},
}

## 瓦片 → 炮塔类型名
const TILE_TURRET: Dictionary = {
	Constants.Tile.TURRET_MINIGUN: "minigun",
	Constants.Tile.TURRET_SHOTGUN: "shotgun",
	Constants.Tile.TURRET_CANNON: "cannon",
	Constants.Tile.TURRET_ROCKETS: "rockets",
	Constants.Tile.TURRET_LASER: "laser",
	Constants.Tile.TURRET_RICOCHET: "ricochet",
	Constants.Tile.TURRET_RAILGUN: "railgun",
	Constants.Tile.TURRET_FLAMETHROWER: "flamethrower",
}

## 生成器定义：kind(0..6) → 血量/分数/产出表（H5 spawnTypes 展开为敌人场景名）
const SPAWNERS: Dictionary = {
	0: {"max_health": 150.0, "points": 1400, "spawn_types": [
		"EnemyMinigun", "EnemyMinigun", "EnemyMinigun", "EnemyShotgun", "EnemyShotgun", "EnemyRicochet"]},
	1: {"max_health": 250.0, "points": 1900, "spawn_types": [
		"EnemyShotgun", "EnemyShotgun", "EnemyShotgun", "EnemyRicochet", "EnemyRicochet", "EnemyFlamethrower"]},
	2: {"max_health": 400.0, "points": 2400, "spawn_types": [
		"EnemyRicochet", "EnemyRicochet", "EnemyRicochet", "EnemyFlamethrower", "EnemyFlamethrower", "EnemyCannon"]},
	3: {"max_health": 600.0, "points": 2900, "spawn_types": [
		"EnemyFlamethrower", "EnemyFlamethrower", "EnemyFlamethrower", "EnemyCannon", "EnemyCannon", "EnemyRockets"]},
	4: {"max_health": 800.0, "points": 3400, "spawn_types": [
		"EnemyCannon", "EnemyCannon", "EnemyCannon", "EnemyRockets", "EnemyRockets", "EnemyKamikaze"]},
	5: {"max_health": 1000.0, "points": 3900, "spawn_types": [
		"EnemyRockets", "EnemyRockets", "EnemyRockets", "EnemyKamikaze", "EnemyKamikaze", "EnemyLaser"]},
	6: {"max_health": 1000.0, "points": 4400, "spawn_types": [
		"EnemyKamikaze", "EnemyKamikaze", "EnemyKamikaze", "EnemyLaser", "EnemyLaser", "EnemyRailgun"]},
}

## 瓦片 → 生成器 kind
const TILE_SPAWNER: Dictionary = {
	Constants.Tile.SPAWNER_1: 0,
	Constants.Tile.SPAWNER_2: 1,
	Constants.Tile.SPAWNER_3: 2,
	Constants.Tile.SPAWNER_4: 3,
	Constants.Tile.SPAWNER_5: 4,
	Constants.Tile.SPAWNER_6: 5,
	Constants.Tile.SPAWNER_7: 6,
}
