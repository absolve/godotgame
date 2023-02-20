extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus
var xSpeed=30 #基本速度
var timer=0
var throwDelay=240  #每次扔东西的间隔
var throwHideTime=70 #扔完后躲起来的时间
var maxCount=3

var egg=preload("res://scenes/spiny.tscn")

func _ready():
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	type=constants.lakitu
	maxYVel=constants.enemyMaxVel #y轴最大速度
	debug=true
	ani.position.y-=18
	status=constants.lakituIdle
	pass


func addEgg():
	var count=0
	for i in  Game.getObj():
		if i.type==constants.spiny:
			count+=1
	if count<maxCount:
		var temp=egg.instance()
		temp.position.x=position.x
		temp.position.y=position.y
		temp.dir=dir
		temp.yVel=-200
		Game.addObj(temp)
	pass


func _update(delta):
	if status==constants.lakituIdle:
		timer+=1
		if timer>throwDelay:
			timer=0
			addEgg()
			
		if timer>throwDelay-throwHideTime:
			animation('idle')
		else:
			animation('throw')
		
		if Game.getMario().size()>0:
			var m= Game.getMario()[0]
			if m.status!=constants.deadJump:
				var distance=m.position.x-position.x
				if distance<0:
					if abs(distance)>constants.lakituDistance:
						if dir==constants.left:
							if m.xVel<0:
								xVel=-max(xSpeed,abs(m.xVel))
							else:
								xVel=-xSpeed
						elif dir==constants.right:
							dir=constants.left					
					else:
						if dir==constants.right:
							xVel=xSpeed
						elif dir==constants.left:
							xVel=-xSpeed
				elif distance>0:
					if abs(distance)>constants.lakituDistance:
						if dir==constants.right:
							if  m.xVel>0:
								xVel=max(xSpeed,abs(m.xVel))
							else:
								xVel=xSpeed
						elif dir==constants.left:
							dir=constants.right	
					else:
						if dir==constants.right:
							xVel=xSpeed
						elif dir==constants.left:
							xVel=-xSpeed
								
			if position.x+xVel*delta<0:
				dir=constants.right
	elif status==constants.deadJump:
		yVel+=gravity*delta	
		position.y+=yVel*delta	
		pass

func startDeathJump(_dir=constants.left):
	status=constants.deadJump
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	active=false
	_dead=true
	gravity=constants.deathJumpGravity
	z_index=5
	
func animation(type):
	if type=='idle':
		if spriteIndex==0:
			ani.play("idle_0")
		elif spriteIndex==1:
			ani.play("idle_1")	
		elif spriteIndex==2:	
			ani.play("idle_2")	
	elif type=='throw':
		if spriteIndex==0:
			ani.play("throw_0")
		elif spriteIndex==1:
			ani.play("throw_1")	
		elif spriteIndex==2:	
			ani.play("throw_2")	
	if dir==constants.left:
		ani.flip_h=false
	else:
		ani.flip_h=true		
				
	pass	
	
