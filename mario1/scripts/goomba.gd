extends "res://scripts/enemy.gd"


onready var ani=$ani
var preStatus


func _ready():
#	debug=true
	mask=[constants.brick,constants.box,constants.platform,
		constants.fireball,constants.pipe,constants.koopa,constants.goomba
		,constants.cannon,constants.beetle,constants.spiny,constants.beetle]
	._ready()
	rect=Rect2(Vector2(-15,-16),Vector2(30,32))
#	gravity=constants.enemyGravity
	type=constants.goomba
#	maxYVel=constants.enemyMaxVel #y轴最大速度
	gravity=constants.enemyGravity
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
	
	position.x+=offsetX
	position.y+=offsetY
		
	if spriteIndex==0:
		ani.play("walk")
	elif spriteIndex==1:
		ani.play("walk_blue")	
	elif spriteIndex==2:	
		ani.play("walk_grey")	
	pass

func _update(delta):
	if status==constants.walking:
		walking(delta)
	elif status==constants.dead:
		dead(delta)
	elif status==constants.deadJump:
		deathJump(delta)
	elif status==constants.stop:
		pass


	
func jumpedOn():
	if spriteIndex==0:
		ani.play("dead")
	elif spriteIndex==1:
		ani.play("dead_blue")	
	elif spriteIndex==2:	
		ani.play("dead_grey")	
	status=constants.dead	
	gravity=0
	xVel=0
	yVel=0
	_dead=true
	pass


func startDeathJump(_dir=constants.left):
	dir=_dir
	.startDeathJump()
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	_dead=true
	active=false


func pause():
	preStatus=status
	status=constants.stop
	active=false
	ani.stop()

func resume():
#	if status!=constants.dead&&status!=constants.deadJump:
#		status=preStatus
	status=preStatus
	ani.play()	
	if status!=constants.dead&&status!=constants.deadJump:
		active=true
#	if status!=constants.dead&&status!=constants.deadJump:
#		ani.play()	
		
func rightCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe\
	||obj.type==constants.jumpingBoard||obj.type==constants.cannon:
		if obj.type==constants.box&&!obj._visible:
			return false
		turnLeft()
		return true
	elif  obj.type==constants.goomba||obj.type==constants.koopa\
	||obj.type==constants.spiny||obj.type==constants.beetle:
		if obj.status!=constants.deadJump:
			turnLeft()
#		return true
	pass
	
func leftCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe\
	||obj.type==constants.jumpingBoard||obj.type==constants.cannon:
		if obj.type==constants.box&&!obj._visible:
			return false
		turnRight()
		return true
	elif  obj.type==constants.goomba||obj.type==constants.koopa\
	||obj.type==constants.spiny||obj.type==constants.beetle:
		if obj.status!=constants.deadJump:
			turnRight()
#		return true
	
	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		if obj.type==constants.box&&obj.status==constants.bumped||obj.type==constants.cannon:
			Game.addScore(position,200)
			if position.x>=obj.position.x:
				startDeathJump(constants.right)
			else:
				startDeathJump()
		if obj.type==constants.box&&!obj._visible:
			return false
		return true
