class_name StateMachine
extends Node
## StateMachine —— 节点式有限状态机（对应 GDQuest FSM 教程的 StateMachine）
##
## 用法（敌人场景 enemy.tscn 根坦克下加子节点）：
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

signal stateChanged(from_name: StringName, to_name: StringName)

## 宿主（可为空；为空时取父节点）。也可用 NodePath 指向场景其它节点
@export var actor: Node2D = null
@export var actorPath: NodePath = NodePath("..")

## 初始状态子节点名（留空 = 自动取第一个 State 子节点）
@export var initialState: StringName = &""

var states: Dictionary = {}            # 状态名(小写) -> State
var currentState: State = null        # 当前状态
var enabled := true                    # 置 false 可整体暂停 AI（如冰冻/死亡）

var lastState: StringName = &""


func _ready() -> void:
	if actor == null:
		if not actorPath.is_empty():
			actor = get_node_or_null(actorPath) as Node2D
		if actor == null:
			actor = get_parent() as Node2D
	# 收集本机所有 State 子节点并注册
	for child in get_children():
		if child is State:
			registerState(child)
	# 决定初始状态：explicit 优先，否则第一个注册的
	if initialState != &"":
		if not states.has(StringName(initialState).to_lower()):
			push_warning("StateMachine %s: initial_state '%s' not found" % [name, initialState])
			initialState = &""
	if initialState == &"":
		for child in get_children():
			if child is State:
				initialState = child.name as StringName
				break
	if initialState != &"":
		transitionTo(initialState)


func registerState(s: State) -> void:
	var key: StringName = StringName(str(s.name).to_lower())
	states[key] = s
	s.stateMachine = self
	s.actor = actor if actor is Node2D else get_parent() as Node2D
	s.stateTime = 0.0


## 切换状态。name 用状态子节点名（大小写不敏感）。
func transitionTo(name_: StringName, msg: Dictionary = {}) -> void:
	var key := StringName(str(name_).to_lower())
	if not states.has(key):
		push_warning("StateMachine %s: no state named '%s'" % [self.name, name_])
		return
	var next: State = states[key]
	if next == currentState:
		# 允许重入（如重新进 Idle 刷新计时）
		if currentState != null:
			currentState.exit()
		next.enter(msg)
		next.stateTime = 0.0
		stateChanged.emit(lastState, name_)
		return
	lastState = currentState.name as StringName if currentState != null else &""
	if currentState != null:
		currentState.exit()
	currentState = next
	next.enter(msg)
	next.stateTime = 0.0
	stateChanged.emit(lastState, name_)


## 供外部（如冻结/解冻系统）强制当前状态处理事件
func sendEvent(methodName: StringName, arg: Variant = null) -> void:
	if currentState != null and currentState.has_method(methodName):
		if arg == null:
			currentState.call(methodName)
		else:
			currentState.call(methodName, arg)


func getCurrentState() -> State:
	return currentState


func _physics_process(delta: float) -> void:
	if not enabled or currentState == null:
		return
	currentState.stateTime += delta
	currentState.physicsUpdate(delta)


func _process(delta: float) -> void:
	if not enabled or currentState == null:
		return
	currentState.processUpdate(delta)


func _unhandled_input(event: InputEvent) -> void:
	if not enabled or currentState == null:
		return
	currentState.handleInput(event)
