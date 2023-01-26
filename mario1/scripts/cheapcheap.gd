extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus
var swimYspeed=8
var swimXspeed=15

func _ready():
	type=constants.cheapcheap
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	maxYVel=constants.enemyMaxVel #y轴最大速度
	gravity=constants.enemyGravity
#	speed=swimXspeed
#	status=constants.swim
	
	if status==constants.swim:
		if spriteIndex==0:
			swimXspeed=25
		ani.speed_scale=0.5	
		gravity=0
		
	if dir==constants.left:
		xVel=-swimXspeed
	else:
		xVel=speed

func startDeathJump(_dir=constants.left):
	status=constants.deadJump
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	active=false
	_dead=true
	gravity=constants.deathJumpGravity
	z_index=5


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
		if spriteIndex==0 && Game.getMario().size()>0: #红色的会追人
			var m= Game.getMario()[0]
			if m.status!=constants.deadJump:
				if m.position.y>position.y && m.position.x<position.x:
					yVel=swimYspeed
				elif m.position.y<position.y:	
					yVel=-swimYspeed
				else:
					yVel=0
		animation('swim')
		pass
	elif status==constants.flying:  #在天上飞
		
		pass
	elif status==constants.deadJump:
		yVel=50
#		position.x+=xVel*delta
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
				
