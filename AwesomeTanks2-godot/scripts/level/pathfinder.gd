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
var tile_size: int = Settings.TILE_SIZE

## C# 实现对象（scripts/pathfinding/EasyStarPathfinder.cs，[GlobalClass]）
var _cs: EasyStarPathfinder = null


## 初始化网格（默认全部可走，之后逐个 set_solid 标墙）
func setup(w: int, h: int, ts: int = Settings.TILE_SIZE) -> void:
	width = maxi(w, 1)
	height = maxi(h, 1)
	tile_size = ts
	if _cs == null:
		_cs = EasyStarPathfinder.new()
	_cs.Setup(width, height, tile_size)


# ============================================================
# 可通行性
# ============================================================
func set_solid(x: int, y: int, on: bool) -> void:
	if _cs != null:
		_cs.SetSolid(x, y, on)


func is_solid(x: int, y: int) -> bool:
	if _cs == null:
		return true
	return _cs.IsSolid(x, y)


func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


# ============================================================
# 坐标换算
# ============================================================
func world_to_cell(p: Vector2) -> Vector2i:
	return Vector2i(int(floor(p.x / tile_size)), int(floor(p.y / tile_size)))


func cell_center(c: Vector2i) -> Vector2:
	return Vector2((c.x + 0.5) * tile_size, (c.y + 0.5) * tile_size)


# ============================================================
# 寻路
# ============================================================
## 世界坐标 → 世界坐标路径点；空数组 = 连部分路径都没有
func find_path(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	if _cs == null:
		return PackedVector2Array()
	return _cs.FindPath(from_world, to_world)


## 两点之间是否可直线通行（Bresenham 走格，遇 solid 即 false）
func is_line_walkable(from_world: Vector2, to_world: Vector2) -> bool:
	if _cs == null:
		return false
	return _cs.IsLineWalkable(from_world, to_world)


func is_cell_line_walkable(a: Vector2i, b: Vector2i) -> bool:
	if _cs == null:
		return false
	return _cs.IsCellLineWalkable(a, b)


## 路径平滑：能直线看到更远的点就跳过中间点（string pulling）
func smooth_path(path: PackedVector2Array, from_world: Vector2) -> PackedVector2Array:
	if _cs == null:
		return path
	return _cs.SmoothPath(path, from_world)


# ============================================================
# 线程池（保留能力，游戏当前不启用：默认 0 = 单线程、不建任何线程）
# ============================================================
func set_worker_threads(n: int) -> void:
	if _cs != null:
		_cs.SetWorkerThreads(n)


func is_threaded() -> bool:
	return _cs != null and _cs.Threaded


func worker_count() -> int:
	return _cs.WorkerCount if _cs != null else 0
