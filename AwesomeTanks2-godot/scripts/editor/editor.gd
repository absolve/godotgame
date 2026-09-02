extends Control
## LevelEditor — 关卡编辑器
## 与 H5 项目无关，全新设计：调色板选画笔，画布点击/拖动绘制，保存为 JSON。

const FONT: Font = preload("res://fonts/gunplay.ttf")

# 调色板配置：[tile 枚举, 显示名, 代表贴图]
const PALETTE: Array = [
	[Constants.Tile.EMPTY, "Empty (Eraser)", null],
	[Constants.Tile.WALL, "Wall", preload("res://sprites/game/wall_0.png.tres")],
	[Constants.Tile.SECRET, "Secret", preload("res://sprites/game/secret.png.tres")],
	[Constants.Tile.BRICKS_1, "Bricks 1", preload("res://sprites/game/bricks_0.png.tres")],
	[Constants.Tile.BRICKS_2, "Bricks 2", preload("res://sprites/game/bricks_1.png.tres")],
	[Constants.Tile.WOOD, "Wood", preload("res://sprites/game/wood.png.tres")],
	[Constants.Tile.GATE, "Gate", preload("res://sprites/game/gate.png.tres")],
	[Constants.Tile.BARREL, "Barrel", preload("res://sprites/game/barrel.png.tres")],
	[Constants.Tile.CRATE, "Crate", preload("res://sprites/game/crate.png.tres")],
	[Constants.Tile.PLAYER, "Player", preload("res://sprites/game/player/body_0.png.tres")],
]

@onready var _canvas: Control = $Design/Main/PaletteCanvas/Scroll/Canvas
@onready var _palette_grid: GridContainer = $Design/Main/Side/PaletteScroll/PaletteGrid
@onready var _name_edit: LineEdit = $Design/TopBar/NameEdit
@onready var _theme_option: OptionButton = $Design/TopBar/ThemeOption
@onready var _width_spin: SpinBox = $Design/TopBar/WidthSpin
@onready var _height_spin: SpinBox = $Design/TopBar/HeightSpin
@onready var _file_edit: LineEdit = $Design/TopBar/FileEdit
@onready var _load_option: OptionButton = $Design/TopBar/LoadOption
@onready var _status: Label = $Design/StatusBar
@onready var _brush_label: Label = $Design/Main/Side/BrushLabel

var _brush_buttons: Dictionary = {}    # tile -> TextureButton
var _current_level_name: String = "Custom Level"
var _current_theme: String = "grass"


func _ready() -> void:
	_status.add_theme_font_override("font", FONT)
	_brush_label.add_theme_font_override("font", FONT)
	_build_palette()
	_populate_load_list()
	_canvas.tile_painted.connect(_on_tile_painted)
	_canvas.new_level(int(_width_spin.value), int(_height_spin.value))
	_select_brush(Constants.Tile.WALL)
	_refresh_status()


# ---------- 调色板 ----------
func _build_palette() -> void:
	for c in _palette_grid.get_children():
		c.queue_free()
	_brush_buttons.clear()
	for entry in PALETTE:
		var tile: int = entry[0]
		var label: String = entry[1]
		var tex: Texture2D = entry[2]
		var btn := TextureButton.new()
		btn.texture_normal = tex if tex != null else _make_empty_icon()
		btn.custom_minimum_size = Vector2(48, 48)
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.ignore_texture_size = true
		btn.tooltip_text = label
		btn.pressed.connect(_select_brush.bind(tile))
		_palette_grid.add_child(btn)
		_brush_buttons[tile] = btn
		# 在按钮下方加标签
		var lbl := Label.new()
		lbl.text = label
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 10)
		_palette_grid.add_child(lbl)


func _make_empty_icon() -> Texture2D:
	# 用 PlaceholderTexture2D 表示橡皮
	var tex := PlaceholderTexture2D.new()
	tex.size = Vector2i(36, 36)
	return tex


func _select_brush(tile: int) -> void:
	_canvas.set_brush(tile)
	_brush_label.text = "Brush: %s" % _tile_name(tile)
	_refresh_status()


static func _tile_name(tile: int) -> String:
	for entry in PALETTE:
		if entry[0] == tile:
			return entry[1]
	return "Unknown"


# ---------- 工具栏 ----------
func _on_new_pressed() -> void:
	Audio.play_button_down()
	_canvas.new_level(int(_width_spin.value), int(_height_spin.value))
	_refresh_status()


func _on_save_pressed() -> void:
	Audio.play_button_down()
	var file_name := _file_edit.text.strip_edges()
	if file_name.is_empty():
		_status.text = "Status: 请输入文件名"
		return
	var name := _name_edit.text.strip_edges()
	if name.is_empty():
		name = file_name
	_current_level_name = name
	_current_theme = _theme_option.get_item_text(_theme_option.selected)
	var rows := _canvas.get_rows()
	var ok := ATLevels.save_custom_json(file_name, name, _current_theme, rows)
	if ok:
		_status.text = "Status: 已保存 %s.json" % file_name
		_populate_load_list()
		_file_edit.text = file_name
	else:
		_status.text = "Status: 保存失败"


func _on_load_pressed() -> void:
	Audio.play_button_down()
	var idx := _load_option.selected
	if idx < 0:
		_status.text = "Status: 请选择关卡"
		return
	var file_name := _load_option.get_item_text(idx)
	var data := ATLevels.load_custom_json(file_name)
	_canvas.load_from_data(data)
	_name_edit.text = data[0]
	_current_level_name = data[0]
	_current_theme = data[1]
	# 同步主题下拉框
	for i in _theme_option.item_count:
		if _theme_option.get_item_text(i) == _current_theme:
			_theme_option.selected = i
			break
	_file_edit.text = file_name
	_refresh_status()


func _on_back_pressed() -> void:
	Audio.play_button_down()
	Game.change_scene(Settings.SCENE_TITLE)


func _on_width_value_changed(_v: float) -> void:
	_refresh_status()


func _on_height_value_changed(_v: float) -> void:
	_refresh_status()


# ---------- 画布回调 ----------
func _on_tile_painted(x: int, y: int, tile: int) -> void:
	_refresh_status(x, y, tile)


# ---------- 状态 ----------
func _refresh_status(px: int = -1, py: int = -1, pt: int = -1) -> void:
	var s := "Status: %dx%d | Brush: %s" % [_canvas.width, _canvas.height, _tile_name(_canvas.brush)]
	if px >= 0:
		s += " | Last paint: (%d, %d) = %s" % [px, py, _tile_name(pt)]
	_status.text = s


func _populate_load_list() -> void:
	_load_option.clear()
	var names := ATLevels.list_custom_levels()
	for n in names:
		_load_option.add_item(n)
	if names.is_empty():
		_load_option.add_item("(none)")
		_load_option.disabled = true
	else:
		_load_option.disabled = false
