## AIStateMachine — 敌人有限状态机（移植自原项目）
## 状态：Idle(巡逻) / GoToSound(调查) / GoToPlayer(追击) / FollowPlayer(A*追击) / Frozen
##
## 用法：tank.machine = AIMachine.new(self) 然后挂载状态对象。
## 每个状态实现 enter/exit/update/on_player_in_sight/on_sound_emitted/on_freeze。

class_name ATAIMachine

var owner: Node2D = null           # 持有该状态机的坦克
var current: ATAIState = null
var time: float = 0.0              # 当前状态已持续时间

func _init(owner_: Node2D) -> void:
	owner = owner_

func change(state: ATAIState) -> void:
	if current:
		current.exit(owner)
	current = state
	current.machine = self
	time = 0.0
	current.enter(owner)

func update(delta: float) -> void:
	time += delta
	if current:
		current.update(owner, delta)

func on_player_in_sight() -> void:
	if current: current.on_player_in_sight(owner)
func on_sound_emitted(x: float, y: float) -> void:
	if current: current.on_sound_emitted(owner, x, y)
func on_freeze() -> void:
	if current: current.on_freeze(owner)
func on_unfreeze() -> void:
	if current and current.has_method("on_unfreeze"):
		current.on_unfreeze(owner)


class ATAIState:
	var machine: ATAIMachine = null
	func enter(_o: Node2D) -> void: pass
	func exit(_o: Node2D) -> void: pass
	func update(_o: Node2D, _delta: float) -> void: pass
	func on_player_in_sight(_o: Node2D) -> void: pass
	func on_sound_emitted(_o: Node2D, _x: float, _y: float) -> void: pass
	func on_freeze(_o: Node2D) -> void: pass


# 示例状态实现（骨架，逻辑待补）
class StateIdle extends ATAIState:
	func on_player_in_sight(_o: Node2D) -> void: machine.change(machine.owner.get("state_goto_player"))
	func on_sound_emitted(_o: Node2D, _x: float, _y: float) -> void: pass

class StateGoToPlayer extends ATAIState:
	func update(_o: Node2D, _delta: float) -> void: pass

class StateFollowPlayer extends ATAIState:
	func update(_o: Node2D, _delta: float) -> void: pass

class StateFrozen extends ATAIState:
	func on_unfreeze(_o: Node2D) -> void: machine.change(machine.owner.get("state_idle"))
