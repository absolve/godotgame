extends Control
## SummaryAlert —— 关卡结算弹窗（对应 H5 window.AT.gui.SummaryAlert，L23053~L23092）
##
## 时序完全照 H5：
##   打开 → 先等 2s（让爆炸 / 全场吸金币演完）→ 整组淡入 250ms
##        头图 再 0.25s 从上方 100px 滑入；收益行 再 0.425s 滑入
##        失败时才显示 CONTINUE 按钮，0.775s 后从下方滑入；
##        胜利时 4.5s 后自动 continue（H5: time.events.add(4500, this.continue)）
##   继续 → 头图向右飞出 / 收益向左飞出 / 按钮向下飞出（Back.In 700ms）
##         → 遮罩淡到全黑（延迟 0.9s，250ms）→ 发 continue_pressed
##
## 纯视觉/时序组件：只发 shown（面板真正出现的时刻）与 continue_pressed 信号，
## 具体去向由关卡根脚本决定（关卡结算时**不暂停世界**，和 H5 一致）。

signal shown                  # 面板真正出现（2s 延迟后；关卡已不再据此暂停世界，留作扩展/调试）
signal continuePressed

const TEX_COMPLETE: Texture2D = preload("res://sprites/game/summary/header_complete.png.tres")
const TEX_FAILED: Texture2D = preload("res://sprites/game/summary/header_failed.png.tres")

const DELAY := 2.0            # H5: 整组 alpha tween delay 2000ms
const FADE := 0.25            # H5: 250ms Linear
const HEADER_DELAY := 0.25    # H5: 2250ms
const PROFIT_DELAY := 0.425   # H5: 2425ms
const BTN_DELAY := 0.775      # H5: 2775ms
const AUTO_CONTINUE_SEC := 4.5
const OUT_TIME := 0.7         # H5: Back.In 700ms
const OUT_DIM_DELAY := 0.9    # H5: 遮罩 alpha tween delay 900ms
const OUT_DIM_TIME := 0.25

@onready var dim: ColorRect = $Dim
@onready var header: TextureRect = $Center/Panel/Header
@onready var profit: TextureRect = $Center/Panel/Profit
@onready var profitValue: Label = $Center/Panel/Profit/Value
@onready var continueBtn: TextureButton = $Center/Panel/ContinueBtn

var tweens: Array[Tween] = []
var baseHeader := Vector2.ZERO
var baseProfit := Vector2.ZERO
var baseBtn := Vector2.ZERO


func _ready() -> void:
	visible = false
	baseHeader = header.position
	baseProfit = profit.position
	baseBtn = continueBtn.position
	continueBtn.pressed.connect(onContinue)
	# 背景点击不响应，必须点按钮
	mouse_filter = Control.MOUSE_FILTER_STOP


func open(success: bool, amount: int) -> void:
	killTweens()
	header.texture = TEX_COMPLETE if success else TEX_FAILED
	profitValue.text = formatSummaryMoney(amount)
	continueBtn.visible = not success
	visible = true
	# 起始状态：整组透明；头图/收益行在最终位置上方 100px；按钮在下方 100px（H5: -200→-100、-10→90、275→175）
	modulate.a = 0.0
	header.modulate.a = 0.0
	profit.modulate.a = 0.0
	continueBtn.modulate.a = 0.0
	header.position = baseHeader + Vector2(0.0, -100.0)
	profit.position = baseProfit + Vector2(0.0, -100.0)
	continueBtn.position = baseBtn + Vector2(0.0, 100.0)
	dim.color = Color(0, 0, 0, 0.6)
	playEnter(success)


func close() -> void:
	killTweens()
	visible = false


# ============================================================
# 入场
# ============================================================
func playEnter(success: bool) -> void:
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, FADE).set_delay(DELAY)
	tw.tween_property(header, "modulate:a", 1.0, FADE).set_delay(DELAY + HEADER_DELAY)
	tw.tween_property(profit, "modulate:a", 1.0, FADE).set_delay(DELAY + PROFIT_DELAY)
	tw.tween_property(header, "position:y", baseHeader.y, FADE) \
		.set_delay(DELAY + HEADER_DELAY).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(profit, "position:y", baseProfit.y, FADE) \
		.set_delay(DELAY + PROFIT_DELAY).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if not success:
		tw.tween_property(continueBtn, "modulate:a", 1.0, FADE).set_delay(DELAY + BTN_DELAY)
		tw.tween_property(continueBtn, "position:y", baseBtn.y, FADE) \
			.set_delay(DELAY + BTN_DELAY).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tweens.append(tw)

	# 面板出现的时刻（关卡不再据此暂停世界，信号留给以后需要"面板出现的瞬间"的地方）
	var shownTw := create_tween()
	shownTw.tween_interval(DELAY)
	shownTw.tween_callback(func() -> void: shown.emit())
	tweens.append(shownTw)

	# 胜利：4.5s 后自动继续（H5 同）
	if success:
		var autoTw := create_tween()
		autoTw.tween_interval(AUTO_CONTINUE_SEC)
		autoTw.tween_callback(onContinue)
		tweens.append(autoTw)


# ============================================================
# 出场（点击/自动继续）
# ============================================================
func onContinue() -> void:
	if not visible:
		return
	Audio.playButtonDown()
	var w := get_viewport_rect().size.x * 0.5 + 300.0
	var h := get_viewport_rect().size.y * 0.6
	var tw := create_tween().set_parallel(true)
	tw.tween_property(header, "position:x", header.position.x + w, OUT_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(profit, "position:x", profit.position.x - w, OUT_TIME) \
		.set_delay(0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	if continueBtn.visible:
		tw.tween_property(continueBtn, "position:y", continueBtn.position.y + h, OUT_TIME) \
			.set_delay(0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(dim, "color:a", 1.0, OUT_DIM_TIME).set_delay(OUT_DIM_DELAY)
	tweens.append(tw)

	var doneTw := create_tween()
	doneTw.tween_interval(OUT_DIM_DELAY + OUT_DIM_TIME)
	doneTw.tween_callback(finishContinue)
	tweens.append(doneTw)


func finishContinue() -> void:
	visible = false
	continuePressed.emit()


func killTweens() -> void:
	for tw in tweens:
		if tw != null and tw.is_valid():
			tw.kill()
	tweens.clear()


func formatSummaryMoney(v: int) -> String:
	# 对应 H5 SummaryAlert.updateProfit：>=1e5 时先除以 1000 再按通用规则格式化，末尾加 "k"
	# （格式化统一走 Game._format_money，见 game.gd）
	if v >= 100000:
		return Game.formatMoney(int(v / 1000.0)) + "k"
	return Game.formatMoney(v)
