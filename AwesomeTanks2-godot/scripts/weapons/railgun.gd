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

@export var beamRange := 1200.0   # 无墙时的最长光束
@export var beamWidth := 20.0     # 判定带宽度 = 光束起始厚度

@onready var wallRay: RayCast2D = $WallRay
@onready var hitArea: Area2D = $HitArea
@onready var hitShape: CollisionShape2D = $HitArea/HitShape
@onready var beam: Line2D = $Beam

var beamT := 0.0          # 光束剩余可见时间
var beamTotal := 0.1      # 本发光束总时长
var flickerT := 0.0       # 贴图交替计时
var texAlt := false       # 当前帧用 railgun_1？
var damaged: Dictionary = {}   # 本发已结算目标（避免同一目标多次受击）


func _ready() -> void:
	# 场景里未写 id 时补上（基类 _ready 会按 id 套用 PRESETS 的开火音效，故必须先设）
	if id == "":
		id = "railgun"
	super._ready()
	beam.visible = false
	hitArea.monitoring = false
	# 独立形状副本：防止多实例共享场景 sub_resource 被 resize 相互影响
	if hitShape.shape != null:
		hitShape.shape = (hitShape.shape as Shape2D).duplicate()


## 单发轨道炮：射线找墙 → 设判定区 → 显示光束（基类负责 can_fire/计时）
func shoot() -> void:
	fireShot()
	# 音效 + 弹药（参考基类 _shoot 尾部；基类此处不生成子弹）
	if fireSound != null and fireSound.stream != null:
		fireSound.play()
	if not infiniteAmmo:
		ammo -= 1
		if ammo <= 0:
			ammo = 0
			outOfAmmo.emit(self)
	applyRecoil()
	shot.emit(self)


func fireShot() -> void:
	if tank == null or not is_instance_valid(tank):
		return
	var angle: float = getAimAngle()
	var dir := Vector2.from_angle(angle)
	var muzzle: Vector2 = tank.getTurretPosition(muzzleOffset) \
		if tank.has_method("getTurretPosition") else tank.global_position

	# 1) 射线找墙（只认 WALL 层 → 光束穿过敌人/障碍直到静态墙，与 H5 一致）
	wallRay.global_position = muzzle
	wallRay.rotation = angle
	wallRay.force_raycast_update()
	var length := beamRange
	var end := muzzle + dir * beamRange
	var hitWall := false
	if wallRay.is_colliding():
		var cp: Vector2 = wallRay.get_collision_point()
		length = clampf((cp - muzzle).length(), 4.0, beamRange)
		end = muzzle + dir * length
		hitWall = true

	# 2) 判定区：矩形长=光束长、宽=beam_width，中心在光束中点（跟随当前朝向）
	var rect := hitShape.shape as RectangleShape2D
	if rect != null:
		rect.size = Vector2(maxf(length, 4.0), beamWidth)
	hitArea.global_position = muzzle + dir * (length * 0.5)
	hitArea.rotation = angle
	hitArea.monitoring = true

	# 3) 光束（Line2D）：从炮口到终点；贴图两帧交替 + 淡出在 _physics_process
	beam.global_position = muzzle
	beam.rotation = angle
	beam.points = PackedVector2Array([Vector2.ZERO, Vector2(maxf(length, 2.0), 0.0)])
	beam.width = beamWidth
	beam.modulate = Color(1, 1, 1, 1)
	beam.visible = true
	beamTotal = maxf(life, 0.1)
	beamT = beamTotal
	damaged.clear()

	# 4) 墙端命中特效：只用场景里配的那一种（H5 是 1 星 + 10 个 spark_3，这里默认配 sparkBurst）
	if hitWall:
		Fx.spawnNamed(impactFx, end, fxHolder())


## 结算当前判定区内未处理过的目标
func collectHits() -> void:
	if not hitArea.monitoring:
		return
	for body in hitArea.get_overlapping_bodies():
		if body == null or not is_instance_valid(body):
			continue
		if body == tank:
			continue
		if damaged.has(body):
			continue
		if not body.has_method("onBulletHit"):
			continue
		# 同队坦克不误伤；障碍物/生成器等无 team 属性 → 双方都可破坏
		if "team" in body and int(body.team) == team:
			continue
		damaged[body] = true
		body.onBulletHit(damage, self, null)


func hideBeam() -> void:
	beam.visible = false
	hitArea.monitoring = false
	damaged.clear()
	beamT = 0.0


## 光束生命内的显示/命中结算
func _physics_process(delta: float) -> void:
	if beamT <= 0.0:
		return
	beamT -= delta
	collectHits()
	flickerT -= delta
	if flickerT <= 0.0:
		flickerT = 1.0 / 30.0
		texAlt = not texAlt
		beam.texture = TEX_1 if texAlt else TEX_0
	var p := clampf(beamT / maxf(beamTotal, 0.0001), 0.0, 1.0)
	beam.width = maxf(1.5, beamWidth * 0.85 * p + 2.0)
	beam.modulate.a = p
	if beamT <= 0.0:
		hideBeam()
