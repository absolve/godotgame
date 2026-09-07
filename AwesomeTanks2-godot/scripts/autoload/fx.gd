extends Node
## Fx —— 战斗特效自动加载单例（火花/消散/爆炸/烟雾）
## 供子弹、爆炸、可破坏物体共用：在目标位置生成一次性粒子并自动销毁。

const SCENE_SPARK: PackedScene = preload("res://scenes/fx/spark.tscn")
const SCENE_PUFF: PackedScene = preload("res://scenes/fx/puff.tscn")
const SCENE_EXPLOSION: PackedScene = preload("res://scenes/fx/explosion.tscn")


## 在 pos 生成一个一次性特效；holder 若不传则加在当前场景根（建议传子弹/物体的父节点）
func spawn(pos: Vector2, scene: PackedScene, holder: Node = null) -> void:
	if scene == null:
		return
	if holder == null:
		holder = get_tree().current_scene
	if holder == null:
		return
	var fx: Node2D = scene.instantiate()
	# 先禁发粒子：避免节点默认在 (0,0)=左上角喷一次
	_set_emitting(fx, false)
	holder.add_child(fx)
	fx.global_position = pos
	_set_emitting(fx, true)
	_restart_particles(fx)


func _set_emitting(node: Node, on: bool) -> void:
	for child in node.get_children():
		if child is CPUParticles2D:
			(child as CPUParticles2D).emitting = on
		_set_emitting(child, on)


func _restart_particles(node: Node) -> void:
	for child in node.get_children():
		if child is CPUParticles2D:
			(child as CPUParticles2D).restart()
		_restart_particles(child)


func spark(pos: Vector2, holder: Node = null) -> void:
	spawn(pos, SCENE_SPARK, holder)


func puff(pos: Vector2, holder: Node = null) -> void:
	spawn(pos, SCENE_PUFF, holder)


func explosion(pos: Vector2, holder: Node = null) -> void:
	spawn(pos, SCENE_EXPLOSION, holder)
