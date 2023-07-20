extends "res://scripts/object.gd"

onready var ani=$ani

var status=Constants.enemyOnFloor
var onReadyTime=130
var timer=0
var pumpUpTime=120	#大致120帧后起飞

func _ready():
	type=Constants.enemy
	
	
	pass


func _physics_process(delta):
	if status==Constants.enemyOnFloor:
		timer+=1
		if timer>onReadyTime:
			status=Constants.enemyPumpUp
			timer=0
	elif status==Constants.enemyFall:
		vec.y+=gravity*delta
		vec=move_and_slide(vec,Vector2.UP)
	elif status==Constants.enemyPumpUp:#打气
		timer+=1
		if timer>pumpUpTime:
			timer=0
			status=Constants.enemyFly
	elif status==Constants.enemyDead:
		vec.y+=gravity*delta
		vec=move_and_slide(vec,Vector2.UP)
	elif status==Constants.enemyFly:
		vec.y+=gravity*delta
		
		vec=move_and_slide(vec,Vector2.UP)

		
func animation(type):
	
	pass
