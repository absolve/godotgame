extends "res://scripts/enemy.gd"

#const speed=40
const slidingSpeed=260
var preStatus
onready var ani=$ani
const speed=55
var reviveStartTime=0
var reviveTime=600 #变成壳然后变回乌龟的时间


func _ready():
#	status=constants.shell
#	animation("shell")
	debug=true
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	gravity=constants.enemyGravity
	type=constants.koopa
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
	animation("walk")		
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
		reviveStartTime+=1
		if reviveTime-reviveStartTime<200:
			status=constants.revive
			animation("revive")	
		pass
	elif status==constants.stop:
		pass
	elif status==constants.revive:
		reviveStartTime+=1
		if reviveTime-reviveStartTime<0:
			status=constants.walking
			reviveStartTime=0
			animation("walk")	
			ani.position.y=-18
		pass
	pass
	

func jumpedOn():
	if status==constants.shell:
		startSliding()
		return
	elif status==constants.sliding:
		status=constants.shell
	animation("shell")	
	if dir==constants.left:
		dir=constants.right
	else:
		dir=constants.left	
		
#	if spriteIndex==0:
#		ani.play("shell")
#	elif spriteIndex==1:
#		ani.play("shell_blue")	
#	elif spriteIndex==2:	
#		ani.play("shell_grey")	
#	elif spriteIndex==3:
#		ani.play("shell_red")	
#	if dir==constants.left:
#		xVel=slidingSpeed
#	else:
#		xVel=-slidingSpeed	
	reviveStartTime=0
	status=constants.shell
	ani.position.y=0	
	pass



func startDeathJump(_dir=constants.left):
#	.startDeathJump()
#	ani.playing=false
#	if spriteIndex==0:
#		ani.play()
#
#	ani.frame=0
#	z_index=2
	#status=constants.deadJump
	dir=_dir
	ani.position.y=0
	animation("shell")
	.startDeathJump()
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	z_index=2
	status=constants.deadJump
	pass	


func startSliding():
	if dir==constants.left:
		xVel=slidingSpeed
	else:
		xVel=-slidingSpeed	
	status=constants.sliding	

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

func turnDir():
	.turnDir()
	ani.flip_h=!ani.flip_h

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

func animation(type):
	if type=="walk":
		if spriteIndex==0:
			ani.play("walk")
		elif spriteIndex==1:
			ani.play("walk_blue")	
		elif spriteIndex==2:	
			ani.play("walk_grey")	
		elif spriteIndex==3:
			ani.play("walk_red")	
	elif type=="shell":	
		if spriteIndex==0:
			ani.play("shell")
		elif spriteIndex==1:
			ani.play("shell_blue")	
		elif spriteIndex==2:	
			ani.play("shell_grey")	
		elif spriteIndex==3:
			ani.play("shell_red")	
	elif type=="revive":
		if spriteIndex==0:
			ani.play("revive")
		elif spriteIndex==1:
			ani.play("revive_blue")	
		elif spriteIndex==2:	
			ani.play("revive_grey")	
		elif spriteIndex==3:
			ani.play("revive_red")					
