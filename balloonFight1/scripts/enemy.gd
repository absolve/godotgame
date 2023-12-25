extends "res://scripts/object.gd"

onready var ani=$ani

var status=Constants.enemyOnFloor
var onReadyTime=130
var timer=0
var pumpUpTime=120	#大致120帧后起飞
var target=null #目标
var speedUp=80	#加速
var keepDirectionTime=0	#保持方向时间
var directionTime=0
var keepFlyTime=0	#保持加速时间
var flyTime=0
var flyFlag=false

func _ready():
	randomize()
	type=Constants.enemy
	animation("onFloor")
	dir=Constants.right
	keepDirectionTime = randi()%200+40
	keepFlyTime=randi()%60+10	
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
		if timer<pumpUpTime/4:
			animation('pumpUp_1')
		elif timer<pumpUpTime/2:
			animation('pumpUp_2')
		elif timer<pumpUpTime/3*2:	
			animation('pumpUp_3')
		if timer>pumpUpTime:	#切换到飞行
			timer=0
			ani.position.y-=8
			status=Constants.enemyFly
	elif status==Constants.enemyDead:
		vec.y+=gravity*delta
		vec=move_and_slide(vec,Vector2.UP)
		animation('dead')
	elif status==Constants.enemyFly:
		vec.y+=gravity*delta
		if is_on_floor():
			onFloor=true
		else:
			onFloor=false
		
		if onFloor:
			timer=0
			speedUp=10+randi()%80
		
		timer+=1		
		if timer<speedUp:
			vec.y-=upAccelerate*delta	
		else:
			status=	Constants.enemyIdle	
		animation('fly')	
		vec=move_and_slide(vec,Vector2.UP)
	elif status==Constants.enemyIdle:
		vec.y+=gravity*delta
		if is_on_floor():
			onFloor=true
		else:
			onFloor=false
		if onFloor:
			status=	Constants.enemyFly	
		directionTime+=1
		if directionTime>keepDirectionTime:
			keepDirectionTime=randi()%200+40
			directionTime=0
			var num=randi()%10
			if num>5:
				if dir==Constants.right:
					dir=Constants.left
				else:
					dir=Constants.right	
		if dir==Constants.right:
			if vec.x<moveMaxSpeed:
				vec.x+=accelerate*delta
		else:
			if vec.x>-moveMaxSpeed:
				vec.x-=accelerate*delta
		flyTime+=1
		if flyTime>keepFlyTime:
			flyTime=0
			keepFlyTime=randi()%60+10	
			var num=randf()
			if num<0.6:
				if position.y<size.y:
					flyFlag=false
				else:	
					flyFlag=!flyFlag
		if flyFlag:
			vec.y-=upAccelerate*delta		
			animation('fly')
		else:
			ani.stop()			
		vec=move_and_slide(vec,Vector2.UP)
		
		
	if position.x+size.x/2<0:
		position.x=Game.gameData.width+size.x/2
	if position.x-size.x/2>Game.gameData.width:
		position.x=-size.x/2
	if position.y<size.y/2:
		position.y=size.y/2	
		
func animation(type):
	if type=='onFloor':
		ani.play("onFloor")
	elif type=='fall':
		ani.play("fall")
	elif type=='pumpUp_1':
		ani.play("pump_1")
	elif type=='pumpUp_2':
		ani.play("pump_2")
	elif type=='pumpUp_3':
		ani.play("pump_3")
	elif type=='fly':
		ani.play("fly")
	elif type=='dead':
		ani.play("dead")

	if dir==Constants.left:
		ani.flip_h=true
	else:
		ani.flip_h=false




