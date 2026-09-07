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

var tank: Node2D = null
var team: int = Constants.Team.CPU
var id: String = ""

# —— 弹道/伤害参数 ——
@export var ammo: int = 999999 # 弹药（>=999999 视为无限）
@export var max_ammo: int = 999999
@export var damage: float = 10.0
@export var rate: float = 4.0 # 每秒射次（<=0 = 无开火延迟，每帧直接开火/由子类处理）
@export var life: float = 1.0 # 子弹存活时间（秒）
@export var velocity: float = 600.0
@export var spread: float = 0.0
@export var spawn_count: int = 1
@export var spawn_distance: float = 20.0
@export var sound_alert_radius: float = 0.0

@export var bullet_scene: PackedScene = null
@export var bullet_texture: Texture2D = null

# —— 音效配置 ——
@export var fire_sfx := "" # 开火音（经 FireSound 节点播放）
@export var fire_start_sfx := "" # 开始持续开火时的单发音
@export var fire_loop_sfx := "" # 持续开火循环音
@export var impact_sfx := "" # 子弹撞墙/物体音效
@export var bullet_spark := true
@export var bullet_puff := false

# —— 是否允许开火（坦克输入层设置）——
var can_fire: bool = true

var _loop_started := false
var _fire_start_played := false

signal shot(weapon)
signal out_of_ammo(weapon)

const LOOP_KEY := "weapon_fire"

const PRESETS: Dictionary = {
	"minigun": {
		"fire_sfx": "minigun.mp3", "impact_sfx": "bullet_hit.mp3",
		"bullet_spark": true, "bullet_puff": true,
	},
	"shotgun": {
		"fire_sfx": "shotgun.mp3", "impact_sfx": "bullet_hit.mp3",
	},
	"ricochet": {
		"fire_sfx": "ricochet_shot.mp3", "impact_sfx": "bullet_hit.mp3",
	},
	"flamethrower": {
		"fire_start_sfx": "flame_start.mp3", "fire_loop_sfx": "flame_loop.mp3",
	},
	"cannon": {"fire_sfx": "cannon.mp3"},
	"shock": {"fire_loop_sfx": "shock_loop.mp3"},
	"rockets": {"fire_sfx": "rocket.mp3"},
	"railgun": {"fire_sfx": "railgun.mp3", "impact_sfx": "bullet_hit.mp3"},
}

@onready var _fire_timer: Timer = $FireTimer
@onready var _fire_sound: AudioStreamPlayer = $FireSound


func _ready() -> void:
	if id != "" and PRESETS.has(id):
		var p: Dictionary = PRESETS[id]
		for k in p:
			if k in self:
				set(k, p[k])
	_apply_fire_sound()


## 设置是否允许开火；true 时有延迟走定时器、无延迟直接开火
func set_firing(_on: bool) -> void:
	#if can_fire == on:
		#return
	#can_fire = on
	#if not on:
		#_fire_start_played = false
		##_ensure_loop(false)
	#elif fire_start_sfx != "" and ammo > 0:
		#Audio.play_sfx(fire_start_sfx)
	if not _on:
		return
	if ammo <= 0:
		#_ensure_loop(false)
		out_of_ammo.emit(self)
		return
	#_ensure_loop(true)
	# 有开火延迟：FireTimer 倒计时结束后才允许下一发；无延迟：每帧直接开火
	if rate > 0.0:
		if can_fire:
			can_fire = false
			_shoot()
			_fire_timer.start(1.0 / rate)
	else:
		_shoot()

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


func apply_params(p: Dictionary) -> void:
	for key in p:
		if key in self:
			set(key, p[key])
	if "fire_sfx" in p:
		_apply_fire_sound()


func has_infinite_ammo() -> bool:
	return max_ammo >= 999999


func _apply_fire_sound() -> void:
	if _fire_sound == null:
		return
	if fire_sfx == "":
		_fire_sound.stream = null
		return
	var path := "res://sounds/" + fire_sfx
	if ResourceLoader.exists(path):
		_fire_sound.stream = load(path)


## 单次齐射（子类可重写）：按 spawn_count/spread 发射并扣弹
func _shoot() -> void:
	var base_angle := _get_aim_angle()
	for i in spawn_count:
		var t: float = 0.5 if spawn_count == 1 else float(i) / maxf(float(spawn_count - 1), 1.0)
		var a: float = base_angle - spread * 0.5 + t * spread if spawn_count > 1 \
			else base_angle + (randf() * spread - spread * 0.5) if spread > 0.0 else base_angle
		_spawn_bullet(a)
	# 开火音（FireSound 节点）
	if fire_sfx != "" and _fire_sound != null and _fire_sound.stream != null:
		_fire_sound.play()
	if ammo < 999999:
		ammo -= 1
		if ammo <= 0:
			ammo = 0
			#set_firing(false)
			out_of_ammo.emit(self)
	shot.emit(self)


func _get_aim_angle() -> float:
	if tank == null:
		return 0.0
	if "_turret_sprite" in tank:
		var ts = tank.get("_turret_sprite")
		if ts != null:
			return ts.rotation
	return tank.rotation


## 在炮口角度 a 生成一发子弹（子类可重写/改用其它发射方式）
func _spawn_bullet(angle: float) -> Node2D:
	if bullet_scene == null or tank == null or not is_instance_valid(tank):
		return null
	var b: Node2D = bullet_scene.instantiate()
	var pos: Vector2 = tank.get_turret_position(spawn_distance) \
		if tank.has_method("get_turret_position") else tank.global_position
	b.global_position = pos
	b.rotation = angle
	if bullet_texture != null and b.has_node("Sprite2D"):
		(b.get_node("Sprite2D") as Sprite2D).texture = bullet_texture
	if b.has_method("setup"):
		b.setup(team, damage, velocity, life, Color.WHITE, sound_alert_radius)
	if "owner_actor" in b:
		b.owner_actor = tank
	for prop in ["impact_sfx", "bullet_spark", "bullet_puff"]:
		if prop in b:
			b.set(prop, get(prop))
	var holder: Node = tank.get_parent()
	if holder != null:
		holder.add_child(b)
	return b


func _on_fire_timer_timeout() -> void:
	can_fire = true
