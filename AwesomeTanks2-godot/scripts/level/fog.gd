class_name ATFog
extends Node2D
## Fog —— 战争迷雾（逐格黑雾瓦片版）
##
## 结构：
##   · 按地图尺寸逐格创建黑雾瓦片（Area2D + 纯黑块贴图，见 scenes/level/fog_tile.tscn），铺满整张地图；
##   · 每格瓦片自带"放大 + 淡出 + 随机旋转"的消失动画（见 ATFogTile.clear）。
##
## 视野揭示由玩家坦克驱动（ATPlayer.updateFogReveal），本类用 Godot 原生的一次形状查询：
##   PhysicsDirectSpaceState2D.intersect_shape() —— 拿一个细长矩形盖住整条射线，
##   **一次**就返回沿途所有重叠的碰撞体（黑雾瓦片 + 墙壁/障碍物，不保证顺序）：
##     · 先从结果里取"最近的墙/障碍"作阻挡点（格子中心沿射线的投影最小者）；
##     · 再清掉阻挡点之前（含墙自己那一格）的黑雾瓦片，墙后的一律不管
##                       —— 所以墙后面的黑雾不会被清掉。
##   · 被清掉的瓦片永久保持清除（看过的区域不再变黑）。
##
## 说明：这里没用 ShapeCast2D —— 它是"运动扫描"，撞到第一个障碍就停，
## 只会返回停下点附近碰到的对象，拿不到"一条线上全部命中"。
##
## 场景：scenes/level/fog.tscn（本脚本挂在根节点上，由 Level 实例化）。

const TILE_SCENE: PackedScene = preload("res://scenes/level/fog_tile.tscn")

## 细长矩形的厚度（px）：查询用的"射线"宽度
const RAY_THICKNESS: float = 2.0
## 一次查询最多返回多少个碰撞体
const MAX_HITS: int = 32

@export var tileSize: int = Settings.TILE_SIZE
## 圆形揭示半径（格）—— 只有"制导火箭期间视野跟着导弹"用到
@export var clearRadiusTiles: float = 1.35
## 黑雾瓦片判定区相对一格的大小（1.0 = 正好一格）
@export var tileCollisionScale: float = 1.0

var fogWidth: int = 0
var fogHeight: int = 0
var tiles: Array = []                 # tiles[y][x] = ATFogTile 或 null（已清除）
var tileOffsetX: int = 0
var tileOffsetY: int = 0

var rayShape: RectangleShape2D = null


func _ready() -> void:
	rayShape = RectangleShape2D.new()


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
	t.z_index = 100
	t.disappeared.connect(onTileDisappeared)
	add_child(t)
	tiles[y][x] = t


func onTileDisappeared(tile: ATFogTile) -> void:
	if tile.tileY >= 0 and tile.tileY < fogHeight \
			and tile.tileX >= 0 and tile.tileX < fogWidth:
		if tiles[tile.tileY][tile.tileX] == tile:
			tiles[tile.tileY][tile.tileX] = null


# ============================================================
# 坐标 / 查询
# ============================================================
func cellCenter(x: int, y: int) -> Vector2:
	return Vector2((float(x + tileOffsetX) + 0.5) * float(tileSize),
		(float(y + tileOffsetY) + 0.5) * float(tileSize))


func tileAt(x: int, y: int) -> ATFogTile:
	if x < 0 or y < 0 or x >= fogWidth or y >= fogHeight:
		return null
	return tiles[y][x]


func isCleared(x: int, y: int) -> bool:
	return tileAt(x, y) == null


## 清除一格（播放消失动画）。返回是否真的清掉。
func clearTile(x: int, y: int) -> bool:
	var t := tileAt(x, y)
	if t == null or not is_instance_valid(t) or t.cleared:
		return false
	tiles[y][x] = null
	t.clear()
	return true


## 清除某世界坐标所在的格子
func clearPoint(p: Vector2) -> int:
	var x := int(p.x / float(tileSize)) - tileOffsetX
	var y := int(p.y / float(tileSize)) - tileOffsetY
	return 1 if clearTile(x, y) else 0


## 清除以某格为中心、半径 radius(格) 内的黑雾（制导火箭跟随时用）
func clearArea(centerX: int, centerY: int, radius: float) -> int:
	var n := 0
	var r := maxf(radius, 0.0)
	var x0 := int(floor(float(centerX) - r))
	var x1 := int(ceil(float(centerX) + r))
	var y0 := int(floor(float(centerY) - r))
	var y1 := int(ceil(float(centerY) + r))
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var dx := float(x - centerX)
			var dy := float(y - centerY)
			if dx * dx + dy * dy <= r * r:
				if clearTile(x, y):
					n += 1
	return n


# ============================================================
# 视野射线（核心，全程用 Godot 原生查询）
# ============================================================
## 一条视野射线：从 origin 沿 angle 前进 dist。**只做一次** intersect_shape 查询：
##   细长矩形盖住整条射线，一次返回沿途所有碰撞体（黑雾瓦片 + 墙壁/障碍物）。
##   先从结果里取"最近的墙/障碍"作阻挡点（其格子中心沿 dir 的投影），再清掉
##   阻挡点之前（含墙自己那一格）的黑雾瓦片，墙后的一律不管。
##   墙的阻挡点直接取自这次 shape 结果，不再另开 intersect_ray —— 后者一旦没命中，
##   stop 会回退成整条射线长，墙就"透明"了（墙后黑雾被误清）。
func castRay(origin: Vector2, angle: float, dist: float) -> int:
	if rayShape == null or dist <= 0.0:
		return 0
	var space := get_world_2d().direct_space_state
	if space == null:
		return 0
	var dir := Vector2.RIGHT.rotated(angle)

	# 细长矩形盖住整条射线：一次拿到沿途所有黑雾瓦片 + 墙壁/障碍物
	rayShape.size = Vector2(dist, RAY_THICKNESS)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = rayShape
	query.transform = Transform2D(angle, origin + dir * (dist * 0.5))
	query.collision_mask = Constants.layerMask([
		Constants.Layer.WALL, Constants.Layer.OBSTACLE, Constants.Layer.FOG,
	])
	query.collide_with_areas = true     # 黑雾是 Area2D
	query.collide_with_bodies = true    # 墙壁/可破坏障碍物是 StaticBody2D

	var hits := space.intersect_shape(query, MAX_HITS)

	# 先从结果里找最近的墙/障碍（StaticBody2D）作阻挡点：取其格子中心沿 dir 的投影
	# ATObstacle 也是 StaticBody2D，所以可破坏障碍同样会挡视野（被毁后自然不再挡）
	var wallStop := INF
	var wallPos := Vector2.ZERO
	for hit in hits:
		var c = hit.get("collider")
		if c is StaticBody2D:
			var p := (c as StaticBody2D).global_position
			var proj := (p - origin).dot(dir)
			if proj < wallStop:
				wallStop = proj
				wallPos = p
	var hasWall := wallStop < INF

	var cleared := clearPoint(origin)   # 自己脚下那一格
	for hit in hits:
		var collider = hit.get("collider")
		if not (collider is ATFogTile):
			continue
		var ft := collider as ATFogTile
		var proj := (cellCenter(ft.tileX, ft.tileY) - origin).dot(dir)
		if hasWall and proj > wallStop + 1.0:
			continue                    # 在墙/障碍后面 → 不揭
		if clearTile(ft.tileX, ft.tileY):
			cleared += 1
	# 墙/障碍自己那一格算"看见了"（shape 没返回该格雾瓦片时的兜底；已清则 no-op）
	if hasWall:
		cleared += clearPoint(wallPos)
	return cleared
