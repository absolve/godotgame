extends Control
## LevelCanvas — 关卡编辑器画布
## 维护 2D 瓦片数组，用 _draw 绘制网格 + 每格贴图，鼠标点击/拖动绘制。

signal tilePainted(x: int, y: int, tile: int)

const TILE_SIZE: int = 36          # 编辑器中每格像素（小于游戏内 52 便于显示）
const GRID_COLOR: Color = Color(1, 1, 1, 0.15)
const CURSOR_COLOR: Color = Color(1, 0.71, 0, 0.6)

# 可绘制瓦片 -> 贴图列表（用于随机/单选）
const TILE_TEXTURES: Dictionary = {
	Constants.Tile.WALL: [
		preload("res://sprites/game/wall_0.png.tres"),
		preload("res://sprites/game/wall_1.png.tres"),
		preload("res://sprites/game/wall_2.png.tres"),
	],
	Constants.Tile.SECRET: [preload("res://sprites/game/secret.png.tres")],
	Constants.Tile.BRICKS_1: [
		preload("res://sprites/game/bricks_0.png.tres"),
		preload("res://sprites/game/bricks_1.png.tres"),
	],
	Constants.Tile.BRICKS_2: [
		preload("res://sprites/game/bricks_0.png.tres"),
		preload("res://sprites/game/bricks_1.png.tres"),
	],
	Constants.Tile.WOOD: [preload("res://sprites/game/wood.png.tres")],
	Constants.Tile.GATE: [preload("res://sprites/game/gate.png.tres")],
	Constants.Tile.BARREL: [preload("res://sprites/game/barrel.png.tres")],
	Constants.Tile.CRATE: [preload("res://sprites/game/crate.png.tres")],
	Constants.Tile.PLAYER: [preload("res://sprites/game/player/body_0.png.tres")],
}

# 瓦片 -> ASCII 字符（反向映射，用 constants.CHAR_TO_TILE 反查）
var charForTile: Dictionary = {}

var width: int = 15
var height: int = 12
var tiles: Array = []               # tiles[y][x] = Tile 枚举
var brush: int = Constants.Tile.WALL
var painting: bool = false
var hoverCell: Vector2i = Vector2i(-1, -1)


func _ready() -> void:
	# 构建反向映射 Tile -> 字符
	for ch in Constants.CHAR_TO_TILE:
		charForTile[Constants.CHAR_TO_TILE[ch]] = ch
	# 初始化空网格
	newGrid(width, height)
	# 接收鼠标
	mouse_filter = Control.MOUSE_FILTER_STOP


func newGrid(w: int, h: int) -> void:
	width = w
	height = h
	tiles.clear()
	for y in range(height):
		var row: Array = []
		for x in range(width):
			row.append(Constants.Tile.EMPTY)
		tiles.append(row)
	updateSize()
	queue_redraw()


func updateSize() -> void:
	custom_minimum_size = Vector2(width * TILE_SIZE, height * TILE_SIZE)
	size = custom_minimum_size


## 新建空白关卡
func newLevel(w: int, h: int) -> void:
	newGrid(w, h)


## 从 ATLevels 格式数据加载（[name, theme, ...rows]）
func loadFromData(levelData: Array) -> void:
	var rows: Array = levelData.slice(2)
	height = rows.size()
	width = 0
	for r in rows:
		width = max(width, (r as String).length())
	tiles.clear()
	for y in range(height):
		var row: Array = []
		var s: String = rows[y]
		for x in range(width):
			var ch := " " if x >= s.length() else s[x]
			row.append(Constants.CHAR_TO_TILE.get(ch, Constants.Tile.EMPTY))
		tiles.append(row)
	updateSize()
	queue_redraw()


## 导出为 ASCII 行数组（与 ATLevels.LEVELS 元素 slice(2) 一致）
func getRows() -> Array[String]:
	var out: Array[String] = []
	for y in range(height):
		var s := ""
		for x in range(width):
			var t: int = tiles[y][x]
			s += charForTile.get(t, " ")
		out.append(s)
	return out


func setBrush(tile: int) -> void:
	brush = tile


func paintAt(pos: Vector2) -> void:
	var c := posToCell(pos)
	if c.x < 0 or c.x >= width or c.y < 0 or c.y >= height:
		return
	if tiles[c.y][c.x] == brush:
		return
	tiles[c.y][c.x] = brush
	tilePainted.emit(c.x, c.y, brush)
	queue_redraw()


func posToCell(pos: Vector2) -> Vector2i:
	return Vector2i(int(pos.x / TILE_SIZE), int(pos.y / TILE_SIZE))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				painting = true
				paintAt(mb.position)
			else:
				painting = false
			accept_event()
	elif event is InputEventMouseMotion and painting:
		paintAt(event.position)
		accept_event()
	elif event is InputEventMouseMotion:
		var c := posToCell(event.position)
		if c != hoverCell:
			hoverCell = c
			queue_redraw()


func _draw() -> void:
	# 1. 每格贴图
	for y in range(height):
		for x in range(width):
			var t: int = tiles[y][x]
			var pos := Vector2(x * TILE_SIZE, y * TILE_SIZE)
			var rect := Rect2(pos, Vector2(TILE_SIZE, TILE_SIZE))
			if t == Constants.Tile.EMPTY:
				# 空格画淡色背景以便辨识
				draw_rect(rect, Color(0, 0, 0, 0.25), true)
				continue
			var texList: Array = TILE_TEXTURES.get(t, [])
			if texList.is_empty():
				continue
			var tex: Texture2D = texList[randi() % texList.size()]
			draw_texture_rect(tex, rect, false)
	# 2. 网格线
	var col := GRID_COLOR
	for x in range(width + 1):
		var x0 := x * TILE_SIZE
		draw_line(Vector2(x0, 0), Vector2(x0, height * TILE_SIZE), col)
	for y in range(height + 1):
		var y0 := y * TILE_SIZE
		draw_line(Vector2(0, y0), Vector2(width * TILE_SIZE, y0), col)
	# 3. 当前 hover 格高亮
	if hoverCell.x >= 0 and hoverCell.x < width and hoverCell.y >= 0 and hoverCell.y < height:
		var pos := Vector2(hoverCell.x * TILE_SIZE, hoverCell.y * TILE_SIZE)
		draw_rect(Rect2(pos, Vector2(TILE_SIZE, TILE_SIZE)), CURSOR_COLOR, false, 2.0)
