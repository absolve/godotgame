extends "res://scripts/enemy.gd"

onready var ani=$ani
var timer=0
var plantOutTime=270
var speed=30
var oldYPos

func _ready():
	debug=true
	active=false
	mask=[constants.mario,constants.fireball]
	rect=Rect2(Vector2(-16,-24),Vector2(32,48))
	type=constants.plant
	status=constants.plantIn
	if spriteIndex==0:
		ani.play("active")
	ani.position.y-=6
	position.x+=offsetX
	position.y+=offsetY
	oldYPos=position.y
	print(oldYPos,":",position.y)
	pass


func startDeathJump(_dir=constants.left):
	destory()

func _update(delta):
	if status==constants.stop:
		pass
	elif status==constants.plantOut:
		yVel=-speed
		if position.y<=oldYPos:
			position.y=oldYPos
		else:
			position.y+=yVel*delta
		
		if timer<plantOutTime:
			timer+=1
		else:
			timer=0
			status=	constants.plantIn
		pass
	elif status==constants.plantIn:
		yVel=speed
		if position.y>=oldYPos+getSizeY()+5:
			position.y=oldYPos+getSizeY()+5
		else:
			position.y+=yVel*delta	
		if timer<plantOutTime:
			timer+=1
		else:
			timer=0
			status=	constants.plantOut		
	pass

func pause():
	status=constants.stop
	ani.stop()

func resume():
	ani.play()	
	
