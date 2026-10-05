extends Control
## HelpAlert —— 帮助图册弹窗（图片直接来自 sprites/menu/help/*.png）
## 点击图片/滚轮即可翻页：点一下看下一张；最后一张再点即关闭。
## 右上角 X 可随时关闭；底部显示 "当前 / 总数"。
## 纯视觉组件：只发 closed 信号，由关卡根脚本决定暂停/恢复逻辑。

signal closed

const HELP_DIR := "res://sprites/menu/help/"

@onready var image: TextureRect = $Center/Panel/Image
@onready var counter: Label = $Center/Panel/Counter
@onready var catcher: TextureButton = $Center/Panel/Catcher

var pages: Array[String] = []
var index: int = 0


func _ready() -> void:
	visible = false
	collectPages()
	($Center/Panel/CloseBtn as TextureButton).pressed.connect(onClose)
	catcher.pressed.connect(onNext)
	catcher.gui_input.connect(onCatcherGuiInput)


## 列出帮助图册（自动扫描 sprites/menu/help/ 下 .png，按名称排序）
func collectPages() -> void:
	pages.clear()
	var dir := DirAccess.open(HELP_DIR)
	if dir == null:
		return
	for f in dir.get_files():
		if f.ends_with(".png"):
			pages.append(f)
	pages.sort()
	index = 0


func open() -> void:
	index = 0
	refreshPage()
	visible = true


func close() -> void:
	visible = false


func refreshPage() -> void:
	if pages.is_empty():
		image.texture = null
		catcher.disabled = true
		counter.text = "0 / 0"
		return
	image.texture = load(HELP_DIR + pages[index]) as Texture2D
	counter.text = "%d / %d" % [index + 1, pages.size()]
	catcher.disabled = false


func onNext() -> void:
	# 点击翻页；最后一张点击视为看完 → 关闭
	if index < pages.size() - 1:
		index += 1
		refreshPage()
	else:
		onClose()


func onPrev() -> void:
	if index > 0:
		index -= 1
		refreshPage()


func onCatcherGuiInput(event: InputEvent) -> void:
	# 滚轮：向上上一张 / 向下下一张
	if event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			onNext()
			catcher.accept_event()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			onPrev()
			catcher.accept_event()


func onClose() -> void:
	Audio.playButtonDown()
	visible = false
	closed.emit()
