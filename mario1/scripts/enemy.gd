extends "res://scripts/object.gd"

var status=constants.walking
var dir=constants.left
var spriteIndex=0 #0普通颜色 1蓝色 2灰色
var time=0
var delTime=100  #删除时间 100帧
#var maxYVel=constants.enemyMaxVel
#var init=false
#var isOnFloor=true #是否在地面上
var _dead=false #是否死亡
var speed=55

func _ready():
	maxYVel=constants.enemyMaxVel
#	._ready()
#	gravity=constants.enemyGravity
	
	
func walking(delta):
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
	pass
	

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
	yVel=-300
	if dir==constants.left:
		xVel=-45
	else:
		xVel=45
	gravity=constants.deathJumpGravity
	z_index=5
	pass

func dead(delta):
	time+=1
	if time>=delTime:
#		queue_free()
		destroy=true
		pass
	pass

#func destory():
#	queue_free()
	
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


