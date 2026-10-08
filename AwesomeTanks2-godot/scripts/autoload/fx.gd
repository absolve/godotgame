extends Node
## Fx —— 战斗特效自动加载单例（火花/消散/爆炸/烟雾）
## 供子弹、爆炸、可破坏物体共用：在目标位置生成一次性粒子并自动销毁。

const SCENE_SPARK: PackedScene = preload("res://scenes/fx/spark.tscn")
const SCENE_SPARK_CYAN: PackedScene = preload("res://scenes/fx/spark_cyan.tscn")
const SCENE_SPARK_RED: PackedScene = preload("res://scenes/fx/spark_red.tscn")
const SCENE_SPARK_BURST: PackedScene = preload("res://scenes/fx/spark_burst.tscn")
const SCENE_STAR: PackedScene = preload("res://scenes/fx/star.tscn")
const SCENE_PUFF: PackedScene = preload("res://scenes/fx/puff.tscn")
const SCENE_EXPLOSION: PackedScene = preload("res://scenes/fx/explosion.tscn")
const SCENE_SMOKE: PackedScene = preload("res://scenes/fx/smoke.tscn")

## 特效名 → 场景。武器场景里的 impactFx / expireFx / trailFx 填这些名字（空字符串 = 不放特效）：
##   每把武器只挑一种命中特效，别在同一个弹上叠好几种
const SCENES: Dictionary = {
	"spark": SCENE_SPARK,
	"sparkCyan": SCENE_SPARK_CYAN,
	"sparkRed": SCENE_SPARK_RED,
	"sparkBurst": SCENE_SPARK_BURST,
	"star": SCENE_STAR,
	"smoke": SCENE_SMOKE,
	"puff": SCENE_PUFF,
	"explosion": SCENE_EXPLOSION,
}


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
	setEmitting(fx, false)
	#holder.call_deferred("add_child",fx)
	holder.add_child(fx)
	fx.global_position = pos
	setEmitting(fx, true)
	restartParticles(fx)


func setEmitting(node: Node, on: bool) -> void:
	for child in node.get_children():
		if child is CPUParticles2D:
			(child as CPUParticles2D).emitting = on
		setEmitting(child, on)


func restartParticles(node: Node) -> void:
	for child in node.get_children():
		if child is CPUParticles2D:
			(child as CPUParticles2D).restart()
		restartParticles(child)


func spark(pos: Vector2, holder: Node = null) -> void:
	spawn(pos, SCENE_SPARK, holder)


## 火花爆发（H5 Railgun 命中点：1 颗星 + 10 个 spark_3、速度 ±100）
func sparkBurst(pos: Vector2, holder: Node = null) -> void:
	spawn(pos, SCENE_SPARK_BURST, holder)


## 命中星（H5 starEmitter 用的 game/particles/star_object.png）：
## 子弹打到墙/物体/敌人身上的"命中标记" —— 原地随机角度、200ms 内 alpha 1→0.05
func star(pos: Vector2, holder: Node = null) -> void:
	spawn(pos, SCENE_STAR, holder)


func puff(pos: Vector2, holder: Node = null) -> void:
	spawn(pos, SCENE_PUFF, holder)


func explosion(pos: Vector2, holder: Node = null) -> void:
	spawn(pos, SCENE_EXPLOSION, holder)


## 烟雾（H5 spawnSmoke）；一次 3 个粒子，火焰撞墙/物体被毁时用
func smoke(pos: Vector2, holder: Node = null) -> void:
	spawn(pos, SCENE_SMOKE, holder)


## 按名字放特效（武器场景里的 impactFx / expireFx 走这里）；名字为空或不认识 = 什么都不放
func spawnNamed(fxName: String, pos: Vector2, holder: Node = null) -> void:
	if fxName == "":
		return
	var scene: PackedScene = SCENES.get(fxName)
	if scene == null:
		push_warning("Fx: 未知特效名 '%s'（可选：%s）" % [fxName, ", ".join(SCENES.keys())])
		return
	spawn(pos, scene, holder)
