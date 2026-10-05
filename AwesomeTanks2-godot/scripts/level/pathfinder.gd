class_name ATPathfinder
extends RefCounted
## ATPathfinder —— 关卡网格寻路（GDScript 门面；实际实现已换成 C#）
##
## 实现：scripts/pathfinding/EasyStarPathfinder.cs（内部是 EasyStarJS 的 C# 移植，
## scenes 侧不再使用 Godot 的 AStarGrid2D）。
## 本类**保持与旧版完全相同的 API**，所以 Level / ATEnemy 的调用点一行都没改：
##   var pf := ATPathfinder.new()
##   pf.setup(map_width, map_height)
##   pf.set_solid(x, y, true)                          # 墙/障碍/固定单位占格
##   var pts := pf.find_path(from_world, to_world)      # 空数组 = 不可达
##   if pf.is_line_walkable(from_world, to_world): ...  # 直冲快路径
##   var smooth := pf.smooth_path(pts, from_world)      # 拉直路径
##
## 与旧版行为一致的点：
##   - 格子 0 = 可走、1 = 不可走；单位不标 solid（避免互相堵路）；
##   - 8 向移动、禁止贴角斜穿（两个正交邻居都要可走）；
##   - 起点/终点格被占 → 退到最近可走格；目标不可达 → 返回"部分路径"推进到墙边；
##   - 路径返回世界坐标格心，并去掉"起点所在格"。
## 差异：内部换成 EasyStar + 标准 Octile 启发式（路径与旧 AStarGrid2D 一样是最优的），
##       并且**默认单线程**；线程池能力（set_worker_threads）保留，游戏当前不启用。

var width: int = 0
var height: int = 0
var tileSize: int = Settings.TILE_SIZE

## C# 实现对象（scripts/pathfinding/EasyStarPathfinder.cs，[GlobalClass]）
var cs: EasyStarPathfinder = null


## 初始化网格（默认全部可走，之后逐个 set_solid 标墙）
func setup(w: int, h: int, ts: int = Settings.TILE_SIZE) -> void:
	width = maxi(w, 1)
	height = maxi(h, 1)
	tileSize = ts
	if cs == null:
		cs = EasyStarPathfinder.new()
	cs.Setup(width, height, tileSize)


# ============================================================
# 可通行性
# ============================================================
func setSolid(x: int, y: int, on: bool) -> void:
	if cs != null:
		cs.SetSolid(x, y, on)


func isSolid(x: int, y: int) -> bool:
	if cs == null:
		return true
	return cs.IsSolid(x, y)


func inBounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


# ============================================================
# 坐标换算
# ============================================================
func worldToCell(p: Vector2) -> Vector2i:
	return Vector2i(int(floor(p.x / tileSize)), int(floor(p.y / tileSize)))


func cellCenter(c: Vector2i) -> Vector2:
	return Vector2((c.x + 0.5) * tileSize, (c.y + 0.5) * tileSize)


# ============================================================
# 寻路
# ============================================================
## 世界坐标 → 世界坐标路径点；空数组 = 连部分路径都没有
func findPath(fromWorld: Vector2, toWorld: Vector2) -> PackedVector2Array:
	if cs == null:
		return PackedVector2Array()
	return cs.FindPath(fromWorld, toWorld)


## 两点之间是否可直线通行（Bresenham 走格，遇 solid 即 false）
func isLineWalkable(fromWorld: Vector2, toWorld: Vector2) -> bool:
	if cs == null:
		return false
	return cs.IsLineWalkable(fromWorld, toWorld)


func isCellLineWalkable(a: Vector2i, b: Vector2i) -> bool:
	if cs == null:
		return false
	return cs.IsCellLineWalkable(a, b)


## 路径平滑：能直线看到更远的点就跳过中间点（string pulling）
func smoothPath(path: PackedVector2Array, fromWorld: Vector2) -> PackedVector2Array:
	if cs == null:
		return path
	return cs.SmoothPath(path, fromWorld)


# ============================================================
# 线程池（保留能力，游戏当前不启用：默认 0 = 单线程、不建任何线程）
# ============================================================
func setWorkerThreads(n: int) -> void:
	if cs != null:
		cs.SetWorkerThreads(n)


func isThreaded() -> bool:
	return cs != null and cs.Threaded


func workerCount() -> int:
	return cs.WorkerCount if cs != null else 0
