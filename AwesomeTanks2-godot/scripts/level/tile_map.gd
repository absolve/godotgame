extends Node2D
## TileMap — 关卡 ASCII 解析器与瓦片构建器
## 负责把 ATLevels 的字符串数组解析为可用的瓦片网格 + 对象坐标。

class_name ATTileMap

var tiles: Array = []           # 二维数组：tiles[y][x] = Tile 枚举
var width: int = 0
var height: int = 0
var theme: int = 0              # Constants.gameTheme

# 用于查询某格是否被占用（动态对象占据后标记）
var occupancy: Array = []

@onready var _static_layer: Node2D = $StaticLayer

# 主题地板贴图（平铺背景）
const TEX_FLOOR: Dictionary = {
	Constants.gameTheme.GRASS: preload("res://sprites/game/grass.png.tres"),
	Constants.gameTheme.SNOW: preload("res://sprites/game/snow.png.tres"),
	Constants.gameTheme.DESERT: preload("res://sprites/game/desert.png.tres"),
}

# 墙体贴图（随机选）
const TEX_WALLS: Array = [
	preload("res://sprites/game/wall_0.png.tres"),
	preload("res://sprites/game/wall_1.png.tres"),
	preload("res://sprites/game/wall_2.png.tres"),
]
const TEX_SECRET: Texture2D = preload("res://sprites/game/secret.png.tres")


func _ready() -> void:
	pass


## 解析关卡数据（来自 ATLevels.LEVELS 的元素）
func parse(level_data: Array) -> void:
	var name: String = level_data[0]
	theme = Constants.THEME_NAMES.get(level_data[1], Constants.gameTheme.GRASS)
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
			row_arr.append(Constants.CHAR_TO_TILE.get(ch, Constants.Tile.EMPTY))
			occ_row.append(false)
		tiles.append(row_arr)
		occupancy.append(occ_row)
	_build_static_tiles()


## 构建静态瓦片：主题地板 + 墙体 + 秘密墙（每格一个 StaticBody2D + Sprite2D）
func _build_static_tiles() -> void:
	if _static_layer == null:
		return
	# 清空旧节点（保留 parse 前可能已存在的子节点）
	for c in _static_layer.get_children():
		c.queue_free()

	var ts := Settings.TILE_SIZE

	# 1. 主题地板背景（TextureRect 平铺整个关卡）
	var floor := TextureRect.new()
	floor.name = "Floor"
	floor.position = Vector2.ZERO
	floor.size = Vector2(width * ts, height * ts)
	floor.texture = TEX_FLOOR.get(theme, TEX_FLOOR[Constants.gameTheme.GRASS])
	floor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	floor.texture_repeat = TextureRect.TEXTURE_REPEAT_ENABLED
	floor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_static_layer.add_child(floor)

	# 2. 逐格构建静态墙 + 秘密墙（StaticBody2D + Sprite2D + RectangleShape2D）
	for y in range(height):
		for x in range(width):
			var t: int = tiles[y][x]
			if not Constants.is_static_wall(t):
				continue
			var pos := cell_center(x, y)
			var body := StaticBody2D.new()
			body.position = pos
			body.collision_layer = 1 << (Constants.Layer.WALL - 1)
			body.collision_mask = 0
			var shape := RectangleShape2D.new()
			shape.size = Vector2(ts, ts)
			var cs := CollisionShape2D.new()
			cs.shape = shape
			body.add_child(cs)
			var sprite := Sprite2D.new()
			sprite.centered = true
			if t == Constants.Tile.SECRET:
				sprite.texture = TEX_SECRET
			else:
				sprite.texture = TEX_WALLS[randi() % TEX_WALLS.size()]
			body.add_child(sprite)
			_static_layer.add_child(body)


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
	if Constants.is_static_wall(tiles[y][x]):
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
			if t != Constants.Tile.EMPTY and not Constants.is_static_wall(t):
				callback.call(t, x, y)
