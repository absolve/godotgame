extends "res://scripts/enemy.gd"


onready var ani=$ani
var preStatus

func _ready():
	mask=[constants.fireball,constants.box,constants.brick
		,constants.platform,constants.pipe,constants.koopa,constants.goomba,
		constants.beetle,constants.cannon]
	rect=Rect2(Vector2(-15,-16),Vector2(30,32))
	maxYVel=constants.enemyMaxVel #y轴最大速度
	gravity=constants.spinyEggGravity
	type=constants.spiny
	status=constants.spinyEgg
	pass # Replace with function body.


func _update(delta):
	if status==constants.spinyEgg:
		animation('egg')
		pass
	elif status==constants.walking:
		walking(delta)
		animation('walk')
		pass	
	elif status==constants.deadJump:
		deathJump(delta)	
	
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

func turnLeft():
	.turnLeft()
	ani.flip_h=false	

func turnRight():
	.turnRight()
	ani.flip_h=true	

func startDeathJump(_dir=constants.left):
	dir=_dir
	.startDeathJump()
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	_dead=true
	active=false


func animation(type):
	if type=='egg':
		ani.play("egg")
	elif type=='walk':
		ani.play("walk")	
		
	if dir==constants.left:
		ani.flip_h=false
	else:
		ani.flip_h=true		
	pass


func rightCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box\
	||obj.type==constants.pipe||obj.type==constants.cannon:
		if obj.type==constants.box&&!obj._visible:
			return false
		turnLeft()
		return true
	elif  obj.type==constants.goomba||obj.type==constants.koopa\
	||obj.type==constants.spiny||obj.type==constants.beetle:
		if obj.status!=constants.deadJump:
			turnLeft()

	
func leftCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box\
	||obj.type==constants.pipe||obj.type==constants.cannon:
		if obj.type==constants.box&&!obj._visible:
			return false
		turnRight()
		return true
	elif  obj.type==constants.goomba||obj.type==constants.koopa\
	||obj.type==constants.spiny||obj.type==constants.beetle:
		if obj.status!=constants.deadJump:
			turnRight()

	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box\
	||obj.type==constants.pipe||obj.type==constants.cannon:
		if obj.type==constants.box&&obj.status==constants.bumped:
			Game.addScore(position,200)
			if position.x>=obj.position.x:
				startDeathJump(constants.right)
			else:
				startDeathJump()
		if status==constants.spinyEgg:
			status=constants.walking
		if obj.type==constants.box&&!obj._visible:
			return false	
		return true
