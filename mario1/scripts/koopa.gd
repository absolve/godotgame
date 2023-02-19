extends "res://scripts/enemy.gd"

#const speed=40
const slidingSpeed=380
var preStatus
onready var ani=$ani
#const speed=55
var reviveStartTime=0
var reviveTime=600 #变成壳然后变回乌龟的时间
var combo=0  #分数连击
var yDir=constants.up #飞行时的移动方向
var ySpeed=55  #向上飞行时y的速度
var jumpSpeed=400

func _ready():
#	status=constants.shell
#	animation("shell")
#	debug=true
	mask=[constants.fireball,constants.box,constants.brick
		,constants.platform,constants.pipe,constants.koopa,constants.goomba,
		constants.beetle]
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
#	gravity=constants.enemyGravity
	maxYVel=constants.enemyMaxVel #y轴最大速度
	gravity=constants.enemyGravity
	
	type=constants.koopa
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
	
	position.x+=offsetX
	position.y+=offsetY
	
	if spriteIndex in [4,5,6,7]:	#设置成飞行的状态
		status=constants.flying
		yDir=constants.up	
		spriteIndex-=4
		gravity=0
		xVel=0
		animation("flying")
	elif spriteIndex in [8,9,10,11]: #跳跃的状态
		status=constants.jumping
		spriteIndex-=8
		gravity=constants.enemyJumpGravity
		animation("jumping")
	else:		
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
	elif status==constants.stop:
		pass
	elif status==constants.revive:
		reviveStartTime+=1
		if reviveTime-reviveStartTime<0:
			status=constants.walking
			reviveStartTime=0
			animation("walk")	
			ani.position.y=-18
	elif status== constants.flying:
		flying(delta)
	elif status==constants.jumping:
		jumping(delta)

func flying(delta):
	if yDir==constants.up:
		yVel-=1
		if yVel<-ySpeed:
			yDir=constants.down
	elif yDir==constants.down:	
		yVel+=1
		if yVel>ySpeed:
			yDir=constants.up

func jumping(delta):
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
	
func jumpedOn():
	if status==constants.walking:
		animation("shell")
		if dir==constants.left:
			turnRight()
		else:
			turnLeft()
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
	elif status==constants.flying||status==constants.jumping:
		status=constants.walking
		gravity=constants.enemyGravity
		if dir==constants.left:
			turnRight()
		else:
			turnLeft()	
		animation("walk")	


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
	pass	


func startSliding(_dir=constants.left):
	animation("shell")
	status=constants.sliding	
	dir=_dir

func shellSliding(delta):
	if dir==constants.left:
		xVel=-slidingSpeed
	else:
		xVel=slidingSpeed	


func turnLeft():
	.turnLeft()
	ani.flip_h=false	

func turnRight():
	.turnRight()
	ani.flip_h=true	

func turnDir():
	.turnDir()
	ani.flip_h=!ani.flip_h

func changeDir():
#	if dir==constants.left:	
#		dir=constants.right
#	else:
#		dir=constants.left
	pass

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
	elif type=="flying" || type=='jumping':
		if spriteIndex==0:
			ani.play("fly")
		elif spriteIndex==1:
			ani.play("fly_blue")	
		elif spriteIndex==2:	
			ani.play("fly_grey")	
		elif spriteIndex==3:
			ani.play("fly_red")		
	

	
	
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
		if status==constants.jumping:
			yVel=-jumpSpeed
		#todo 增加被砖块撞飞
		
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

func ceilcollide(obj):#上方的判断
	if obj.type==constants.goomba||obj.type==constants.koopa||obj.type==constants.beetle:
		if status==constants.sliding:
			if ! obj._dead:
				obj.startDeathJump()
