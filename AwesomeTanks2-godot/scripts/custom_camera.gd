extends Camera2D

@export var target: Node2D
#@export var max_offset: Vector2 = Vector2(100, 100)
@export var edge_threshold: float = 0.2
@export var smooth_speed: float = 6.0 # 平滑速度
@export var scalingFactor = 0.10

var viewport_size: Vector2
var viewport

func _ready():
	viewport = get_viewport()
	viewport_size = viewport.get_visible_rect().size
	

func _physics_process(delta: float) -> void:
	if not target:
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


	# 计算目标位置并进行平滑移动
	var desired = target.global_position + offset
	global_position = global_position.lerp(desired, smooth_speed * delta)
