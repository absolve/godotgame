extends Node
## SceneTransition —— 场景过渡（移植自 machine-TD scene/scene_transition.tscn）
##
## 结构见 `scenes/scene_transition.tscn`：
##   SceneTransition(Node, 本脚本, 自动加载)
##     └─ CanvasLayer(CanvasLayer, layer 100)
##          └─ Overlay(ColorRect + shaders/transition.gdshader)
##
## 用法：`Game.changeScene("res://scenes/title.tscn")`（游戏里所有切场景都走 Game.changeScene，
##       它再转发到这里；也可以直接 `SceneTransition.changeScene(path)`）。
##
## 着色器 factor 的语义：**0 = 完全透明，1 = 完全覆盖**。
## 所以先补间 0 → 1（遮罩擦入盖住屏幕），同时后台线程加载目标场景；
## 加载完 change_scene_to_packed，再把 factor 补间回 0（擦出，露出新场景）。
## 擦除方向/软边/颜色都在场景里的 ShaderMaterial 上，改表现不用动代码。

## 一次过渡的总时长（秒）；擦入 + 擦出各占一半
const DEFAULT_DURATION := 0.6

@onready var overlay: ColorRect = $CanvasLayer/Overlay

## 是否正在过渡（过渡中会吞掉输入，避免点击穿透到旧场景）
var isTransitioning: bool = false

var pendingScenePath: String = ""
var pendingDuration: float = 0.0
## 过渡途中又来的请求（过渡结束后接着放，避免把玩家的点击吞掉）
var queuedScenePath: String = ""
var queuedDuration: float = 0.0

var _material: ShaderMaterial


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_material = overlay.material as ShaderMaterial
	overlay.visible = false
	_setFactor(0.0)
	_syncResolution()
	get_viewport().size_changed.connect(_syncResolution)


# ============================================================
# 对外：切场景
# ============================================================
## 切到指定场景（带过渡）；过渡途中再调用会被记下来，等这次结束接着放
func changeScene(path: String, duration: float = DEFAULT_DURATION) -> void:
	if path == "":
		return
	if isTransitioning:
		queuedScenePath = path
		queuedDuration = duration
		return
	_begin(path, duration)


func _begin(path: String, duration: float) -> void:
	isTransitioning = true
	pendingScenePath = path
	pendingDuration = duration

	overlay.visible = true
	_setFactor(0.0)

	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(_setFactor, 0.0, 1.0, maxf(duration * 0.5, 0.12))
	tween.tween_callback(_startSceneLoad)


# ============================================================
# 加载（后台线程）→ 换场景 → 擦出
# ============================================================
func _startSceneLoad() -> void:
	var err: int = ResourceLoader.load_threaded_request(pendingScenePath)
	if err != OK:
		push_error("SceneTransition: 加载请求失败 %s" % pendingScenePath)
		_finish()
		return
	call_deferred("_monitorSceneLoad")


func _monitorSceneLoad() -> void:
	while isTransitioning:
		var status: int = ResourceLoader.load_threaded_get_status(pendingScenePath)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var packed: Resource = ResourceLoader.load_threaded_get(pendingScenePath)
			if packed is PackedScene:
				get_tree().change_scene_to_packed(packed)
				_playWipeOut()
			else:
				push_error("SceneTransition: 不是 PackedScene %s" % pendingScenePath)
				_finish()
			return
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("SceneTransition: 加载失败 %s" % pendingScenePath)
			_finish()
			return
		await get_tree().process_frame


func _playWipeOut() -> void:
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(_setFactor, 1.0, 0.0, maxf(pendingDuration * 0.5, 0.12))
	tween.tween_callback(_finish)


func _finish() -> void:
	_setFactor(0.0)
	overlay.visible = false
	pendingScenePath = ""
	pendingDuration = 0.0
	isTransitioning = false
	# 过渡途中攒下的请求，接着放
	if queuedScenePath != "":
		var path := queuedScenePath
		var duration := queuedDuration
		queuedScenePath = ""
		queuedDuration = 0.0
		_begin(path, duration)


# ============================================================
# 着色器参数 / 输入
# ============================================================
## 着色器用它做宽高比校正
func _syncResolution() -> void:
	if _material == null:
		return
	_material.set_shader_parameter("node_resolution", get_viewport().get_visible_rect().size)


func _setFactor(value: float) -> void:
	if _material != null:
		_material.set_shader_parameter("factor", value)


## 过渡期间消费所有输入事件，防止点击穿透到下层场景
func _input(_event: InputEvent) -> void:
	if isTransitioning:
		get_viewport().set_input_as_handled()
