class_name ATFog
extends Node2D
## Fog —— 战争迷雾管理器（逐格黑雾瓦片版）
##
## 设计（对照 H5 window.AT.Fog 的“逐格揭示”语义，改为节点式实现）：
##   1) 地图加载时按地图尺寸逐格创建黑雾瓦片（scenes/level/fog_tile.tscn =
##      Area2D + 黑色贴图 fog_tile.png（12×12，按 tile 放大）+ tile 尺寸判定），
##      每个地图格一个瓦片，铺满整张地图；
##   2) 玩家按炮塔方向发射射线（物理射线，见 reveal_fov）：射线同时与
##      “墙壁/障碍”和“黑雾瓦片”发生碰撞——
##        · 打到黑雾瓦片 → 该瓦片播放消失动画，射线继续向前推进；
##        · 打到墙/障碍   → 射线终止（墙后、箱子后的黑雾不会被清掉）；
##   3) 每条视野射线穿过多少格黑雾就清多少格，永久保持清除（不回收）；
##   4) 玩家所在格周围一圈黑雾也会被清掉（保证能看到自己，对应 H5 revealTileArea）。
##
## 场景：scenes/level/fog.tscn（本脚本挂在根节点上，由 Level 实例化）。

const TILE_SCENE: PackedScene = preload("res://scenes/level/fog_tile.tscn")

## 视野射线一次最多推进的段数（防止极端情况下死循环）
const MAX_RAY_STEPS: int = 64
## 射线推进的最小剩余距离（小于它就不再发射线）
const MIN_REMAIN: float = 2.0

@export var tile_size: int = Settings.TILE_SIZE
## 玩家脚下清除半径（瓦片）
@export var clear_radius_tiles: float = 1.35
## 是否打开位置/朝向缓存（玩家不动不转时不重复发射线）
@export var cache_enabled: bool = true
## 黑雾瓦片判定区相对 tile 的放大倍数（>1：射线提前命中，黑雾不用贴近才消失）
@export var tile_collision_scale: float = 1.8

var fog_width: int = 0
var fog_height: int = 0
var tiles: Array = []                 # tiles[y][x] = ATFogTile 或 null（已清除）
var tile_offset_x: int = 0
var tile_offset_y: int = 0

var _last_center := Vector2.INF
var _last_aim := INF


# ============================================================
# 构建
# ============================================================
func configure(offset_x: int, offset_y: int, w: int, h: int) -> void:
	tile_offset_x = offset_x
	tile_offset_y = offset_y
	fog_width = w
	fog_height = h


## 按地图逐格创建黑雾瓦片（地图加载时调用一次）
func build_tiles() -> void:
	for y in range(fog_height):
		var row: Array = []
		for x in range(fog_width):
			row.append(null)
		tiles.append(row)
	for y in range(fog_height):
		for x in range(fog_width):
			_add_tile(x, y)


func _add_tile(x: int, y: int) -> void:
	var t: ATFogTile = TILE_SCENE.instantiate()
	t.tile_x = x
	t.tile_y = y
	t.collision_scale = tile_collision_scale   # 必须在入树(_ready)前赋值
	t.position = cell_center(x, y)
	t.z_index = 100   # 盖住地图与单位
	t.disappeared.connect(_on_tile_disappeared)
	add_child(t)
	tiles[y][x] = t


func _on_tile_disappeared(tile: ATFogTile) -> void:
	if tile.tile_y >= 0 and tile.tile_y < fog_height \
			and tile.tile_x >= 0 and tile.tile_x < fog_width:
		if tiles[tile.tile_y][tile.tile_x] == tile:
			tiles[tile.tile_y][tile.tile_x] = null


# ============================================================
# 坐标/查询
# ============================================================
func cell_center(x: int, y: int) -> Vector2:
	return Vector2((x + tile_offset_x + 0.5) * tile_size,
		(y + tile_offset_y + 0.5) * tile_size)


func tile_at(x: int, y: int) -> ATFogTile:
	if x < 0 or y < 0 or x >= fog_width or y >= fog_height:
		return null
	return tiles[y][x]


func is_cleared(x: int, y: int) -> bool:
	return tile_at(x, y) == null


func remaining_count() -> int:
	var n := 0
	for row in tiles:
		for t in row:
			if t != null and is_instance_valid(t):
				n += 1
	return n


