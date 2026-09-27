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

@onready var _bar: TextureProgressBar = $Bar

var _target: Node = null
var _last_health: float = -1.0
var _idle: float = 0.0
var _shown: bool = false
var _tween: Tween = null


func _ready() -> void:
	_target = get_parent()
	modulate.a = 0.0
	visible = false
	_last_health = _health()
	_refresh()


func _process(delta: float) -> void:
	global_rotation = 0.0                 # H5 postUpdate：血条抵消父节点旋转，永远水平
	var hp := _health()
	if hp <= 0.0:                         # 目标已死 → 立刻淡出
		hide_bar()
		return
	if not is_equal_approx(hp, _last_health):
		_last_health = hp
		_refresh()
		show_bar()                        # H5：血量一变就显示（受击掉血、治疗回血同理）
		return
	if permanent:
		show_bar()
		return
	if _shown:
		_idle += delta
		if _idle >= IDLE_TIME:
			hide_bar()


# ============================================================
# 对外接口
# ============================================================
## 显示血条（H5 show）：重置待机计时 + 立刻按当前血量刷新 + 200ms 淡入
func show_bar() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	_last_health = _health()
	_refresh()
	_idle = 0.0
	if _shown:
		return                            # 已在显示中：只重置计时（避免每帧重启补间）
	_shown = true
	visible = true
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)


## 隐藏血条（H5 hide）：200ms 淡出后置为不可见
func hide_bar() -> void:
	if not _shown and not visible:
		return
	_shown = false
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	_tween.tween_callback(func() -> void: visible = false)


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null


# ============================================================
# 内部：读目标血量 / 刷新前景裁切
# ============================================================
## 按血量比例刷新条（H5: cropRect.width = health / maxHealth * 95）
func _refresh() -> void:
	if _bar == null:
		return
	var mx := _max_health()
	_bar.value = clampf(_health() / mx * 100.0, 0.0, 100.0) if mx > 0.0 else 0.0


func _health() -> float:
	if _target == null or not is_instance_valid(_target) or not ("health" in _target):
		return 0.0
	return float(_target.get("health"))


func _max_health() -> float:
	if _target == null or not is_instance_valid(_target) or not ("max_health" in _target):
		return 0.0
	return float(_target.get("max_health"))
