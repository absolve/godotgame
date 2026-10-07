extends Area2D
## ATBullet —— 通用子弹（对应 H5 Phaser.Sprite 子弹）
## 设计：每种“行为”一颗子弹 = 独立场景（scenes/projectiles/*.tscn），
## 根节点 Area2D + 脚本 + CollisionShape2D(触发) + Sprite2D(贴图)。
## 由武器下发命中表现参数（见 ATWeapon.spawnBullet）：
##   impactSfx / bulletSpark / bulletStar / bulletPuff ——
##   - 命中墙/物体/敌人 → 命中星（H5 基类 starEmitter）+ 火花（H5 Minigun/Shotgun spawnSparks）+ 命中音
##   - 寿命耗尽 → 消散烟（H5 disappearingEmitter）
## 子类覆写 onHit/die 实现反弹/穿透/爆炸/连锁。

class_name ATBullet

var team: int = Constants.Team.CPU
var damage: float = 10.0
var speed: float = 600.0
var life: float = 1.0
var hitColor: Color = Color.WHITE
var soundAlertRadius: float = 0.0
var ownerActor: Node = null      # 布设者（射击坦克），避免自撞
var ownerWeapon: Node = null     # 发射它的武器（命中回调要用来判断火焰/激光等特性）

# —— 由武器下发（见 ATWeapon.spawnBullet）——
var impactSfx := ""
var bulletSpark := true          # 命中时爆火花（H5 Minigun/Shotgun 的 spawnSparks，1 个）
var bulletStar := true           # 命中时冒"命中星"（H5 基类 onBulletHitWall 的 starEmitter）
var bulletPuff := false          # 寿命耗尽时冒消散烟

@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite") as AnimatedSprite2D


func _ready() -> void:
	collision_layer = 1 << (Constants.Layer.PROJECTILE - 1)
	collision_mask = Constants.layerMask([
		Constants.Layer.WALL, Constants.Layer.OBSTACLE,
		Constants.Layer.PLAYER, Constants.Layer.ENEMY, Constants.Layer.ENEMY_SPAWNER,
	])
	body_entered.connect(onHit)
	# 贴图/动画由派生子弹场景的 SpriteFrames 提供，自动播第一个动画
	if sprite != null and sprite.sprite_frames != null \
			and sprite.sprite_frames.get_animation_names().size() > 0:
		sprite.play(sprite.sprite_frames.get_animation_names()[0])


func setup(team_: int, damage_: float, speed_: float, life_: float, color_: Color, alert_: float) -> void:
	team = team_
	damage = damage_
	speed = speed_
	life = life_
	hitColor = color_
	soundAlertRadius = alert_


## 运行时替换贴图（已废弃：贴图由派生子弹场景直接设置）
func setBulletTexture(tex: Texture2D) -> void:
	pass


func onHit(other: Node) -> void:
	if isOwner(other):
		return
	if other.has_method("onBulletHit"):
		var otherTeam: int = other.team if "team" in other else Constants.Team.CPU
		if otherTeam != team:
			# 发射者在子弹飞行途中可能已经被销毁（坦克被击毁 → 它的武器子节点一起释放，
			# 而子弹挂在 ObjectsLayer 上还活着）。这里必须传 null 而不是"已释放的对象"，
			# 否则受击方的 on_bullet_hit(src: Node) 形参会报 "previously freed is not a subclass"。
			other.onBulletHit(damage, ownerWeapon if is_instance_valid(ownerWeapon) else null, self)
	die(true)


## 是否是布设者自身（生成瞬间贴脸时会先碰撞到自己）
func isOwner(other: Node) -> bool:
	return is_instance_valid(ownerActor) and other == ownerActor


func die(hitSomething: bool) -> void:
	if not is_inside_tree():
		return
	if hitSomething:
		onContactEffects()
	elif bulletPuff:
		Fx.puff(global_position, get_parent())
	queue_free()


## 命中任何东西的表现（H5 每种子弹的击中效果都不一样，这里按武器下发的参数走）：
##   - 命中星：H5 基类 onBulletHitWall 的 starEmitter（打在墙/物体/敌人身上都冒一颗）
##   - 火花：H5 Minigun/Shotgun 的 spawnSparks(x, y, 0, 2π, 100, 1)
##   - 音效：impactSfx（Minigun/Shotgun = bullet_hit.mp3；火焰为空）
##   - 警报：H5 命中时也会 alertSound(命中点, soundAlertRadius)，惊动附近敌人来调查
func onContactEffects() -> void:
	if not is_inside_tree():
		return
	if bulletStar:
		Fx.star(global_position, get_parent())
	if bulletSpark:
		Fx.spark(global_position, get_parent())
	if impactSfx != "":
		Audio.playSfx(impactSfx)
	alertOnHit()


## H5 onBulletHitWall：this.soundAlertRadius && level.alertSound(x, y, radius)
func alertOnHit() -> void:
	if soundAlertRadius <= 0.0 or not is_instance_valid(ownerActor):
		return
	var lv = ownerActor.get("level") if "level" in ownerActor else null
	if lv != null and lv.has_method("alertSound"):
		lv.alertSound(global_position, soundAlertRadius)


## 半径爆炸/范围伤害 + 爆炸特效（供 cannon/rocket/mine 复用）
static func explodeAt(owner: Node2D, origin: Vector2, radius: float, dmg: float, myTeam: int) -> void:
	Audio.playSfx("explosion.mp3")
	Fx.explosion(origin, owner.get_parent())
	damageInRadius(owner, origin, radius, dmg, myTeam)


## 半径爆炸/范围伤害（仅伤害，不播特效）
static func damageInRadius(owner: Node2D, origin: Vector2, radius: float, dmg: float, myTeam: int) -> void:
	var space := owner.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0.0, origin)
	# H5 Explosion.damageObject：玩家 / 障碍物 / 生成器 / 敌人都吃爆炸伤害
	query.collision_mask = Constants.layerMask([
		Constants.Layer.PLAYER, Constants.Layer.ENEMY,
		Constants.Layer.OBSTACLE, Constants.Layer.ENEMY_SPAWNER,
	])
	for hit in space.intersect_shape(query, 32):
		var obj := hit.get("collider") as Node
		if obj == null or obj == owner:
			continue
		if not obj.has_method("onBulletHit"):
			continue
		# 有队伍属性的单位不打同队；没有队伍属性的（障碍物）一律可打（H5 同款）
		if "team" in obj and int(obj.team) == myTeam:
			continue
		obj.onBulletHit(dmg, null, owner)


func _physics_process(delta: float) -> void:
	life -= delta
	if life <= 0:
		die(false)
		return
	global_position += Vector2.RIGHT.rotated(rotation) * speed * delta
