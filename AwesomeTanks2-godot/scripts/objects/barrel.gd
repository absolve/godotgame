extends ATObstacle
## Barrel — 油桶（被击毁时范围爆炸，连锁伤害其它油桶/坦克）
## 对应原项目 window.AT.Barrel

class_name ATBarrel

var explodeRadius: float = 90.0
var explodeDamage: float = 60.0
var exploded := false


func _ready() -> void:
	super._ready()
	conductsCurrent = true  # H5：油桶导电，被 Shock 电到会传导（父类默认 false）
	# 血量由父类按关卡序号给定（H5 Barrel: setHealth(25 + 4 * level.index)）


func die() -> void:
	explode()


func explode() -> void:
	if exploded or not is_inside_tree():
		return
	exploded = true
	Audio.playSfx("explosion.mp3")
	Fx.explosion(global_position, get_parent())
	# 范围伤害：坦克 + 其它可破坏物（连锁引爆其它油桶）
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = explodeRadius
	query.shape = shape
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = Constants.layerMask([
		Constants.Layer.PLAYER, Constants.Layer.ENEMY, Constants.Layer.OBSTACLE,
	])
	for hit in space.intersect_shape(query, 10):
		var obj := hit.get("collider") as Node
		if obj == null or obj == self:
			continue
		if obj.has_method("onBulletHit"):
			obj.onBulletHit(explodeDamage, null, self)
	queue_free()
