extends ATBullet
## ATShockBolt —— 闪电链（Shock）：命中后自动跳向下一个最近目标，链式多次
## 对应 H5 Shock（targets 数组）；max_jumps 可由武器配置注入。

class_name ATShockBolt

var max_jumps: int = 4
var chain_radius: float = 180.0
var _hit_set: Array = []


func _on_hit(other: Node) -> void:
	if _is_owner(other):
		return
	if other.has_method("on_bullet_hit"):
		var other_team: int = other.team if "team" in other else Constants.Team.CPU
		if other_team != team:
			other.on_bullet_hit(damage, null, self)
			_hit_set.append(other.get_instance_id())
			_chain_to_next()
	queue_free()


func _chain_to_next() -> void:
	if _hit_set.size() >= max_jumps:
		return
	var next = _find_next_target(global_position, chain_radius)
	if next == null:
		return
	_hit_set.append(next.get_instance_id())
	next.on_bullet_hit(damage, null, self)
	_chain_to_next()


func _find_next_target(origin: Vector2, radius: float) -> Node:
	var space := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0.0, origin)
	query.collision_mask = Constants.layer_mask([Constants.Layer.PLAYER, Constants.Layer.ENEMY])
	var best: Node = null
	var best_d: float = radius * radius
	for hit in space.intersect_shape(query, 32):
		var obj := hit.get("collider") as Node
		if obj == null or not obj.has_method("on_bullet_hit"):
			continue
		if _hit_set.has(obj.get_instance_id()):
			continue
		var ot: int = obj.team if "team" in obj else -1
		if ot == team or ot == -1:
			continue
		var d: float = best_d + 1.0
		if obj is Node2D:
			d = (obj.global_position - origin).length_squared()
		if d < best_d:
			best_d = d
			best = obj
	return best
