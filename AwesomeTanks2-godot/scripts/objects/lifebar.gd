class_name ATLifebar
extends Node2D
## Lifebar —— 头顶血条（对应原项目 window.AT.Lifebar，awesome_tanks_2.js L20744~20766）
##
## 场景：scenes/objects/lifebar.tscn（根节点即本类）。作为**子节点**挂到任何有
## health/max_health 的单位或物体上（敌人/炮塔/生成器/油桶/木箱/木板/砖墙…）。
##
## 布局（照抄 H5）：贴图 95×15、整体 scale 0.5、位于目标上方 30px（H5 pivot(0,60)×0.5），
## 血条背景居中、前景按血量比例从左往右裁切；血条永远水平（H5 rotation = -parent.rotation）。
##
## 用法：目标受击时调用 show_bar() → 200ms 淡入；0.833s 内没有再次受击 → 200ms 淡出隐藏。
## 血量变化会自动刷新（每帧与上一帧的 health 比较，H5 postUpdate 同款）。

## H5 show/hide 补间时长 200ms
const FADE_TIME := 0.2
## H5 idleTime：最后一次受击后 0.833s 自动隐藏
const IDLE_TIME := 0.833

## H5 _permanent：常显（原项目 level.showHealth 调试开关用；本项目暂无该开关）
@export var permanent: bool = false

@onready var bar: TextureProgressBar = $Bar

var targetNode: Node = null
var lastHealth: float = -1.0
var idle: float = 0.0
var shown: bool = false
var tween: Tween = null


func _ready() -> void:
	targetNode = get_parent()
	modulate.a = 0.0
	visible = false
	lastHealth = health()
	refresh()


# ============================================================
# 对外接口
# ============================================================
## 显示血条（H5 show）：重置待机计时 + 立刻按当前血量刷新 + 200ms 淡入
func showBar() -> void:
	if targetNode == null or not is_instance_valid(targetNode):
		return
	lastHealth = health()
	refresh()
	idle = 0.0
	if shown:
		return                            # 已在显示中：只重置计时（避免每帧重启补间）
	shown = true
	visible = true
	killTween()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)


## 隐藏血条（H5 hide）：200ms 淡出后置为不可见
func hideBar() -> void:
	if not shown and not visible:
		return
	shown = false
	killTween()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(func() -> void: visible = false)


func killTween() -> void:
	if tween != null and tween.is_valid():
		tween.kill()
	tween = null


# ============================================================
# 内部：读目标血量 / 刷新前景裁切
# ============================================================
## 按血量比例刷新条（H5: cropRect.width = health / maxHealth * 95）
func refresh() -> void:
	if bar == null:
		return
	var mx := maxHealth()
	bar.value = clampf(health() / mx * 100.0, 0.0, 100.0) if mx > 0.0 else 0.0


func health() -> float:
	if targetNode == null or not is_instance_valid(targetNode) or not ("health" in targetNode):
		return 0.0
	return float(targetNode.get("health"))


func maxHealth() -> float:
	if targetNode == null or not is_instance_valid(targetNode) or not ("maxHealth" in targetNode):
		return 0.0
	return float(targetNode.get("maxHealth"))


func _process(delta: float) -> void:
	global_rotation = 0.0                 # H5 postUpdate：血条抵消父节点旋转，永远水平
	var hp := health()
	if hp <= 0.0:                         # 目标已死 → 立刻淡出
		hideBar()
		return
	if not is_equal_approx(hp, lastHealth):
		lastHealth = hp
		refresh()
		showBar()                        # H5：血量一变就显示（受击掉血、治疗回血同理）
		return
	if permanent:
		showBar()
		return
	if shown:
		idle += delta
		if idle >= IDLE_TIME:
			hideBar()
