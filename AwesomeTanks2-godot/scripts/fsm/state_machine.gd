class_name StateMachine
extends Node
## StateMachine —— 节点式有限状态机（对应 GDQuest FSM 教程的 StateMachine）
##
## 用法（敌人场景 Enemy.tscn 根坦克下加子节点）：
##   [Enemy (ATTank)]
##   └─ [StateMachine (script: state_machine.gd)]     ← 本类
##       ├─ Idle          (script: 敌人状态1.gd, extends State)
##       ├─ GoToPlayer    (script: 敌人状态2.gd, extends State)
##       └─ FollowPlayer  (script: 敌人状态3.gd, extends State)
##
## 约定：
##   - actor：本机控制的宿主（默认 get_parent()，即状态机直接挂在宿主下）。
##     也可用 export actor_path 指向别处。
##   - 初始状态：export initial_state 填状态子节点名；为空则自动选第一个 State 子节点。
##   - State 子节点直接挂在 StateMachine 下（一层），_ready 时注册：
##       状态名(小写) -> State 节点
##   - 每物理帧把 current.physics_update 转发；同时累计 current.state_time；
##     每渲染帧转发 process_update；unhandled input 转发给当前状态。
##   - transition_to(name, msg)：exit 旧状态 → enter 新状态 → 广播 state_changed。
##
## 参考：https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/

signal state_changed(from_name: StringName, to_name: StringName)

## 宿主（可为空；为空时取父节点）。也可用 NodePath 指向场景其它节点
@export var actor: Node2D = null
@export var actor_path: NodePath = NodePath("..")

## 初始状态子节点名（留空 = 自动取第一个 State 子节点）
@export var initial_state: StringName = &""

var states: Dictionary = {}            # 状态名(小写) -> State
var current_state: State = null        # 当前状态
var enabled := true                    # 置 false 可整体暂停 AI（如冰冻/死亡）

var _last_state: StringName = &""


func _ready() -> void:
	if actor == null:
		if not actor_path.is_empty():
			actor = get_node_or_null(actor_path) as Node2D
		if actor == null:
			actor = get_parent() as Node2D
	# 收集本机所有 State 子节点并注册
	for child in get_children():
		if child is State:
			_register_state(child)
	# 决定初始状态：explicit 优先，否则第一个注册的
	if initial_state != &"":
		if not states.has(StringName(initial_state).to_lower()):
			push_warning("StateMachine %s: initial_state '%s' not found" % [name, initial_state])
			initial_state = &""
	if initial_state == &"":
		for child in get_children():
			if child is State:
				initial_state = child.name as StringName
				break
	if initial_state != &"":
		transition_to(initial_state)


func _register_state(s: State) -> void:
	var key: StringName = StringName(str(s.name).to_lower())
	states[key] = s
	s.state_machine = self
	s.actor = actor if actor is Node2D else get_parent() as Node2D
	s.state_time = 0.0


## 切换状态。name 用状态子节点名（大小写不敏感）。
func transition_to(name_: StringName, msg: Dictionary = {}) -> void:
	var key := StringName(str(name_).to_lower())
	if not states.has(key):
		push_warning("StateMachine %s: no state named '%s'" % [self.name, name_])
		return
	var next: State = states[key]
	if next == current_state:
		# 允许重入（如重新进 Idle 刷新计时）
		if current_state != null:
			current_state.exit()
		next.enter(msg)
		next.state_time = 0.0
		state_changed.emit(_last_state, name_)
		return
	_last_state = current_state.name as StringName if current_state != null else &""
	if current_state != null:
		current_state.exit()
	current_state = next
	next.enter(msg)
	next.state_time = 0.0
	state_changed.emit(_last_state, name_)


## 供外部（如冻结/解冻系统）强制当前状态处理事件
func send_event(method_name: StringName, arg: Variant = null) -> void:
	if current_state != null and current_state.has_method(method_name):
		if arg == null:
			current_state.call(method_name)
		else:
			current_state.call(method_name, arg)


func get_current_state() -> State:
	return current_state


func _physics_process(delta: float) -> void:
	if not enabled or current_state == null:
		return
	current_state.state_time += delta
	current_state.physics_update(delta)


func _process(delta: float) -> void:
	if not enabled or current_state == null:
		return
	current_state.process_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if not enabled or current_state == null:
		return
	current_state.handle_input(event)
