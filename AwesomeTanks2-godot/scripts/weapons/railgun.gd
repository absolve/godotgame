extends ATWeapon
## railgun 武器脚本（场景继承 weapon.tscn 基类；覆写 _shoot 为轨道炮单发射击）
## 对应原项目 window.AT.Railgun（awesome_tanks_2.js L21635~21686）
##
## 无子弹：武器内置三段（railgun.tscn）——
##   WallRay (RayCast2D) —— 只检测静态墙(WALL 层)，决定光束/判定区长度；
##   HitArea (Area2D + HitShape 矩形) —— 用射线算出的长度设矩形，逐个命中段内
##       敌人/障碍（物理帧读 overlapping_bodies，同一目标每发只结算一次）；
##   Beam (Line2D) —— 光束显示：railgun_0/railgun_1 两帧贴图按 ~30fps 交替(帧动画)，
##       随生命剩余收缩宽度并淡出（对应 H5 贴图缩放+每帧随机切帧）。
## 开火节流沿用基类 can_fire/FireTimer；本脚本只覆写 _shoot（一次命中+光束）。

class_name ATWeaponRailgun

const TEX_0: Texture2D = preload("res://sprites/atlas/game_51.png")
const TEX_1: Texture2D = preload("res://sprites/atlas/game_262.png")

@export var beam_range := 1200.0   # 无墙时的最长光束
@export var beam_width := 20.0     # 判定带宽度 = 光束起始厚度

@onready var _wall_ray: RayCast2D = $WallRay
@onready var _hit_area: Area2D = $HitArea
@onready var _hit_shape: CollisionShape2D = $HitArea/HitShape
@onready var _beam: Line2D = $Beam

var _beam_t := 0.0          # 光束剩余可见时间
var _beam_total := 0.1      # 本发光束总时长
var _flicker_t := 0.0       # 贴图交替计时
var _tex_alt := false       # 当前帧用 railgun_1？
var _damaged: Dictionary = {}   # 本发已结算目标（避免同一目标多次受击）


func _ready() -> void:
	super._ready()
	_beam.visible = false
	_hit_area.monitoring = false
	# 独立形状副本：防止多实例共享场景 sub_resource 被 resize 相互影响
	if _hit_shape.shape != null:
		_hit_shape.shape = (_hit_shape.shape as Shape2D).duplicate()


## 光束生命内的显示/命中结算
func _physics_process(delta: float) -> void:
	if _beam_t <= 0.0:
		return
	_beam_t -= delta
	_collect_hits()
	_flicker_t -= delta
	if _flicker_t <= 0.0:
		_flicker_t = 1.0 / 30.0
		_tex_alt = not _tex_alt
		_beam.texture = TEX_1 if _tex_alt else TEX_0
	var p := clampf(_beam_t / maxf(_beam_total, 0.0001), 0.0, 1.0)
	_beam.width = maxf(1.5, beam_width * 0.85 * p + 2.0)
	_beam.modulate.a = p
	if _beam_t <= 0.0:
		_hide_beam()


## 单发轨道炮：射线找墙 → 设判定区 → 显示光束（基类负责 can_fire/计时）
func _shoot() -> void:
	_fire_shot()
	# 音效 + 弹药（参考基类 _shoot 尾部；基类此处不生成子弹）
	if _fire_sound != null and _fire_sound.stream != null:
		_fire_sound.play()
	if ammo < 999999:
		ammo -= 1
		if ammo <= 0:
			ammo = 0
			out_of_ammo.emit(self)
	shot.emit(self)


func _fire_shot() -> void:
	if tank == null or not is_instance_valid(tank):
		return
	var angle: float = _get_aim_angle()
	var dir := Vector2.from_angle(angle)
	var muzzle: Vector2 = tank.get_turret_position(spawn_distance) \
		if tank.has_method("get_turret_position") else tank.global_position

	# 1) 射线找墙（只认 WALL 层 → 光束穿过敌人/障碍直到静态墙，与 H5 一致）
	_wall_ray.global_position = muzzle
	_wall_ray.rotation = angle
	_wall_ray.force_raycast_update()
	var length := beam_range
	var end := muzzle + dir * beam_range
	var hit_wall := false
	if _wall_ray.is_colliding():
		var cp: Vector2 = _wall_ray.get_collision_point()
		length = clampf((cp - muzzle).length(), 4.0, beam_range)
		end = muzzle + dir * length
		hit_wall = true

	# 2) 判定区：矩形长=光束长、宽=beam_width，中心在光束中点（跟随当前朝向）
	var rect := _hit_shape.shape as RectangleShape2D
	if rect != null:
		rect.size = Vector2(maxf(length, 4.0), beam_width)
	_hit_area.global_position = muzzle + dir * (length * 0.5)
	_hit_area.rotation = angle
	_hit_area.monitoring = true

	# 3) 光束（Line2D）：从炮口到终点；贴图两帧交替 + 淡出在 _physics_process
	_beam.global_position = muzzle
	_beam.rotation = angle
	_beam.points = PackedVector2Array([Vector2.ZERO, Vector2(maxf(length, 2.0), 0.0)])
	_beam.width = beam_width
	_beam.modulate = Color(1, 1, 1, 1)
	_beam.visible = true
	_beam_total = maxf(life, 0.1)
	_beam_t = _beam_total
	_damaged.clear()

	# 4) 墙端火花（H5 star+10 spark）
	if hit_wall:
		Fx.spark(end, _fx_holder())


## 结算当前判定区内未处理过的目标
func _collect_hits() -> void:
	if not _hit_area.monitoring:
		return
	for body in _hit_area.get_overlapping_bodies():
		if body == null or not is_instance_valid(body):
			continue
		if body == tank:
			continue
		if _damaged.has(body):
			continue
		if not body.has_method("on_bullet_hit"):
			continue
		# 同队坦克不误伤；障碍物/生成器等无 team 属性 → 双方都可破坏
		if "team" in body and int(body.team) == team:
			continue
		_damaged[body] = true
		body.on_bullet_hit(damage, self, null)


func _hide_beam() -> void:
	_beam.visible = false
	_hit_area.monitoring = false
	_damaged.clear()
	_beam_t = 0.0


func _fx_holder() -> Node:
	if tank != null and is_instance_valid(tank) and tank.get_parent() != null:
		return tank.get_parent()
	return get_tree().current_scene
