extends "res://scripts/enemy.gd"

onready var ani=$ani
var timer=0
var plantOutTime=120
var plantInTime=90
var oldYPos
var preStatus
var ySpeed=35

func _ready():
#	debug=true
	active=false
	mask=[constants.mario,constants.fireball]
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	type=constants.plant
#	status=constants.plantIn
	ani.position.y-=14
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


func hit():
	_dead=true
	destroy=true

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
#					print(abs((m.position.x+m.rect.size.x/2)-(position.x-rect.size.x/2)))
#					print(abs((m.position.x-m.rect.size.x/2)-(position.x+rect.size.x/2)))				
					if m.position.x+m.rect.size.x/2>=position.x-rect.size.x/2-3 &&\
					 m.position.x-m.rect.size.x/2<=position.x+rect.size.x/2+3:
#						print(m.position.y+m.rect.size.y/2)
#						print(position.y-rect.size.y/2)
						if abs((m.position.y+m.rect.size.y/2)-(position.y-rect.size.y/2)) <17:
							if timer>0:
								timer-=15
							
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
	
