extends "res://scripts/enemy.gd"

onready var ani=$ani
var timer=0
var plantOutTime=200
var plantInTime=100
var oldYPos
var preStatus
var ySpeed=35

func _ready():
	debug=true
	active=false
	mask=[constants.mario,constants.fireball]
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	type=constants.plant
#	status=constants.plantIn
	ani.position.y-=16
	if spriteIndex==0:
		ani.play("0")
	elif spriteIndex==1:	
		ani.play("1")
	elif spriteIndex==2:	
		ani.play("2")
	elif spriteIndex==3:
		ani.play("3")

	position.x+=offsetX
	position.y+=offsetY
	oldYPos=position.y

	status=constants.plantIn
	position.y+=48
	print(oldYPos,":",position.y)
	pass


func startDeathJump(_dir=constants.left):
	
	pass

func _update(delta):
	if status==constants.plantOut:
		if position.y>oldYPos:
			yVel=-ySpeed
		else:
			yVel=0
			timer+=1
			if timer>plantOutTime:
				timer=0
				status=	constants.plantIn
		position.y+=yVel*delta
		pass
	elif status==constants.plantIn:
		if position.y<oldYPos+48:
			yVel=ySpeed
		else:  	#准备出来的时候判断是不是有马里奥
			yVel=0
			timer+=1
			if Game.getMario().size()>0:
				var m= Game.getMario()[0]
				if m.status!=constants.deadJump:
					if abs((m.position.x+m.rect.size.x/2)-(position.x-rect.size.x/2)) <4 &&\
					abs((m.position.x-m.rect.size.x/2)-(position.x+rect.size.x/2)) <4:
						if abs((m.position.y+m.rect.size.y/2)-(position.y-rect.size.y/2)) <4:
							timer-=20
			if timer>plantInTime:
				timer=0
				status=	constants.plantOut
				
				
						
		position.y+=yVel*delta

func pause():
	preStatus=status
	status=constants.stop
	ani.stop()

func resume():
	status=preStatus
	ani.play()	
	
