extends Control
## SummaryAlert —— 关卡结算弹窗（对应 H5 SummaryAlert）
## 胜利：header_complete + 收益金额，无按钮，自动 4.5s 后 continue；
## 失败：header_failed + 收益金额 + CONTINUE 按钮（点击继续）。
## 纯视觉/时序组件：只发 continue_pressed 信号，由关卡根脚本决定去向。

signal continue_pressed

const TEX_COMPLETE: Texture2D = preload("res://sprites/game/summary/header_complete.png.tres")
const TEX_FAILED: Texture2D = preload("res://sprites/game/summary/header_failed.png.tres")

const AUTO_CONTINUE_SEC := 4.5

@onready var _header: TextureRect = $Center/Panel/Header
@onready var _profit_value: Label = $Center/Panel/Profit/Value
@onready var _continue_btn: TextureButton = $Center/Panel/ContinueBtn

var _auto_timer: Tween = null


func _ready() -> void:
	visible = false
	_continue_btn.pressed.connect(_on_continue)
	# 背景点击不响应，必须点按钮
	mouse_filter = Control.MOUSE_FILTER_STOP


func open(success: bool, amount: int) -> void:
	if _auto_timer != null and _auto_timer.is_valid():
		_auto_timer.kill()
	_header.texture = TEX_COMPLETE if success else TEX_FAILED
	_profit_value.text = _format_summary_money(amount)
	_continue_btn.visible = not success
	visible = true
	if success:
		_auto_timer = create_tween()
		_auto_timer.tween_interval(AUTO_CONTINUE_SEC)
		_auto_timer.tween_callback(_on_continue)


func close() -> void:
	if _auto_timer != null and _auto_timer.is_valid():
		_auto_timer.kill()
	visible = false


func _on_continue() -> void:
	if not visible:
		return
	Audio.play_button_down()
	close()
	continue_pressed.emit()


static func _format_summary_money(v: int) -> String:
	# 对应 H5 SummaryAlert.updateProfit：>=1e5 显示 xxk，其余显示整数金额
	if v >= 100000:
		return "$%dk" % int(v / 1000.0)
	return "$%d" % v
