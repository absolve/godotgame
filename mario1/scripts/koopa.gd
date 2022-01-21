extends "res://scripts/enemy.gd"

#const speed=40
const slidingSpeed=110
var preStatus
onready var ani=$ani

func _ready():
#	status=constants.sliding
	debug=true
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	gravity=constants.marioGravity
	type=constants.koopa
	if dir==constants.left:
		xVel=-50
	else:
		xVel=50
	if spriteIndex==0:
		ani.play("walk")
	elif spriteIndex==1:
		ani.play("walk_blue")	
	elif spriteIndex==2:	
		ani.play("walk_grey")	
	elif spriteIndex==3:
		ani.play("walk_red")	
	ani.position.y=-18		
	pass

func _update(delta):
	if status==constants.walking:
		walking(delta)
	elif status==constants.sliding:
		shellSliding(delta)
	elif status==constants.dead:
		dead(delta)
	elif status==constants.deadJump:
		deathJump(delta)
	elif status==constants.shell:
		pass
	elif status==constants.stop:
		pass
	pass
	

func jumpedOn():
	if status==constants.shell:
		status=constants.sliding
		return
		
	if spriteIndex==0:
		ani.play("shell")
	elif spriteIndex==1:
		ani.play("shell_blue")	
	elif spriteIndex==2:	
		ani.play("shell_grey")	
	elif spriteIndex==3:
		ani.play("shell_red")	
	if dir==constants.left:
		xVel=slidingSpeed
	else:
		xVel=-slidingSpeed	
	status=constants.shell
	ani.position.y=0	
	pass



func startDeathJump():
#	.startDeathJump()
#	ani.playing=false
#	if spriteIndex==0:
#		ani.play()
#
#	ani.frame=0
#	z_index=2
	#status=constants.deadJump
	pass	


func shellSliding(delta):
	yVel+=gravity*delta
	position.x+=xVel*delta
	position.y+=yVel*delta
	pass

func turnLeft():
	.turnLeft()
	ani.flip_h=false
	pass	

func turnRight():
	.turnRight()
	ani.flip_h=true
	pass	

func changeDir():
	if dir==constants.left:	
		dir=constants.right
	else:
		dir=constants.left
	pass

func pause():
	preStatus=status
	status=constants.stop
	ani.stop()

func resume():
	ani.play()	
	status=preStatus
