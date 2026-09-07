extends Control
## HelpAlert —— 帮助图册弹窗（图片直接来自 sprites/menu/help/*.png）
## 点击图片/滚轮即可翻页：点一下看下一张；最后一张再点即关闭。
## 右上角 X 可随时关闭；底部显示 "当前 / 总数"。
## 纯视觉组件：只发 closed 信号，由关卡根脚本决定暂停/恢复逻辑。

signal closed

const HELP_DIR := "res://sprites/menu/help/"

@onready var _image: TextureRect = $Center/Panel/Image
@onready var _counter: Label = $Center/Panel/Counter
@onready var _catcher: TextureButton = $Center/Panel/Catcher

var _pages: Array[String] = []
var _index: int = 0


func _ready() -> void:
	visible = false
	_collect_pages()
	($Center/Panel/CloseBtn as TextureButton).pressed.connect(_on_close)
	_catcher.pressed.connect(_on_next)
	_catcher.gui_input.connect(_on_catcher_gui_input)


## 列出帮助图册（自动扫描 sprites/menu/help/ 下 .png，按名称排序）
func _collect_pages() -> void:
	_pages.clear()
	var dir := DirAccess.open(HELP_DIR)
	if dir == null:
		return
	for f in dir.get_files():
		if f.ends_with(".png"):
			_pages.append(f)
	_pages.sort()
	_index = 0


func open() -> void:
	_index = 0
	_refresh_page()
	visible = true


func close() -> void:
	visible = false


func _refresh_page() -> void:
	if _pages.is_empty():
		_image.texture = null
		_catcher.disabled = true
		_counter.text = "0 / 0"
		return
	_image.texture = load(HELP_DIR + _pages[_index]) as Texture2D
	_counter.text = "%d / %d" % [_index + 1, _pages.size()]
	_catcher.disabled = false


func _on_next() -> void:
	# 点击翻页；最后一张点击视为看完 → 关闭
	if _index < _pages.size() - 1:
		_index += 1
		_refresh_page()
	else:
		_on_close()


func _on_prev() -> void:
	if _index > 0:
		_index -= 1
		_refresh_page()


func _on_catcher_gui_input(event: InputEvent) -> void:
	# 滚轮：向上上一张 / 向下下一张
	if event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_on_next()
			_catcher.accept_event()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_on_prev()
			_catcher.accept_event()


func _on_close() -> void:
	Audio.play_button_down()
	visible = false
	closed.emit()
