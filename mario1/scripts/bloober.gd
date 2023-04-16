extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus
var ySpeed=10
var xSpeed=40
var lastXPos=0 #上次准备移动时x位置
var lastYPos=0 #上次下降y的位置
var downSpeed=30 #自由下降的速度
var winHeight

func _ready():
	type=constants.bloober
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	maxYVel=constants.blooberMaxYSpeed #y轴最大速度
	maxXVel=constants.blooberMaxXSpeed
	gravity=0
#	debug=true
	status=constants.idle
	winHeight=get_viewport_rect().size.y
	pass

func _update(delta):
	if status==constants.deadJump:
		yVel=50
		position.y+=yVel*delta
	elif status==constants.upward:
		if dir==constants.left:
			if xVel<-maxXVel:
				xVel=-maxXVel
			else:
				xVel+=-constants.blooberAcceleration*delta	
		elif dir==constants.right:
			if xVel>maxXVel:
				xVel=maxXVel
			else:
				xVel+=constants.blooberAcceleration*delta	
		
		if yVel<-maxYVel:
			yVel=-maxYVel
		else:
			yVel+=-constants.blooberAcceleration*delta		
			
		animation('rise')	
		if abs(position.x-lastXPos)>32*2:
			status=constants.downward
			xVel=0
			lastYPos=position.y
			animation('down')	
	elif status==constants.downward:
		yVel=downSpeed
		if abs(position.y-lastYPos)>32:
			status=constants.idle
			animation('rise')
#		animation('down')
		pass	
	elif status==constants.idle:
		yVel=downSpeed
		if Game.getMario().size()>0:
			var m= Game.getMario()[0]
			if is_instance_valid(m)&& getBottom()+10> m.position.y-16:
				status=constants.upward
				lastXPos=position.x
				if position.x>m.position.x:
					dir=constants.left
				else:
					dir=constants.right	
			else:
				if getBottom()+32>=winHeight:
					status=constants.upward
		elif getBottom()+32>=winHeight:
			status=constants.upward
		
func startDeathJump(_dir=constants.left):
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	status=constants.deadJump
	_dead=true
	active=false
	z_index=5

func pause():
	preStatus=status
	status=constants.stop
	active=false
	ani.stop()

func resume():
	status=preStatus
	ani.play()
	if !_dead:
		active=true


func animation(type):
	if type=='rise':
		if spriteIndex==0:
			ani.play("rise_0")
		elif spriteIndex==1:
			ani.play("rise_1")	
		elif spriteIndex==2:
			ani.play("rise_2")	
			
		ani.stop()
		ani.frame=1
	elif type=='down':
		if spriteIndex==0:
			ani.play("rise_0")
		elif spriteIndex==1:
			ani.play("rise_1")	
		elif spriteIndex==2:
			ani.play("rise_2")	
			
		ani.stop()
		ani.frame=0	
	pass	



