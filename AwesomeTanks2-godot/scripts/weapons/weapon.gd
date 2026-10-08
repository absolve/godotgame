extends Node2D
## ATWeapon —— 武器基类（场景 + 脚本；scenes/weapons/weapon.tscn）
##
## 基类场景自带节点：
##   FireTimer  —— 开火延迟计时器（每次齐射后 start(1/rate)，倒计时结束才能再开火）
##   FireSound  —— 开火音效节点（fire_sfx 对应的 mp3）
##
## 使用方式（无 start_fire/stop_fire）：
##   外部只需维护 `can_fire`（能否开火，由坦克按输入设置）：
##     - can_fire=true 且 弹药>0 且 定时器就绪 → 立即/循环开火
##     - 有开火延迟(rate>0)用 FireTimer 节流；无延迟(rate<=0)每物理帧直接开火
## 子类武器：各自 .tscn 实例化本基类场景，脚本 extends ATWeapon；
##   需要特殊发射逻辑的在子类里重写 _shoot / _physics_process。

class_name ATWeapon

## 无限弹武器的弹药数值（只是"一个大数"，逻辑一律看 infiniteAmmo，不再比较这个数）
const INFINITE_AMMO := 999999

var tank: Node2D = null
var team: int = Constants.Team.CPU
var id: String = ""

# —— 弹道/伤害参数 ——
## 无限弹标记：装填无限弹的武器（敌人武器全部、玩家的 minigun 等）置 true，
## 有它之后不用再靠"弹药数 >= 999999"去猜（玩家武器在 ATPlayer._setupWeapons 里按存档改成有限）
@export var infiniteAmmo: bool = true
## 弹药数 / 上限（只有有限弹武器使用；无限弹武器不看这两个值）
@export var ammo: int = INFINITE_AMMO
@export var maxAmmo: int = INFINITE_AMMO
@export var damage: float = 10.0
@export var rate: float = 4.0 # 每秒射次（<=0 = 无开火延迟，每帧直接开火/由子类处理）
@export var life: float = 1.0 # 子弹存活时间（秒）
@export var velocity: float = 600.0
@export var spread: float = 0.0
@export var spawnCount: int = 1
## 炮口偏移：从坦克中心沿炮塔朝向前方多少像素出膛（H5 spawnDistance，各武器/敌人场景各自调）
@export var muzzleOffset: float = 20.0
@export var soundAlertRadius: float = 0.0

# —— 炮塔后坐力（H5：开火时 tank.recoil=数值，minigun=3、shotgun/cannon/ricochet/railgun=5）——
@export var recoil := 0.0

# —— 火焰类弹药：命中后点燃目标（H5：目标的 onBulletHit 里判断 instanceof Flamethrower）——
@export var ignites := false

@export var bulletScene: PackedScene = null
#@export var bullet_texture: Texture2D = null

# —— 音效配置 ——
@export var fireSfx := "" # 开火音（经 FireSound 节点播放）
@export var fireStartSfx := "" # 开始持续开火时的单发音
@export var fireLoopSfx := "" # 持续开火循环音
@export var impactSfx := "" # 子弹撞墙/物体音效
## 命中特效（**只有一种**；名字见 Fx.SCENES：spark / sparkCyan / sparkBurst / star / smoke / puff / explosion）
## 每把武器在自己的场景里挑一种；光束武器（laser / shock / railgun）在命中点上也用它；空 = 不放
@export var impactFx := "star"
## 寿命耗尽时的特效（H5 disappearingEmitter 的消散烟）
@export var expireFx := ""
## 飞行拖尾特效（H5 Ricochet 飞行时每帧随机冒火花）；空 = 无拖尾
@export var trailFx := ""
## 拖尾间隔（秒）；H5 是每帧 50% 概率冒 2 个，这里等价成每 0.06s 冒一个
@export var trailInterval := 0.06

# —— 是否允许开火（坦克输入层设置）——
var canFire: bool = true
## 当前是否处于"一次连发"中（用于持续音的启停，见 _begin/_end_fire_session）
var firing: bool = false
## 光束命中点特效的节流（秒，见 tickImpactFx）
var fxTimer: float = 0.0

#var _loop_started := false
#var _fire_start_played := false

signal shot(weapon)
signal outOfAmmo(weapon)

