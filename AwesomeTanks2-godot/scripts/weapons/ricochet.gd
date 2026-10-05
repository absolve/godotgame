extends ATWeapon
## ricochet 武器脚本 —— 玩家版“蓄力发射”（对应 H5 Ricochet，awesome_tanks_2.js L21496~21556）
##
## 玩家：按住蓄力（消耗 1 发弹药，charge 1 秒蓄满，带 ricochet_start/loop 音效与炮口火花），
##       松开时发射 1 发反弹弹，伤害 = 基础伤害 × charge（蓄满 = 全额）。
## CPU：敌方 ricochet 保持“按住持续按 rate 自动开火”（本脚本自管理，不依赖基类节流）。
## 本脚本不依赖基类的 can_fire 触发怪癖，开火节奏在此独立实现。

class_name ATWeaponRicochet

@export var chargeMax: float = 1.0

var charge: float = 0.0
var playerCharging := false   # 玩家蓄力状态（不依赖基类 can_fire 默认值）
var chargingSfx := false
var sparkTimer := 0.0

const CHARGE_LOOP_KEY := "ricochet_charge"


func _ready() -> void:
	super._ready()
	if id == "":
		id = "ricochet"


func setFiring(on: bool) -> void:
	if team == Constants.Team.PLAYER:
		setPlayerFiring(on)
	else:
		canFire = on


## 玩家：按下开始蓄力/松开发射
func setPlayerFiring(on: bool) -> void:
	if on:
		if playerCharging:
			return            # 正在蓄力
		if ammo <= 0:
			outOfAmmo.emit(self)
			return
		if ammo < 999999:
			ammo -= 1         # 蓄力预留 1 发（H5：蓄力过程消耗弹药）
		playerCharging = true
		canFire = true
		Audio.playSfx("ricochet_start.mp3")
		Audio.startLoop(CHARGE_LOOP_KEY, "ricochet_loop.mp3")
		chargingSfx = true
	else:
		if not playerCharging:
			return
		playerCharging = false
		canFire = false
		stopChargeSfx()
		if charge > 0.0:
			fireCharged()


func fireCharged() -> void:
	if bulletScene == null or tank == null or not is_instance_valid(tank):
		charge = 0.0
		return
	var dmg := damage * clampf(charge / maxf(chargeMax, 0.0001), 0.0, 1.0)
	var b: Node2D = bulletScene.instantiate()
	var pos: Vector2 = tank.getTurretPosition(spawnDistance) \
		if tank.has_method("getTurretPosition") else tank.global_position
	b.global_position = pos
	b.rotation = getAimAngle()
	if b.has_method("setup"):
		b.setup(team, dmg, velocity, life, Color.WHITE, soundAlertRadius)
	if "ownerActor" in b:
		b.ownerActor = tank
	# 命中回调需要知道"是谁打的"（与基类 ATWeapon.spawnBullet 保持一致）
	if "ownerWeapon" in b:
		b.ownerWeapon = self
	for prop in ["impactSfx", "bulletSpark", "bulletPuff"]:
		if prop in b:
			b.set(prop, get(prop))
	var holder: Node = tank.get_parent()
	if holder != null:
		holder.add_child(b)
	if fireSound != null and fireSound.stream != null:
		fireSound.play()
	applyRecoil()
	shot.emit(self)
	charge = 0.0


func stopChargeSfx() -> void:
	if chargingSfx:
		Audio.stopLoop(CHARGE_LOOP_KEY)
		chargingSfx = false


func _physics_process(delta: float) -> void:
	if team != Constants.Team.PLAYER:
		# CPU：按住期间按 rate 自动发射（用 FireTimer 节流）
		if canFire and ammo > 0:
			if fireTimer.is_stopped():
				shoot()
				if rate > 0.0:
					fireTimer.start(1.0 / rate)
		return
	# 玩家蓄力累计
	if canFire and playerCharging:
		if charge < chargeMax:
			charge = minf(charge + delta, chargeMax)
		sparkTimer -= delta
		if sparkTimer <= 0:
			sparkTimer = 0.05
			if tank != null and is_instance_valid(tank):
				var muzzle: Vector2 = tank.getTurretPosition(spawnDistance) \
					if tank.has_method("getTurretPosition") else global_position
				Fx.spark(muzzle, tank.get_parent())
