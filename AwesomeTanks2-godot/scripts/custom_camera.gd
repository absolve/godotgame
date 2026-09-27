extends Camera2D
## CustomCamera —— 跟随玩家 + 鼠标边缘提前量 + 震屏
## 对应 H5 Level.updateCamera（L23771~L23791）：
##   - 平滑跟随目标；鼠标偏移决定镜头提前量（scalingFactor）
##   - 震屏：每帧随机 ±shake 偏移，按 30px/s 衰减，归零后复位（H5: this.shake -= 30 * physicsElapsed）
##   - FIGHT 横幅播放期间不跟随（H5: 只有 hud.fightMessageComplete 为真才 updateCamera）

@export var target: Node2D
#@export var max_offset: Vector2 = Vector2(100, 100)
@export var edge_threshold: float = 0.2
@export var smooth_speed: float = 6.0 # 平滑速度
@export var scalingFactor = 0.10
## 冻结跟随（入场 FIGHT 横幅期间用；震屏也一并暂停，与 H5 一致）
@export var frozen: bool = false

## 震屏衰减速度（px/s；H5: 30）
const SHAKE_DECAY: float = 30.0

var viewport_size: Vector2
var viewport

var _shake: float = 0.0


func _ready():
	viewport = get_viewport()
	viewport_size = viewport.get_visible_rect().size


## 触发震屏（H5 shakeCamera：只取较大值，不叠加）
func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func _physics_process(delta: float) -> void:
	if not target:
		return
	if frozen:
		offset = Vector2.ZERO
		_shake = 0.0
		return

	# 计算目标偏移（同上）
	#var viewport := get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	#var viewport_size := viewport.get_visible_rect().size
	#print(viewport_size)
	#var normalized := mouse_pos / viewport_size

	#var strength := Vector2.ZERO
	#if normalized.x < edge_threshold:
		#strength.x = 1.0 - normalized.x / edge_threshold
	#elif normalized.x > 1.0 - edge_threshold:
		#strength.x = (normalized.x - (1.0 - edge_threshold)) / edge_threshold
	#if normalized.y < edge_threshold:
		#strength.y = 1.0 - normalized.y / edge_threshold
	#elif normalized.y > 1.0 - edge_threshold:
		#strength.y = (normalized.y - (1.0 - edge_threshold)) / edge_threshold

	if mouse_pos.x - position.x >= viewport_size.x * edge_threshold:
		offset.x = (mouse_pos.x - position.x) * scalingFactor
	if mouse_pos.x - position.x <= viewport_size.x * edge_threshold:
		offset.x = (mouse_pos.x - position.x) * scalingFactor
	if mouse_pos.y - position.y >= viewport_size.y * edge_threshold:
		offset.y = (mouse_pos.y - position.y) * scalingFactor
	if mouse_pos.y - position.y <= viewport_size.y * edge_threshold:
		offset.y = (mouse_pos.y - position.y) * scalingFactor

	# 震屏：叠加在上面的偏移上（offset 每帧都会被重算，所以不会累积）
	if _shake > 0.0:
		offset += Vector2(randf_range(-_shake, _shake), randf_range(-_shake, _shake))
		_shake = maxf(_shake - SHAKE_DECAY * delta, 0.0)

	# 计算目标位置并进行平滑移动
	var desired = target.global_position + offset
	global_position = global_position.lerp(desired, smooth_speed * delta)
