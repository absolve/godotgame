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

@onready var canvas: Control = $Design/Main/PaletteCanvas/Scroll/Canvas
@onready var paletteGrid: GridContainer = $Design/Main/Side/PaletteScroll/PaletteGrid
@onready var nameEdit: LineEdit = $Design/TopBar/NameEdit
@onready var themeOption: OptionButton = $Design/TopBar/ThemeOption
@onready var widthSpin: SpinBox = $Design/TopBar/WidthSpin
@onready var heightSpin: SpinBox = $Design/TopBar/HeightSpin
@onready var fileEdit: LineEdit = $Design/TopBar/FileEdit
@onready var loadOption: OptionButton = $Design/TopBar/LoadOption
@onready var status: Label = $Design/StatusBar
@onready var brushLabel: Label = $Design/Main/Side/BrushLabel

var brushButtons: Dictionary = {}    # tile -> TextureButton
var currentLevelName: String = "Custom Level"
var currentTheme: String = "grass"


func _ready() -> void:
	status.add_theme_font_override("font", FONT)
	brushLabel.add_theme_font_override("font", FONT)
	buildPalette()
	populateLoadList()
	canvas.tilePainted.connect(onTilePainted)
	canvas.newLevel(int(widthSpin.value), int(heightSpin.value))
	selectBrush(Constants.Tile.WALL)
	refreshStatus()


# ---------- 调色板 ----------
func buildPalette() -> void:
	for c in paletteGrid.get_children():
		c.queue_free()
	brushButtons.clear()
	for entry in PALETTE:
		var tile: int = entry[0]
		var label: String = entry[1]
		var tex: Texture2D = entry[2]
		var btn := TextureButton.new()
		btn.texture_normal = tex if tex != null else makeEmptyIcon()
		btn.custom_minimum_size = Vector2(48, 48)
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.ignore_texture_size = true
		btn.tooltip_text = label
		btn.pressed.connect(selectBrush.bind(tile))
		paletteGrid.add_child(btn)
		brushButtons[tile] = btn
		# 在按钮下方加标签
		var lbl := Label.new()
		lbl.text = label
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 10)
		paletteGrid.add_child(lbl)


func makeEmptyIcon() -> Texture2D:
	# 用 PlaceholderTexture2D 表示橡皮
	var tex := PlaceholderTexture2D.new()
	tex.size = Vector2i(36, 36)
	return tex


func selectBrush(tile: int) -> void:
	canvas.setBrush(tile)
	brushLabel.text = "Brush: %s" % tileName(tile)
	refreshStatus()


static func tileName(tile: int) -> String:
	for entry in PALETTE:
		if entry[0] == tile:
			return entry[1]
	return "Unknown"


# ---------- 工具栏 ----------
func onNewPressed() -> void:
	Audio.playButtonDown()
	canvas.newLevel(int(widthSpin.value), int(heightSpin.value))
	refreshStatus()


func onSavePressed() -> void:
	Audio.playButtonDown()
	var fileName := fileEdit.text.strip_edges()
	if fileName.is_empty():
		status.text = "Status: 请输入文件名"
		return
	var name = nameEdit.text.strip_edges()
	if name.is_empty():
		name = fileName
	currentLevelName = name
	currentTheme = themeOption.get_item_text(themeOption.selected)
	var rows = canvas.getRows()
	var ok := ATLevels.saveCustomJson(fileName, name, currentTheme, rows)
	if ok:
		status.text = "Status: 已保存 %s.json" % fileName
		populateLoadList()
		fileEdit.text = fileName
	else:
		status.text = "Status: 保存失败"


func onLoadPressed() -> void:
	Audio.playButtonDown()
	var idx := loadOption.selected
	if idx < 0:
		status.text = "Status: 请选择关卡"
		return
	var fileName := loadOption.get_item_text(idx)
	var data := ATLevels.loadCustomJson(fileName)
	canvas.loadFromData(data)
	nameEdit.text = data[0]
	currentLevelName = data[0]
	currentTheme = data[1]
	# 同步主题下拉框
	for i in themeOption.item_count:
		if themeOption.get_item_text(i) == currentTheme:
			themeOption.selected = i
			break
	fileEdit.text = fileName
	refreshStatus()


func onBackPressed() -> void:
	Audio.playButtonDown()
	Game.changeScene(Settings.SCENE_TITLE)


func onWidthValueChanged(v: float) -> void:
	refreshStatus()


func onHeightValueChanged(v: float) -> void:
	refreshStatus()


# ---------- 画布回调 ----------
func onTilePainted(x: int, y: int, tile: int) -> void:
	refreshStatus(x, y, tile)


# ---------- 状态 ----------
func refreshStatus(px: int = -1, py: int = -1, pt: int = -1) -> void:
	var s := "Status: %dx%d | Brush: %s" % [canvas.width, canvas.height, tileName(canvas.brush)]
	if px >= 0:
		s += " | Last paint: (%d, %d) = %s" % [px, py, tileName(pt)]
	status.text = s


func populateLoadList() -> void:
	loadOption.clear()
	var names := ATLevels.listCustomLevels()
	for n in names:
		loadOption.add_item(n)
	if names.is_empty():
		loadOption.add_item("(none)")
		loadOption.disabled = true
	else:
		loadOption.disabled = false
