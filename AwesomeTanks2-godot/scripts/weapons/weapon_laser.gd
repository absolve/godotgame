extends ATWeapon
## Laser 武器脚本 —— 无需单独激光子弹场景
## 武器场景自带 RayCast2D(Ray) + Line2D(Line，贴图=激光纹理)，
## 持续开火：坦克按住时每帧 set_firing(true) → _physics_process 做一次射线伤害/绘制后
##           把 can_fire 置回 false（下一帧由开火输入再次置 true 即形成“持续”）。
## 音效：持续循环音 laser_loop；开火音 laser_start 只在一次连发开始时播放一次
##      （依据上一帧是否在开火判断）。

class_name ATLaserWeapon

@export var beamRange := 620.0
@export var beamDps := 900.0       # 每秒伤害（射线命中按 delta 累计）
@export var drainPerSec := 60.0   # 每秒弹药消耗

@onready var ray: RayCast2D = $Ray
@onready var line: Line2D = $Line

var beamLoopOn := false
var wasFiring := false            # 上一物理帧是否开火（用于一次性播放 laser_start + _draw 是否画）
var targetPos := Vector2.ZERO       # 光束终点（节点本地坐标，_draw 直接用）
var muzzle := Vector2.ZERO          # 炮口（全局坐标，用来摆射线）
var muzzleLocal := Vector2.ZERO   # 炮口的本地坐标（和 targetPos 同一坐标系，避免混用）

func _ready() -> void:
	super._ready()
	if id == "":
		id = "laser"
	canFire = false
	#_line.visible = false  # 运行时默认隐藏；场景内保持可见便于编辑预览

func setFiring(on: bool) -> void:
	if on:
		if ammo <= 0:
			outOfAmmo.emit(self)
			return
		canFire = true
	else:
		canFire = false

func aimBeam() -> void:
	if tank == null or not is_instance_valid(tank):
		return
	muzzle = tank.getTurretPosition(muzzleOffset) \
		if tank.has_method("getTurretPosition") else global_position
	muzzleLocal = to_local(muzzle)
	var angle := getAimAngle()
	ray.global_position = muzzle
	ray.rotation = angle
	# 关键：刚挪完射线就必须强制刷新，否则下面 is_colliding()/get_collision_point()
	# 读到的是射线**上一帧/上一次开火**的位置 → 画面里就会画出"上次那条线"
	ray.force_raycast_update()
	
	#targetPos=Vector2(beam_range,0).rotated(_get_aim_angle())
	#_line.global_position = muzzle
	#_line.rotation = angle
	#_line.visible = true


func hitScan(delta: float) -> void:
	# 先按最大射程算终点，命中再改成命中点（否则打空时 targetPos 会一直留着上次的命中点）
	var endGlobal := muzzle + Vector2(beamRange, 0.0).rotated(ray.global_rotation)
	if ray.is_colliding():
		var point: Vector2 = ray.get_collision_point()
		endGlobal = point
		# 命中点特效（每把武器在场景里配一种，见 impactFx；带节流，不会每帧都生成）
		tickImpactFx(delta, point)
		var collider := ray.get_collider()
		if collider and collider.has_method("onBulletHit") and collider != tank:
			var ot: int = collider.team if "team" in collider else Constants.Team.CPU
			if ot != team:
				collider.onBulletHit(beamDps * delta, self, null)
	#_line.points = PackedVector2Array([Vector2.ZERO, Vector2(dist, 0.0)])
	targetPos = to_local(endGlobal)

	#queue_redraw()

func finishBurst() -> void:
	if beamLoopOn:
		Audio.stopLaserLoop()
		beamLoopOn = false
	if wasFiring:
		wasFiring = false
		queue_redraw()      # 只在"亮 → 灭"的那一帧重绘一次，把线擦掉
		
	#_line.visible = false


func _physics_process(delta: float) -> void:
	if not canFire:
		finishBurst()
		return
	if not infiniteAmmo and ammo <= 0:
		outOfAmmo.emit(self)
		finishBurst()
		return
	# 弹药消耗
	if not hasInfiniteAmmo():
		ammo = maxi(0, ammo - int(drainPerSec * delta + 0.5))
	# 一次连发开始：只播一次 laser_start + 启动持续音
	if not beamLoopOn:
		Audio.playSfx("laser_start.mp3")
		Audio.startLaserLoop()
		beamLoopOn = true
		
	# 射线即时命中 + 绘制
	aimBeam()
	hitScan(delta)
	wasFiring = true
	canFire = false  # 本帧开火信号已消耗，持续开火由坦克每帧 set_firing(true) 维持
	queue_redraw()

func _draw() -> void:
	if wasFiring:
		var brightness := randf_range(0.55, 1.0)
		var laserColor := Color(brightness, brightness * 0.08, brightness * 0.08, 1.0)
		# 两个端点都在 _physics_process 里转成本地坐标（同一帧、同一变换），
		# 这里不要再 to_local()，否则绘制发生在渲染帧、节点已跟着坦克转动 → 起点/终点对不上
		draw_line(muzzleLocal, targetPos, laserColor, 2.0, true)
