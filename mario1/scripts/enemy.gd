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
	yVel=-180
	if dir==constants.left:
		xVel=-40
	else:
		xVel=40	
	gravity=constants.deathJumpGravity
	pass

func dead(delta):
	time+=1
	if time>=delTime:
		queue_free()
		pass
	pass
	
func turnLeft():
	xVel=-abs(xVel)
	pass	

func turnRight():
	xVel=abs(xVel)
	pass	
