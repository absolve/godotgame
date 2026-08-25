extends Node2D
## TileMap — 关卡 ASCII 解析器与瓦片构建器
## 负责把 ATLevels 的字符串数组解析为可用的瓦片网格 + 对象坐标。
##
## 注意：原项目用 Box2D + 自绘精灵；这里用 Godot 的 TileMapLayer（Godot 4.3+）
## 或 TileMap 渲染静态墙体，可破坏物与单位作为独立 Node2D。

class_name ATTileMap

var tiles: Array = []           # 二维数组：tiles[y][x] = Tile 枚举
var width: int = 0
var height: int = 0
var theme: int = 0              # ATConst.Theme

# 用于查询某格是否被占用（动态对象占据后标记）
var occupancy: Array = []

@onready var _static_layer: TileMapLayer = $StaticLayer

func _ready() -> void:
	pass

## 解析关卡数据（来自 ATLevels.LEVELS 的元素）
func parse(level_data: Array) -> void:
	var name: String = level_data[0]
	theme = ATConst.THEME_NAMES.get(level_data[1], ATConst.Theme.GRASS)
	var rows: Array = level_data.slice(2)
	height = rows.size()
	width = 0
	for r in rows:
		width = max(width, (r as String).length())
	tiles.clear()
	occupancy.clear()
	for y in range(height):
		var row_arr: Array = []
		var occ_row: Array = []
		var row_str: String = rows[y]
		for x in range(width):
			var ch: String = " " if x >= row_str.length() else row_str[x]
			row_arr.append(ATConst.CHAR_TO_TILE.get(ch, ATConst.Tile.EMPTY))
			occ_row.append(false)
		tiles.append(row_arr)
		occupancy.append(occ_row)
	_build_static_tiles()

## 把静态墙体（WALL/SECRET）写入 TileMapLayer
## TODO: 设置 TileSet 资源后，根据 theme + tile 选对应 atlas 坐标
func _build_static_tiles() -> void:
	if _static_layer == null:
		return
	_static_layer.clear()
	for y in range(height):
		for x in range(width):
			var t: int = tiles[y][x]
			if ATConst.is_static_wall(t):
				# TODO: _static_layer.set_cell(Vector2i(x, y), 0, _atlas_coord(t))
				pass

# ============================================================
# 坐标换算（瓦片 <-> 像素）
# ============================================================
func tile_to_px(coord: int) -> float:
	return (coord + 0.5) * Settings.TILE_SIZE

func px_to_tile(px: float) -> int:
	return int(px / Settings.TILE_SIZE)

func cell_center(x: int, y: int) -> Vector2:
	return Vector2(tile_to_px(x), tile_to_px(y))

# ============================================================
# 占位查询（动态对象占据后标记）
# ============================================================
func is_tile_free(x: int, y: int) -> bool:
	if x < 0 or x >= width or y < 0 or y >= height:
		return false
	if ATConst.is_static_wall(tiles[y][x]):
		return false
	return not occupancy[y][x]

func occupy_tile(x: int, y: int) -> void:
	if x >= 0 and x < width and y >= 0 and y < height:
		occupancy[y][x] = true

func free_tile(x: int, y: int) -> void:
	if x >= 0 and x < width and y >= 0 and y < height:
		occupancy[y][x] = false

## 遍历所有非空瓦片，按类型回调（用于实例化对象）
func for_each_object(callback: Callable) -> void:
	for y in range(height):
		for x in range(width):
			var t: int = tiles[y][x]
			if t != ATConst.Tile.EMPTY and not ATConst.is_static_wall(t):
				callback.call(t, x, y)