## 清除一格（射线命中或外部调用）。返回是否真的清掉。
func clear_tile(x: int, y: int, animate: bool = true) -> bool:
	var t := tile_at(x, y)
	if t == null or not is_instance_valid(t) or t.cleared:
		return false
	tiles[y][x] = null
	t.clear(animate)
	return true


## 清除以某瓦片为中心、半径 radius(瓦片) 内的黑雾（玩家脚下）
func clear_area(center_x: int, center_y: int, radius: float) -> int:
	var n := 0
	var r := maxf(radius, 0.0)
	var x0 := int(floor(center_x - r))
	var x1 := int(ceil(center_x + r))
	var y0 := int(floor(center_y - r))
	var y1 := int(ceil(center_y + r))
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var dx := float(x - center_x)
			var dy := float(y - center_y)
			if dx * dx + dy * dy <= r * r:
				if clear_tile(x, y, true):
					n += 1
	return n


# ============================================================
# 视野射线（核心）
# ============================================================
## 按炮塔朝向发射扇形视野射线：半角 half_angle、距离 dist(px)。
## center 为玩家炮塔位置(px)，aim 为炮塔朝向(rad)。
## 返回本次新清除的黑雾格数。
func reveal_fov(center: Vector2, aim: float, half_angle: float, dist: float) -> int:
	if fog_width <= 0 or fog_height <= 0:
		return 0
	if cache_enabled and _last_center.distance_to(center) < 0.5 \
			and absf(wrapf(aim - _last_aim, -PI, PI)) < 0.01:
		return 0
	_last_center = center
	_last_aim = aim

	var cleared := 0
	# 起点所在格：射线从瓦片内部出发不会命中自身，这里直接清掉（玩家脚下可见）
	var otx := int(center.x / tile_size) - tile_offset_x
	var oty := int(center.y / tile_size) - tile_offset_y
	if clear_tile(otx, oty, true):
		cleared += 1
	var step_a := TAU / 36.0            # 每 10° 一条射线（同 H5）
	var a := aim - half_angle
	while a <= aim + half_angle + 0.0001:
		cleared += _cast_ray(center, a, dist)
		a += step_a
	return cleared


## 单条射线：反复与“黑雾瓦片 / 墙”碰撞
##   命中黑雾 → 清除该瓦片并从命中点继续前进（exclude 掉它，避免重复命中）
##   命中墙/障碍 → 结束
func _cast_ray(origin: Vector2, angle: float, dist: float) -> int:
	var space := get_world_2d().direct_space_state
	if space == null:
		return 0
	var dir := Vector2.RIGHT.rotated(angle)
	var mask := Constants.layer_mask([
		Constants.Layer.WALL, Constants.Layer.OBSTACLE,
		Constants.Layer.ENEMY_SPAWNER, Constants.Layer.FOG,
	])
	var exclude: Array[RID] = []
	var pos := origin
	var cleared := 0
	var steps := 0
	while steps < MAX_RAY_STEPS:
		steps += 1
		var remain := dist - origin.distance_to(pos)
		if remain <= MIN_REMAIN:
			break
		var q := PhysicsRayQueryParameters2D.create(pos, pos + dir * remain, mask)
		q.collide_with_areas = true     # 黑雾是 Area2D
		q.collide_with_bodies = true    # 墙/障碍是 StaticBody2D
		q.exclude = exclude
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			break
		var collider = hit.get("collider")
		var point: Vector2 = hit.get("position")
		if collider is ATFogTile:
			var ft := collider as ATFogTile
			# 命中黑雾：清除（带动画）并继续
			if not ft.cleared:
				clear_tile(ft.tile_x, ft.tile_y, true)
				cleared += 1
			if not exclude.has(ft.get_rid()):
				exclude.append(ft.get_rid())
			pos = point + dir * 1.0
			continue
		# 墙/障碍/其它实体：射线被挡住，结束
		break
	return cleared


## 便捷：清除某世界坐标所在格的（及周边）黑雾（供敌人开火/被击中暴露等调用）
func reveal_at_world(pos: Vector2, radius_tiles: float = 0.0) -> int:
	var tx := int(pos.x / tile_size) - tile_offset_x
	var ty := int(pos.y / tile_size) - tile_offset_y
	if radius_tiles <= 0.0:
		return 1 if clear_tile(tx, ty, true) else 0
	return clear_area(tx, ty, radius_tiles)


## 重置缓存（强制下次 reveal_fov 一定发射线）
func invalidate_cache() -> void:
	_last_center = Vector2.INF
	_last_aim = INF