const LOOP_KEY := "weapon_fire"
## 光束武器命中点特效的最小间隔（秒）
const FX_INTERVAL := 0.12

const PRESETS: Dictionary = {
	"minigun": {
		"fireSfx": "minigun.mp3", "impactSfx": "bullet_hit.mp3",
	},
	"shotgun": {
		"fireSfx": "shotgun.mp3", "impactSfx": "bullet_hit.mp3",
	},
	# 反弹弹命中只有 ricochet_bounce.mp3（视觉特效看场景里的 impactFx）
	"ricochet": {
		"fireSfx": "ricochet_shot.mp3",
	},
	"flamethrower": {
		"fireStartSfx": "flame_start.mp3", "fireLoopSfx": "flame_loop.mp3",
	},
	"cannon": {"fireSfx": "cannon.mp3"},
	"shock": {"fireLoopSfx": "shock_loop.mp3"},
	"rockets": {"fireSfx": "rocket.mp3"},
	"railgun": {"fireSfx": "railgun.mp3", "impactSfx": "bullet_hit.mp3"},
}

@onready var fireTimer: Timer = $FireTimer
@onready var fireSound: AudioStreamPlayer = $FireSound


func _ready() -> void:
	if id != "" and PRESETS.has(id):
		var p: Dictionary = PRESETS[id]
		for k in p:
			if k in self:
				set(k, p[k])
	applyFireSound()


## 设置是否开火（坦克按住时每物理帧调用 set_firing(true)，松开调 set_firing(false)）
##   持续音（fire_loop_sfx，如火焰 flame_loop）与起始单发音（fire_start_sfx，如 flame_start）
##   只在"一次连发"的首尾各触发一次，不会每帧重播。
func setFiring(on: bool) -> void:
	if not on:
		endFireSession()
		return
	if not infiniteAmmo and ammo <= 0:
		outOfAmmo.emit(self)
		endFireSession()
		return
	beginFireSession()
	# 有开火延迟：FireTimer 倒计时结束后才允许下一发；无延迟：每帧直接开火
	if rate > 0.0:
		if canFire:
			canFire = false
			shoot()
			fireTimer.start(1.0 / rate)
	else:
		shoot()


## 一次连发开始：播一次起始音 + 起持续循环音（对应 H5 startFire）
func beginFireSession() -> void:
	if firing:
		return
	firing = true
	if fireStartSfx != "":
		Audio.playSfx(fireStartSfx)
	if fireLoopSfx != "":
		Audio.startLoop(loopKey(), fireLoopSfx)


## 一次连发结束：停持续循环音（对应 H5 stopFire）
func endFireSession() -> void:
	if not firing:
		return
	firing = false
	if fireLoopSfx != "":
		Audio.stopLoop(loopKey())


## 循环音键：同种武器共用一条循环音（H5 全局 flame_loop 引用计数同款）
func loopKey() -> String:
	return "weapon_" + (id if id != "" else name)

#func _physics_process(_delta: float) -> void:
	#if not can_fire:
		#_ensure_loop(false)
		#return
	#if ammo <= 0:
		#_ensure_loop(false)
		#out_of_ammo.emit(self)
		#return
	#_ensure_loop(true)
	## 有开火延迟：FireTimer 倒计时结束后才允许下一发；无延迟：每帧直接开火
	#if rate > 0.0:
		#if _fire_timer.is_stopped():
			#_shoot()
			#_fire_timer.start(1.0 / rate)
	#else:
		#_shoot()


#func _ensure_loop(on: bool) -> void:
	#if fire_loop_sfx == "":
		#return
	#if on and not _loop_started:
		#Audio.start_loop(LOOP_KEY, fire_loop_sfx)
		#_loop_started = true
	#elif not on and _loop_started:
		#Audio.stop_loop(LOOP_KEY)
		#_loop_started = false


#func deactivate() -> void:
	#set_firing(false)


func applyParams(p: Dictionary) -> void:
	for key in p:
		if key in self:
			set(key, p[key])
	if "fireSfx" in p:
		applyFireSound()


func hasInfiniteAmmo() -> bool:
	return infiniteAmmo


