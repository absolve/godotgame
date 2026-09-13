class_name ATFogTile
extends Area2D
## FogTile —— 单个黑雾瓦片（Area2D + 黑色贴图，正好盖住地图一个 tile）
##
## 结构见 scenes/level/fog_tile.tscn：
##   FogTile (Area2D，本类)      —— 位于 FOG 碰撞层，供视野“射线”检测
##   ├─ Sprite (Sprite2D)        —— 贴图 res://sprites/game/fog_tile.png.tres
##   │                              该图在 atlas 里只有 12×12（纯黑实心方块），
##   │                              这里按 tile 尺寸放大（52/12 ≈ 4.333 倍）铺满一格
##   └─ Body (CollisionShape2D)   —— 判定矩形，比一个 tile 略大（见 collision_scale），
##                                  让视野射线在还没贴近时就“擦到”本格并清雾
##
## 行为：
##   - 地图加载时由 ATFog 按地图逐格创建（每个格子一个瓦片，铺满全图）；
##   - 视野射线（Fog.reveal_fov 的物理射线）命中本瓦片即调用 clear()；
##   - clear() 先立刻关闭 monitorable（避免射线重复命中/继续前进时卡住），
##     再播放“放大 + 淡出 + 随机旋转”消失动画，动画结束 queue_free。
##
## 注意：本瓦片 monitoring=false（不需要主动检测任何东西），只作为“可被射线打中”的目标。

## 消失动画结束（瓦片将 queue_free）
signal disappeared(tile: ATFogTile)

## 贴图在 atlas 里的原始边长（fog_tile.png = 12×12），用于换算放大倍数
const SOURCE_SIZE: float = 12.0

@export var fade_time: float = 0.26      # 消失动画时长（秒）
@export var grow_scale: float = 1.35     # 消失时放大倍数
@export var spin_degrees: float = 14.0   # 消失时随机旋转角度
## 判定区相对 tile 的放大倍数（>1 表示提前命中：射线不必贴近本格就能清掉它）。
## 上限约 3.0 —— 外扩量 = (scale-1)/2 格，只要 < 1 格（墙厚），射线就不会穿墙命中墙后的黑雾。
@export var collision_scale: float = 1.8

var tile_x: int = 0
var tile_y: int = 0
var cleared: bool = false

@onready var _sprite: Sprite2D = $Sprite
@onready var _body: CollisionShape2D = $Body


func _ready() -> void:
	# 黑雾自成一层（Constants.Layer.FOG），只被黑雾射线检测
	collision_layer = 1 << (Constants.Layer.FOG - 1)
	collision_mask = 0
	monitoring = false
	monitorable = true
	_apply_tile_size()


## 按当前 tile 尺寸校正「贴图放大倍数」与「判定矩形」：
## 12×12 的贴图放大到 tile 边长，正好无缝铺满一个 tile；
## 判定区按 collision_scale 放大（比格子大一圈 → 射线提前命中，黑雾不用贴近才消失）。
func _apply_tile_size() -> void:
	var ts := float(Settings.TILE_SIZE)
	if _sprite != null:
		_sprite.scale = Vector2.ONE * (ts / SOURCE_SIZE)
	if _body != null:
		# 每个实例用独立形状，避免多实例共享场景 sub_resource
		var rect := RectangleShape2D.new()
		rect.size = Vector2(ts, ts) * maxf(collision_scale, 0.1)
		_body.shape = rect


## 让本瓦片消失（射线命中时调用）
func clear(with_animation: bool = true) -> void:
	if cleared:
		return
	cleared = true
	# 立刻不再被射线命中（同一帧内射线可继续向前推进）
	monitorable = false
	if not with_animation:
		disappeared.emit(self)
		queue_free()
		return
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE * grow_scale, fade_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 0.0, fade_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if spin_degrees > 0.0:
		tw.tween_property(self, "rotation", deg_to_rad(randf_range(-spin_degrees, spin_degrees)), fade_time)
	tw.chain().tween_callback(func() -> void:
		disappeared.emit(self)
		queue_free())
