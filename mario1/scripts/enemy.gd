extends "res://scripts/object.gd"

var status=constants.walking
var dir=constants.left
var spriteIndex=0 #0普通颜色 1蓝色 2灰色
var time=0
var delTime=140  #删除时间 140帧
#var maxYVel=constants.enemyMaxVel
#var init=false
#var isOnFloor=true #是否在地面上


func _ready():
	maxYVel=constants.enemyMaxVel
	._ready()
	gravity=constants.enemyGravity
	
	
func walking(delta):
	if yVel<maxYVel:
		yVel+=gravity*delta			
	position.x+=xVel*delta
	if !isOnFloor:	
		position.y+=yVel*delta
	

func deathJump(delta):
	if yVel<maxYVel:
		yVel+=gravity*delta	
	position.x+=xVel*delta
	position.y+=yVel*delta
	pass	
	
func jumpedOn():
	pass	

func startDeathJump():
	status=constants.deadJump
	yVel=-350
	if dir==constants.left:
		xVel=-45
	else:
		xVel=45
#	gravity=constants.deathJumpGravity
	z_index=3
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
	dir=constants.left
	xVel=-abs(xVel)
	pass	

func turnRight():
	dir=constants.right
	xVel=abs(xVel)
	pass	

func turnDir():
	if xVel>0:
		xVel=-abs(xVel)
	else:
		xVel=abs(xVel)	
	pass

#func setActive():
#	if !init:
#		status=constants.walking
#		init=true
