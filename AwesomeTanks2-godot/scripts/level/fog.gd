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
## 视线清雾时"每格延迟"（秒）：离坦克越远越晚淡出，看起来就是视野从坦克向外扫开
const CLEAR_STAGGER: float = 0.035

@export var tileSize: int = Settings.TILE_SIZE
## 玩家脚下清除半径（瓦片）
@export var clearRadiusTiles: float = 1.35
## 是否打开位置/朝向缓存（玩家不动不转时不重复发射线）
@export var cacheEnabled: bool = true
## 黑雾瓦片判定区相对 tile 的放大倍数。
## 1.0 = 判定框正好一格：配合 clearSegment（沿射线走过的格子逐个清）不会漏格，
## 也不会因为框比格子大而在视野边缘多清出孤立的一两格（看起来像零星消失）。
@export var tileCollisionScale: float = 1.0

var fogWidth: int = 0
var fogHeight: int = 0
var tiles: Array = []                 # tiles[y][x] = ATFogTile 或 null（已清除）
var tileOffsetX: int = 0
var tileOffsetY: int = 0

var lastCenter := Vector2.INF
var lastAim := INF


# ============================================================
# 构建
# ============================================================
func configure(offsetX: int, offsetY: int, w: int, h: int) -> void:
	tileOffsetX = offsetX
	tileOffsetY = offsetY
	fogWidth = w
	fogHeight = h


## 按地图逐格创建黑雾瓦片（地图加载时调用一次）
func buildTiles() -> void:
	for y in range(fogHeight):
		var row: Array = []
		for x in range(fogWidth):
			row.append(null)
		tiles.append(row)
	for y in range(fogHeight):
		for x in range(fogWidth):
			addTile(x, y)


func addTile(x: int, y: int) -> void:
	var t: ATFogTile = TILE_SCENE.instantiate()
	t.tileX = x
	t.tileY = y
	t.collisionScale = tileCollisionScale   # 必须在入树(_ready)前赋值
	t.position = cellCenter(x, y)
	t.z_index = 100   # 盖住地图与单位
	t.disappeared.connect(onTileDisappeared)
	add_child(t)
	tiles[y][x] = t


func onTileDisappeared(tile: ATFogTile) -> void:
	if tile.tileY >= 0 and tile.tileY < fogHeight \
			and tile.tileX >= 0 and tile.tileX < fogWidth:
		if tiles[tile.tileY][tile.tileX] == tile:
			tiles[tile.tileY][tile.tileX] = null


# ============================================================
# 坐标/查询
# ============================================================
func cellCenter(x: int, y: int) -> Vector2:
	return Vector2((x + tileOffsetX + 0.5) * tileSize,
		(y + tileOffsetY + 0.5) * tileSize)


func tileAt(x: int, y: int) -> ATFogTile:
	if x < 0 or y < 0 or x >= fogWidth or y >= fogHeight:
		return null
	return tiles[y][x]


func isCleared(x: int, y: int) -> bool:
	return tileAt(x, y) == null


func remainingCount() -> int:
	var n := 0
	for row in tiles:
		for t in row:
			if t != null and is_instance_valid(t):
				n += 1
	return n


## 清除一格（射线命中或外部调用）。返回是否真的清掉。
## delay：淡出动画的延迟（秒），用来做"从坦克身边往外扫"的效果（逻辑上立刻算已清除）
func clearTile(x: int, y: int, animate: bool = true, delay: float = 0.0) -> bool:
	var t := tileAt(x, y)
	if t == null or not is_instance_valid(t) or t.cleared:
		return false
	tiles[y][x] = null
	t.clear(animate, delay)
	return true


## 清除以某瓦片为中心、半径 radius(瓦片) 内的黑雾（玩家脚下）
func clearArea(centerX: int, centerY: int, radius: float) -> int:
	var n := 0
	var r := maxf(radius, 0.0)
	var x0 := int(floor(centerX - r))
	var x1 := int(ceil(centerX + r))
	var y0 := int(floor(centerY - r))
	var y1 := int(ceil(centerY + r))
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var dx := float(x - centerX)
			var dy := float(y - centerY)
			if dx * dx + dy * dy <= r * r:
				if clearTile(x, y, true):
					n += 1
	return n


