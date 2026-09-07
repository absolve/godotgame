extends ATTank
## Enemy — 敌人坦克（继承自 ATTank，挂载 AI 状态机）
## 视觉：车体 <type>_body_0/1 履带动画、炮塔 <type>.png（单帧 default 动画）。
## tank_key 可在子类(Boss/特殊敌人) _init 里改成对应前缀。

class_name ATEnemy

var machine: ATAIMachine = null
var alerted: bool = false
var points: int = 100
var level: Node2D = null            # 指向 Level，用于查询瓦片/玩家
var tank_key: String = "minigun"    # 对应 game/tanks/<tank_key>[_body_0/1].png


func _ready() -> void:
	super._ready()
	team = Constants.Team.CPU
	_configure_enemy_visuals()
	machine = ATAIMachine.new(self)


func _configure_enemy_visuals() -> void:
	var base := "res://sprites/game/tanks/" + tank_key
	configure_body_animation([base + "_body_0.png.tres", base + "_body_1.png.tres"])
	configure_turret_frames({ "default": [base + ".png.tres"] })
	switch_turret("default")


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