func applyFireSound() -> void:
	if fireSound == null:
		return
	if fireSfx == "":
		fireSound.stream = null
		return
	var path := "res://sounds/" + fireSfx
	if ResourceLoader.exists(path):
		fireSound.stream = load(path)


## 单次齐射（子类可重写）：按 spawn_count/spread 发射并扣弹
func shoot() -> void:
	var baseAngle := getAimAngle()
	for i in spawnCount:
		var t: float = 0.5 if spawnCount == 1 else float(i) / maxf(float(spawnCount - 1), 1.0)
		var a: float = baseAngle - spread * 0.5 + t * spread if spawnCount > 1 \
			else baseAngle + (randf() * spread - spread * 0.5) if spread > 0.0 else baseAngle
		spawnBullet(a)
	# 开火音（FireSound 节点）
	if fireSfx != "" and fireSound != null and fireSound.stream != null:
		fireSound.play()
	if not infiniteAmmo:
		ammo -= 1
		if ammo <= 0:
			ammo = 0
			#set_firing(false)
			outOfAmmo.emit(self)
	applyRecoil()
	alertNearbyEnemies()
	shot.emit(self)


## 特效挂载点：坦克所在的 ObjectsLayer（拿不到就退回自己的父节点）
func fxHolder() -> Node:
	if tank != null and is_instance_valid(tank) and tank.get_parent() != null:
		return tank.get_parent()
	return get_parent()


## 光束武器命中点的特效（带节流）：光束每帧都命中，不能每帧都生成特效节点
func tickImpactFx(delta: float, pos: Vector2) -> void:
	if impactFx == "":
		return
	fxTimer -= delta
	if fxTimer > 0.0:
		return
	fxTimer = FX_INTERVAL
	Fx.spawnNamed(impactFx, pos, fxHolder())


## 枪声惊动附近敌人（H5：玩家武器的 onShot → level.alertSound；敌人开火不惊动同伴）
func alertNearbyEnemies() -> void:
	if soundAlertRadius <= 0.0 or team != Constants.Team.PLAYER or tank == null \
			or not is_instance_valid(tank):
		return
	var lv = tank.get("level")
	if lv != null and lv.has_method("alertSound"):
		lv.alertSound(tank.global_position, soundAlertRadius)


## 开火后触发炮塔后坐力（供基类 _shoot 与各子类发射逻辑调用）
func applyRecoil() -> void:
	if recoil > 0.0 and tank != null and tank.has_method("applyRecoil"):
		tank.call("applyRecoil", recoil)


func getAimAngle() -> float:
	if tank == null:
		return 0.0
	if "turretSprite" in tank:
		var ts = tank.get("turretSprite")
		if ts != null:
			return ts.rotation
	return tank.rotation


## 在炮口角度 a 生成一发子弹（子类可重写/改用其它发射方式）
func spawnBullet(angle: float) -> Node2D:
	if bulletScene == null or tank == null or not is_instance_valid(tank):
		return null
	var b: Node2D = bulletScene.instantiate()
	var pos: Vector2 = tank.getTurretPosition(muzzleOffset) \
		if tank.has_method("getTurretPosition") else tank.global_position
	b.global_position = pos
	b.rotation = angle
	#if bullet_texture != null and b.has_node("Sprite2D"):
		#(b.get_node("Sprite2D") as Sprite2D).texture = bullet_texture
	if b.has_method("setup"):
		b.setup(team, damage, velocity, life, Color.WHITE, soundAlertRadius)
	if "ownerActor" in b:
		b.ownerActor = tank
	# 命中回调需要知道"是谁打的"（H5 用 srcWeapon instanceof 判断火焰/激光等）
	if "ownerWeapon" in b:
		b.ownerWeapon = self
	for prop in ["impactSfx", "impactFx", "expireFx", "trailFx", "trailInterval"]:
		if prop in b:
			b.set(prop, get(prop))
	var holder: Node = tank.get_parent()
	if holder != null:
		holder.add_child(b)
	return b


func onFireTimerTimeout() -> void:
	canFire = true


func _exit_tree() -> void:
	# 节点被释放时释放循环音引用，避免留下停不掉的持续音
	if not firing:
		return
	firing = false
	if fireLoopSfx == "":
		return
	var audio := get_node_or_null("/root/Audio")
	if audio != null:
		audio.call("stopLoop", loopKey())
