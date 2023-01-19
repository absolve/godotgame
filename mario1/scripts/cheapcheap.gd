extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus



func _ready():
	type=constants.cheapcheap
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	maxYVel=constants.enemyMaxVel #y轴最大速度
	gravity=constants.enemyGravity
	speed=60
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
	
	pass

func startDeathJump(_dir=constants.left):
	status=constants.deadJump
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	active=false
	gravity=constants.deathJumpGravity
	z_index=5
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
	if status==constants.swim:
		pass
	elif status==constants.deadJump:
		yVel=80
		position.x+=xVel*delta
		position.y+=yVel*delta
		pass
		
func animation(type):
	if type=='swim':
		if spriteIndex==0:
			ani.play("0")
		elif spriteIndex==1:
			ani.play("1")	
		elif spriteIndex==2:
			ani.play("2")
		elif spriteIndex==3:	
			ani.play("3")	
		pass
	elif type=='fly':
		
		pass	
				
