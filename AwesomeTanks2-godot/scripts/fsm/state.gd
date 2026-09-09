class_name State
extends Node
## State —— 有限状态机中的单个状态节点（对应 GDQuest FSM 教程的 State）
##
## 使用方式：
##   1) StateMachine 节点的子节点上挂继承本类的脚本（场景里直接加 Node/状态子节点）；
##   2) 由 StateMachine._ready 统一注入 state_machine / actor，并把本类子节点注册进字典；
##   3) 各状态实现 enter()/exit()/physics_update()/process_update()/handle_input()；
##   4) 想切换状态时调用 transition_to("状态节点名", msg)。
##
## GDQuest 设计要点：
##   - 状态自身不持有宿主逻辑，只通过 actor 访问宿主（敌人/玩家）；
##   - 状态变更由 StateMachine 统一管理，State 只声明“我想去哪”；
##   - 输入/物理更新由机器转发给当前状态，避免敌人自己手写 if/else 状态分发。

## 状态机（父场景中 StateMachine 节点注入）
var state_machine: StateMachine = null

## 状态机所属宿主（如 ATTank 敌人；由 state_machine.actor 下发）
var actor: Node2D = null

## 本状态已持续时长（由 StateMachine.physics_update 累计，enter 时清零）
var state_time: float = 0.0


## 进入状态（首次进入或由其它状态切换而来）。msg 可携带切换参数。
func enter(_msg: Dictionary = {}) -> void:
	pass


## 离开状态（切走前调用一次，用于清理子节点/恢复物理属性等）
func exit() -> void:
	pass


## 每物理帧（约 60Hz）更新；仅当本状态是当前状态时被调用
func physics_update(_delta: float) -> void:
	pass


## 每渲染帧更新（可选；大部分 AI 逻辑放 physics_update）
func process_update(_delta: float) -> void:
	pass


## 由 StateMachine 转发 unhandled input（可选）
func handle_input(_event: InputEvent) -> void:
	pass


## 便捷：请求状态机切到其它状态（找不到时由机器告警并忽略）
func transition_to(target_name: StringName, msg: Dictionary = {}) -> void:
	if state_machine != null:
		state_machine.transition_to(target_name, msg)
