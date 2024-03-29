extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus
var xSpeed=30 #基本速度
var timer=0
var throwDelay=240  #每次扔东西的间隔
var throwHideTime=70 #扔完后躲起来的时间
var maxCount=3
var endX= 0 #最后的距离
var marioEndX=false #马里奥超过了最后的位置

var egg=preload("res://scenes/spiny.tscn")

func _ready():
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	type=constants.lakitu
	maxYVel=constants.enemyMaxVel #y轴最大速度
#	debug=true
	ani.position.y-=18
	status=constants.lakituIdle
	pass


func addEgg():
	var count=0
	for i in  Game.getObj().get_children():
		if i.type==constants.spiny:
			count+=1
	if count<=maxCount:
		var temp=egg.instance()
		temp.position.x=position.x
		temp.position.y=position.y
		temp.dir=dir
		temp.yVel=-240
		Game.addObj(temp)
	pass

func pause():
	preStatus=status
	status=constants.stop
	active=false
	ani.stop()

func resume():
	status=preStatus
	ani.play()	
	if status!=constants.dead&&status!=constants.deadJump:
		active=true

func _update(delta):
	if status==constants.lakituIdle:
		if Game.getMario().size()>0:
			var m= Game.getMario()[0]
			if is_instance_valid(m) && m.status!=constants.deadJump:
				if m.position.x>endX:
					xVel=-xSpeed
					marioEndX=true
				else:	
					marioEndX=false
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
								
			if !marioEndX &&position.x+xVel*delta<0:
				dir=constants.right
	
		timer+=1
		if timer>throwDelay:
			timer=0
			if !marioEndX:
				addEgg()
		
		if 	marioEndX:
			animation('idle')
			
		else:	
			if timer>throwDelay-throwHideTime:
				animation('idle')
			else:
				animation('throw')
	elif status==constants.deadJump:
		yVel+=gravity*delta	
		position.y+=yVel*delta	
		pass

func startDeathJump(_dir=constants.left):
	z_index=5
	dir=_dir
	ani.position.y=0
	.startDeathJump()
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	_dead=true
	active=false


func jumpedOn():
	startDeathJump()
	
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
	