## 沿线段 from→to 经过的每一格都清掉（每半格取样一次，保证不漏格）。
## 这是"视野射线漏清成零星"的修正：黑雾判定框比格子大（tileCollisionScale），
## 只清射线"命中"的那一格会跳过中间格子，所以这里按走过的格子逐个清。
## delay 按离 origin 的距离递增 → 视觉上从坦克身边向外扫开。
func clearSegment(from: Vector2, to: Vector2, origin: Vector2, stagger: float = 0.0) -> int:
	var seg := to - from
	var length := seg.length()
	if length <= 0.001:
		return clearPoint(from, origin, stagger)
	var step := tileSize * 0.5
	var steps := int(ceil(length / step))
	var dir := seg / length
	var n := 0
	for i in range(steps + 1):
		n += clearPoint(from + dir * minf(float(i) * step, length), origin, stagger)
	return n


## 清除某点所在格；delay 按它离 origin 的距离算（近的先淡出）
func clearPoint(p: Vector2, origin: Vector2, stagger: float = 0.0) -> int:
	var x := int(p.x / tileSize) - tileOffsetX
	var y := int(p.y / tileSize) - tileOffsetY
	var delay := origin.distance_to(p) / float(tileSize) * stagger if stagger > 0.0 else 0.0
	return 1 if clearTile(x, y, true, delay) else 0


# ============================================================
# 视野射线（核心）
# ============================================================
## 按炮塔朝向发射扇形视野射线：半角 half_angle、距离 dist(px)。
## center 为玩家炮塔位置(px)，aim 为炮塔朝向(rad)。
## 返回本次新清除的黑雾格数。
func revealFov(center: Vector2, aim: float, halfAngle: float, dist: float) -> int:
	if fogWidth <= 0 or fogHeight <= 0:
		return 0
	if cacheEnabled and lastCenter.distance_to(center) < 0.5 \
			and absf(wrapf(aim - lastAim, -PI, PI)) < 0.01:
		return 0
	lastCenter = center
	lastAim = aim

	var cleared := 0
	# 起点所在格：射线从瓦片内部出发不会命中自身，这里直接清掉（玩家脚下可见）
	var otx := int(center.x / tileSize) - tileOffsetX
	var oty := int(center.y / tileSize) - tileOffsetY
	if clearTile(otx, oty, true):
		cleared += 1
	# 每 5° 一条射线（H5 是 10°；5° 可以避免远距离相邻射线之间漏掉一整格）
	var stepA := TAU / 72.0
	var a := aim - halfAngle
	while a <= aim + halfAngle + 0.0001:
		cleared += castRay(center, a, dist)
		a += stepA
	return cleared


## 单条射线：反复与“黑雾瓦片 / 墙”碰撞
##   命中黑雾 → 沿这段线段把经过的格子全清掉（近→远），再从命中点继续前进
##   命中墙/障碍 → 墙前这一段也清掉（贴墙的格子是看得见的），然后结束
func castRay(origin: Vector2, angle: float, dist: float) -> int:
	var space := get_world_2d().direct_space_state
	if space == null:
		return 0
	var dir := Vector2.RIGHT.rotated(angle)
	var mask := Constants.layerMask([
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
		# 命中点正好在格子边界上，往回缩半像素，免得把边界那一侧的下一格也清掉
		var segEnd := point - dir * 0.5
		if collider is ATFogTile:
			var ft := collider as ATFogTile
			# 命中黑雾：这一段走过的格子全清（判定框比格子大时只清命中格会漏）
			cleared += clearSegment(pos, segEnd, origin, CLEAR_STAGGER)
			if not ft.cleared:
				if clearTile(ft.tileX, ft.tileY, true,
						origin.distance_to(point) / float(tileSize) * CLEAR_STAGGER):
					cleared += 1
			if not exclude.has(ft.get_rid()):
				exclude.append(ft.get_rid())
			pos = point + dir * 1.0
			continue
		# 墙/障碍/其它实体：墙前这一段清掉，墙自己那一格也算"看见了"（H5：先揭格再判阻挡），
		# 然后射线结束（墙后不揭）
		cleared += clearSegment(pos, segEnd, origin, CLEAR_STAGGER)
		cleared += clearPoint(point, origin, CLEAR_STAGGER)
		break
	return cleared


## 便捷：清除某世界坐标所在格的（及周边）黑雾（供敌人开火/被击中暴露等调用）
func revealAtWorld(pos: Vector2, radiusTiles: float = 0.0) -> int:
	var tx := int(pos.x / tileSize) - tileOffsetX
	var ty := int(pos.y / tileSize) - tileOffsetY
	if radiusTiles <= 0.0:
		return 1 if clearTile(tx, ty, true) else 0
	return clearArea(tx, ty, radiusTiles)


## 重置缓存（强制下次 reveal_fov 一定发射线）
func invalidateCache() -> void:
	lastCenter = Vector2.INF
	lastAim = INF
