extends ATTank
## Enemy — 敌人坦克（继承自 ATTank，挂载 AI 状态机）
## 子类：boss / turret(固定) / spawner(生成器) 各自覆盖行为。

class_name ATEnemy

var machine: ATAIMachine = null
var alerted: bool = false
var points: int = 100
var level: Node2D = null            # 指向 Level，用于查询瓦片/玩家

func _ready() -> void:
	super._ready()
	team = Constants.Team.CPU
	machine = ATAIMachine.new(self)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if alive and machine:
		machine.update(delta)

## 巡逻：尝试朝玩家方向移动并开火，返回是否看到玩家
func patrol(_see_player: bool) -> bool:
	# TODO: 视线 raycast + 寻路 + 开火
	return false

## 警戒链：通知附近同伴
func alert_others() -> void:
	if level:
		for e in level.enemies:
			if is_instance_valid(e) and e != self and e.has_method("on_alerted"):
				e.on_alerted(global_position)

func on_alerted(_from_pos: Vector2) -> void:
	if machine:
		machine.on_sound_emitted(_from_pos.x, _from_pos.y)

func on_player_in_sight() -> void:
	if machine:
		machine.on_player_in_sight()

# 供 AI 状态机引用的状态对象
var state_idle = null   # ATAIMachine.ATAIState
var state_goto_player = null
