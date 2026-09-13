class_name ATPathfinder
extends RefCounted
## ATPathfinder —— 关卡网格寻路（基于 Godot 内置 AStarGrid2D）
##
## 设计思路（不照搬 H5 的 EasyStar，尽量用引擎自带能力）：
##   - Godot 4 内置 `AStarGrid2D` 就是"2D 网格 A*"，这里只做三件事：
##       1) 用关卡瓦片尺寸初始化网格（region / cell_size / 对角线规则）；
##       2) 把不可通行格标记为 solid（静态墙 + 未被摧毁的可破坏障碍）；
##       3) 世界坐标 ↔ 格子坐标换算，返回世界坐标路径点。
##   - 另加一个"格子直线可走"判定（Bresenham 走格），供状态机做快路径与路径平滑。
##
## 使用（由 Level 持有）：
##   var pf := ATPathfinder.new()
##   pf.setup(map_width, map_height)
##   pf.set_solid(x, y, true)                  # 墙/障碍
##   var pts := pf.find_path(from_world, to_world)   # 空数组 = 不可达
##   if pf.is_line_walkable(from_world, to_world): ...
##
## 说明：单位（玩家/敌人）不标记 solid —— 避免互相堵路与抖动；
## 需要"避让同伴"时，由使用方自行调用 set_solid 临时标记。

var width: int = 0
var height: int = 0
var tile_size: int = Settings.TILE_SIZE

var _astar := AStarGrid2D.new()
var _solid: Array = []          # _solid[y][x] = true 不可通行


## 初始化网格（先设置 region/cell_size，再 update()，之后才能 set_point_solid）
func setup(w: int, h: int, ts: int = Settings.TILE_SIZE) -> void:
	width = maxi(w, 1)
	height = maxi(h, 1)
	tile_size = ts
	_astar.region = Rect2i(0, 0, width, height)
	_astar.cell_size = Vector2(tile_size, tile_size)
	# 禁止贴角斜穿（与 H5 EasyStar disableCornerCutting 同义）
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.update()
	_solid.clear()
	for y in range(height):
		var row: Array = []
		for x in range(width):
			row.append(false)
		_solid.append(row)


# ============================================================
# 可通行性
# ============================================================
func set_solid(x: int, y: int, on: bool) -> void:
	if not in_bounds(x, y):
		return
	if _solid[y][x] == on:
		return
	_solid[y][x] = on
	_astar.set_point_solid(Vector2i(x, y), on)


func is_solid(x: int, y: int) -> bool:
	if not in_bounds(x, y):
		return true
	return bool(_solid[y][x])


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
## 世界坐标 → 世界坐标路径点（含终点格中心）。
## 起点越界/起点与终点同格时返回空数组。
## 目标不可达（被墙隔开，例如玩家在还没炸开的砖墙房间里）时返回"部分路径"：
## 终点会落在最接近目标的那个可达格，敌人据此一路推进到墙边而不是原地发呆。
func find_path(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	var a := world_to_cell(from_world)
	var b := world_to_cell(to_world)
	if not in_bounds(a.x, a.y) or not in_bounds(b.x, b.y):
		return out
	if is_solid(a.x, a.y):
		# 起点格被占（例如单位正压在已摧毁的固定单位格上）：从最近的可走格出发
		a = _nearest_free(a)
		if a.x < 0:
			return out
	if a == b:
		return out
	if is_solid(b.x, b.y):
		# 目标格本身被占（例如站在障碍格里）：退而求其次找它旁边的可走格
		b = _nearest_free(b)
		if b.x < 0:
			return out
	var ids := _astar.get_id_path(a, b, true)
	for id in ids:
		out.append(cell_center(id))
	# 去掉"起点所在格"：避免先往回走一小步
	if out.size() > 1 and from_world.distance_to(out[0]) < float(tile_size) * 0.6:
		out.remove_at(0)
	return out


func _nearest_free(c: Vector2i) -> Vector2i:
	for radius in range(1, 4):
		for dy in range(-radius, radius + 1):
			for dx in range(-radius, radius + 1):
				var n := Vector2i(c.x + dx, c.y + dy)
				if in_bounds(n.x, n.y) and not is_solid(n.x, n.y):
					return n
	return Vector2i(-1, -1)


## 两点之间是否可直线通行（Bresenham 走格，遇到 solid 即 false）
## 用于"直冲"快路径判断与路径平滑。
func is_line_walkable(from_world: Vector2, to_world: Vector2) -> bool:
	var a := world_to_cell(from_world)
	var b := world_to_cell(to_world)
	return is_cell_line_walkable(a, b)


func is_cell_line_walkable(a: Vector2i, b: Vector2i) -> bool:
	var x := a.x
	var y := a.y
	var dx := absi(b.x - a.x)
	var dy := -absi(b.y - a.y)
	var sx := 1 if a.x < b.x else -1
	var sy := 1 if a.y < b.y else -1
	var err := dx + dy
	while true:
		if is_solid(x, y):
			return false
		if x == b.x and y == b.y:
			return true
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x += sx
		if e2 <= dx:
			err += dx
			y += sy
	return false   # 兜底：循环理论上一定从内部返回（GDScript 需要显式收尾）


## 路径平滑：从起点开始，能直线看到更远的点就跳过中间点（string pulling 简化版）
func smooth_path(path: PackedVector2Array, from_world: Vector2) -> PackedVector2Array:
	if path.size() <= 1:
		return path
	var out := PackedVector2Array()
	var anchor := from_world
	var i := 0
	while i < path.size():
		var far := i
		for j in range(path.size() - 1, i, -1):
			if is_line_walkable(anchor, path[j]):
				far = j
				break
		out.append(path[far])
		anchor = path[far]
		i = far + 1
	return out
