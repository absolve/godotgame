extends ATWeapon
## ricochet 武器脚本 —— 玩家版“蓄力发射”（对应 H5 Ricochet，awesome_tanks_2.js L21496~21556）
##
## 玩家：按住蓄力（消耗 1 发弹药，charge 1 秒蓄满，带 ricochet_start/loop 音效与炮口火花），
##       松开时发射 1 发反弹弹，伤害 = 基础伤害 × charge（蓄满 = 全额）。
## CPU：敌方 ricochet 保持“按住持续按 rate 自动开火”（本脚本自管理，不依赖基类节流）。
## 本脚本不依赖基类的 can_fire 触发怪癖，开火节奏在此独立实现。

class_name ATWeaponRicochet

@export var charge_max: float = 1.0

var charge: float = 0.0
var _player_charging := false   # 玩家蓄力状态（不依赖基类 can_fire 默认值）
var _charging_sfx := false
var _spark_timer := 0.0

const CHARGE_LOOP_KEY := "ricochet_charge"


func _ready() -> void:
	super._ready()
	if id == "":
		id = "ricochet"


func set_firing(on: bool) -> void:
	if team == Constants.Team.PLAYER:
		_set_player_firing(on)
	else:
		can_fire = on


## 玩家：按下开始蓄力/松开发射
func _set_player_firing(on: bool) -> void:
	if on:
		if _player_charging:
			return            # 正在蓄力
		if ammo <= 0:
			out_of_ammo.emit(self)
			return
		if ammo < 999999:
			ammo -= 1         # 蓄力预留 1 发（H5：蓄力过程消耗弹药）
		_player_charging = true
		can_fire = true
		Audio.play_sfx("ricochet_start.mp3")
		Audio.start_loop(CHARGE_LOOP_KEY, "ricochet_loop.mp3")
		_charging_sfx = true
	else:
		if not _player_charging:
			return
		_player_charging = false
		can_fire = false
		_stop_charge_sfx()
		if charge > 0.0:
			_fire_charged()


func _physics_process(delta: float) -> void:
	if team != Constants.Team.PLAYER:
		# CPU：按住期间按 rate 自动发射（用 FireTimer 节流）
		if can_fire and ammo > 0:
			if _fire_timer.is_stopped():
				_shoot()
				if rate > 0.0:
					_fire_timer.start(1.0 / rate)
		return
	# 玩家蓄力累计
	if can_fire and _player_charging:
		if charge < charge_max:
			charge = minf(charge + delta, charge_max)
		_spark_timer -= delta
		if _spark_timer <= 0:
			_spark_timer = 0.05
			if tank != null and is_instance_valid(tank):
				var muzzle: Vector2 = tank.get_turret_position(spawn_distance) \
					if tank.has_method("get_turret_position") else global_position
				Fx.spark(muzzle, tank.get_parent())


func _fire_charged() -> void:
	if bullet_scene == null or tank == null or not is_instance_valid(tank):
		charge = 0.0
		return
	var dmg := damage * clampf(charge / maxf(charge_max, 0.0001), 0.0, 1.0)
	var b: Node2D = bullet_scene.instantiate()
	var pos: Vector2 = tank.get_turret_position(spawn_distance) \
		if tank.has_method("get_turret_position") else tank.global_position
	b.global_position = pos
	b.rotation = _get_aim_angle()
	if bullet_texture != null and b.has_node("Sprite2D"):
		(b.get_node("Sprite2D") as Sprite2D).texture = bullet_texture
	if b.has_method("setup"):
		b.setup(team, dmg, velocity, life, Color.WHITE, sound_alert_radius)
	if "owner_actor" in b:
		b.owner_actor = tank
	for prop in ["impact_sfx", "bullet_spark", "bullet_puff"]:
		if prop in b:
			b.set(prop, get(prop))
	var holder: Node = tank.get_parent()
	if holder != null:
		holder.add_child(b)
	if _fire_sound != null and _fire_sound.stream != null:
		_fire_sound.play()
	shot.emit(self)
	charge = 0.0


func _stop_charge_sfx() -> void:
	if _charging_sfx:
		Audio.stop_loop(CHARGE_LOOP_KEY)
		_charging_sfx = false
