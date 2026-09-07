extends Area2D
## ATBullet —— 通用子弹（对应 H5 Phaser.Sprite 子弹）
## 设计：每种“行为”一颗子弹 = 独立场景（scenes/projectiles/*.tscn），
## 根节点 Area2D + 脚本 + CollisionShape2D(触发) + Sprite2D(贴图)。
## 由武器下发命中表现参数：
##   impact_sfx / bullet_spark / bullet_puff ——
##   - 命中墙/物体/敌人 → 火花 + 命中音（H5 spawnSparks + bullet_hit）
##   - 寿命耗尽 → 消散烟（H5 disappearingEmitter）
## 子类覆写 _on_hit/_die 实现反弹/穿透/爆炸/连锁。

class_name ATBullet

var team: int = Constants.Team.CPU
var damage: float = 10.0
var speed: float = 600.0
var life: float = 1.0
var hit_color: Color = Color.WHITE
var sound_alert_radius: float = 0.0
var owner_actor: Node = null      # 布设者（射击坦克），避免自撞

# —— 由武器下发（见 ATWeapon._spawn_bullet）——
var impact_sfx := ""
var bullet_spark := true          # 命中时爆火花
var bullet_puff := false          # 寿命耗尽时冒消散烟

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite


func _ready() -> void:
	collision_layer = 1 << (Constants.Layer.PROJECTILE - 1)
	collision_mask = Constants.layer_mask([
		Constants.Layer.WALL, Constants.Layer.OBSTACLE,
		Constants.Layer.PLAYER, Constants.Layer.ENEMY,
	])
	body_entered.connect(_on_hit)
	# 贴图/动画由派生子弹场景的 SpriteFrames 提供，自动播第一个动画
	if _sprite != null and _sprite.sprite_frames != null \
			and _sprite.sprite_frames.get_animation_names().size() > 0:
		_sprite.play(_sprite.sprite_frames.get_animation_names()[0])


func setup(team_: int, damage_: float, speed_: float, life_: float, color_: Color, alert_: float) -> void:
	team = team_
	damage = damage_
	speed = speed_
	life = life_
	hit_color = color_
	sound_alert_radius = alert_


## 运行时替换贴图（已废弃：贴图由派生子弹场景直接设置）
func set_bullet_texture(_tex: Texture2D) -> void:
	pass


func _physics_process(delta: float) -> void:
	life -= delta
	if life <= 0:
		_die(false)
		return
	global_position += Vector2.RIGHT.rotated(rotation) * speed * delta


func _on_hit(other: Node) -> void:
	if _is_owner(other):
		return
	if other.has_method("on_bullet_hit"):
		var other_team: int = other.team if "team" in other else Constants.Team.CPU
		if other_team != team:
			other.on_bullet_hit(damage, null, self)
	_die(true)


## 是否是布设者自身（生成瞬间贴脸时会先碰撞到自己）
func _is_owner(other: Node) -> bool:
	return owner_actor != null and other == owner_actor


func _die(hit_something: bool) -> void:
	if not is_inside_tree():
		return
	if hit_something:
		_on_contact_effects()
	elif bullet_puff:
		Fx.puff(global_position, get_parent())
	queue_free()


## 命中任何东西：火花 + 命中音（H5 spawnSparks + bullet_hit.mp3）
func _on_contact_effects() -> void:
	if not is_inside_tree():
		return
	if bullet_spark:
		Fx.spark(global_position, get_parent())
	if impact_sfx != "":
		Audio.play_sfx(impact_sfx)


## 半径爆炸/范围伤害 + 爆炸特效（供 cannon/rocket/mine 复用）
static func explode(owner: Node2D, origin: Vector2, radius: float, dmg: float, my_team: int) -> void:
	Audio.play_sfx("explosion.mp3")
	Fx.explosion(origin, owner.get_parent())
	damage_in_radius(owner, origin, radius, dmg, my_team)


## 半径爆炸/范围伤害（仅伤害，不播特效）
static func damage_in_radius(owner: Node2D, origin: Vector2, radius: float, dmg: float, my_team: int) -> void:
	var space := owner.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0.0, origin)
	query.collision_mask = Constants.layer_mask([Constants.Layer.PLAYER, Constants.Layer.ENEMY])
	for hit in space.intersect_shape(query, 32):
		var obj := hit.get("collider") as Node
		if obj == null or obj == owner:
			continue
		if obj.has_method("on_bullet_hit"):
			var ot: int = obj.team if "team" in obj else -1
			if ot != my_team and ot != -1:
				obj.on_bullet_hit(dmg, null, owner)
