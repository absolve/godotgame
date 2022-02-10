extends "res://scripts/object.gd"

var status=constants.walking
var dir=constants.left
var spriteIndex=0 #0普通颜色 1蓝色 2灰色
var time=0
var delTime=140  #删除时间 140帧


func walking(delta):
	yVel+=gravity*delta	
	position.x+=xVel*delta
	position.y+=yVel*delta
	

func deathJump(delta):
	yVel+=gravity*delta	
	position.x+=xVel*delta
	position.y+=yVel*delta
	pass	
	
func jumpedOn():
	pass	

func startDeathJump():
	yVel=-190
	if dir==constants.left:
		xVel=-45
	else:
		xVel=45
	gravity=constants.deathJumpGravity
	pass

func dead(delta):
	time+=1
	if time>=delTime:
		queue_free()
		pass
	pass

func destory():
	queue_free()
	
func turnLeft():
	xVel=-abs(xVel)
	pass	

func turnRight():
	xVel=abs(xVel)
	pass	

func turnDir():
	if xVel>0:
		xVel=-abs(xVel)
	else:
		xVel=abs(xVel)	
	pass
