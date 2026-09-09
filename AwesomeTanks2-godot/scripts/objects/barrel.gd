extends ATObstacle
## Barrel — 油桶（被击毁时范围爆炸，连锁伤害其它油桶/坦克）
## 对应原项目 window.AT.Barrel

class_name ATBarrel

var explode_radius: float = 90.0
var explode_damage: float = 60.0
var _exploded := false


func _ready() -> void:
	super._ready()
	conducts_current = true  # H5：油桶导电，被 Shock 电到会传导（父类默认 false）
	health = 1.0
	max_health = 1.0


func _die() -> void:
	_explode()


func _explode() -> void:
	if _exploded or not is_inside_tree():
		return
	_exploded = true
	Audio.play_sfx("explosion.mp3")
	Fx.explosion(global_position, get_parent())
	# 范围伤害：坦克 + 其它可破坏物（连锁引爆其它油桶）
	var space := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = explode_radius
	query.shape = shape
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = Constants.layer_mask([
		Constants.Layer.PLAYER, Constants.Layer.ENEMY, Constants.Layer.OBSTACLE,
	])
	for hit in space.intersect_shape(query, 32):
		var obj := hit.get("collider") as Node
		if obj == null or obj == self:
			continue
		if obj.has_method("on_bullet_hit"):
			obj.on_bullet_hit(explode_damage, null, self)
	queue_free()
