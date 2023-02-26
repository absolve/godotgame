extends "res://scripts/enemy.gd"

const slidingSpeed=380
onready var ani=$ani
var reviveStartTime=0
var reviveTime=600 #变成壳然后变回甲壳虫的时间
var combo=0  #分数连击
var preStatus

func _ready():
	mask=[constants.fireball,constants.box,constants.brick
		,constants.platform,constants.pipe,constants.koopa,constants.goomba,
		constants.beetle]
	rect=Rect2(Vector2(-15,-16),Vector2(30,32))
	maxYVel=constants.enemyMaxVel #y轴最大速度
	gravity=constants.enemyGravity
	type=constants.beetle
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
	animation("walk")		
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
	elif status==constants.stop:
		pass
	elif status==constants.revive:
		reviveStartTime+=1
		if reviveTime-reviveStartTime<0:
			status=constants.walking
			reviveStartTime=0
			animation("walk")	
			ani.position.y=-18


func shellSliding(delta):
	if dir==constants.left:
		xVel=-slidingSpeed
	else:
		xVel=slidingSpeed	
	pass

func jumpedOn():
	if status==constants.walking:
		animation("shell")
		if dir==constants.left:
			dir=constants.right
		else:
			dir=constants.left	
		xVel=0	
		reviveStartTime=0
		status=constants.shell
		ani.position.y=0
	elif status==constants.shell|| status==constants.revive:
		startSliding()
	elif status==constants.sliding:
		status=constants.shell
		xVel=0
		reviveStartTime=0
		combo=0

func startDeathJump(_dir=constants.left):
	dir=_dir
	ani.position.y=0
	animation("shell")
	.startDeathJump()
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	_dead=true
	active=false

func startSliding(_dir=constants.left):
	animation("shell")
	status=constants.sliding	
	dir=_dir

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
	if dir==constants.left:
		ani.flip_h=false
	elif dir==constants.right:
		ani.flip_h=true	
	
	

func rightCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		turnLeft()
		return true
	elif  obj.type==constants.goomba||obj.type==constants.koopa||obj.type==constants.beetle:
		if status==constants.sliding:
			if ! obj._dead:
				obj.startDeathJump(constants.right)
				if combo<constants.koopaScore.size():
					Game.addScore(position,constants.koopaScore[combo])
					combo+=1
				else:
					Game.addLive(position,'')
					SoundsUtil.playItem1up()
				SoundsUtil.playStomp()			
		else:	
			turnLeft()
#			return true
	pass
	
func leftCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		turnRight()
		return true
	elif  obj.type==constants.goomba||obj.type==constants.koopa||obj.type==constants.beetle:
		if status==constants.sliding:
			if ! obj._dead:
				obj.startDeathJump()
				if combo<constants.koopaScore.size():
					Game.addScore(position,constants.koopaScore[combo])
					combo+=1
				else:
					Game.addLive(position,'')
					SoundsUtil.playItem1up()
				SoundsUtil.playStomp()			
		else:	
			turnRight()

	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		if status==constants.walking&& dir==constants.left&&spriteIndex==3: #如果是红乌龟就会自动返回
			if !Game.checkMapBrick(position.x,position.y+getSizeY()/2):
				turnRight()
		elif status==constants.walking&& dir==constants.right&&spriteIndex==3:		
			if !Game.checkMapBrick(position.x,position.y+getSizeY()/2):
				turnLeft()
		return true
	elif obj.type==constants.goomba||obj.type==constants.koopa||obj.type==constants.beetle:
		if status==constants.sliding:
			if ! obj._dead:
				obj.startDeathJump()
				if combo<constants.koopaScore.size():
					Game.addScore(position,constants.koopaScore[combo])
					combo+=1
				else:
					Game.addLive(position,'')
					SoundsUtil.playItem1up()
				SoundsUtil.playStomp()		
