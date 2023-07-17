extends "res://scripts/object.gd"


#var maxXVel=constants.marioWalkMaxSpeed
#var maxYVel=constants.marioMaxYVel #y轴最大速度
var big = false #是否变大
#var faceRight=true
var fire = false #是否能发射子弹
var status=constants.stand
var acceleration =constants.acceleration #加速度
#var isOnFloor=false #是否在地面上
var dir=constants.right
var throwAniFinish=false
var playerId=1  #玩家id 1 2 3 4
var shootDelay=200 #发射延迟
var shootStart=0
var allowShoot=false
var big2FireAni=[2,3,0] #变成发射动画列表
var big2FireTime=0
var FireAniIndex=0  #动画索引
var currentAnimation  #当前动画
var preStatus   #之前状态
var invincible=false #无敌
var invincibleStartTime=0
var invincibleEndime=720	#无敌持续时间
var invincibleAnimationTimer=0
var shadowIndex=0  #另一个动画的索引
var hurtInvincible=false
var hurtInvincibleStartTime=0
var hurtInvincibleEndime=300
var dead=false  #是否死亡
var deadStartTime=0
var deadEndTime=30
#var leftStop=false
#var rightStop=false
var flagPoleTimer=0 #从旗杆上转身然后下来
#var poleLength=0 #旗杆右边位置
var isCrouch=false 	#是否蹲下
var enterPipeX=0 #进入水管的时候判断是否已经完全进去水管
var enterPipeY=0 
var combo=0  #分数连击
var pipeNo=0 #水管的编号
var _delta
var vineObj=null #藤曼的对象
var startAutoGrabVine=false #设置开始自动爬藤蔓
var onBoardTimer=0  #在跳板上时间
var onBoardDelta=8.0
var underwater=false #水下
var bubbletimer=0
var bubbleDelta=140  #气泡间隔

var stand_small_animation=['stand_small','stand_small_green',
						'stand_small_red','stand_small_black']
var slide_small_animation=['slide_small','slide_small_green',
						'slide_small_red','slide_small_black']
var walk_small_animation=['walk_small','walk_small_green',
						'walk_small_red','walk_small_black']
var landing_small_animation=['landing_small','landing_small_green',
						'landing_small_red','landing_small_black']				
var jump_small_animation=['jump_small','jump_small_green',
						'jump_small_red','jump_small_black']
var stand_big_animation=['stand_big','stand_big_green',
						'stand_big_red','stand_big_black']
var walk_big_animation=['walk_big','walk_big_green',
						'walk_big_red','walk_big_black']
var slide_big_animation=['slide_big','slide_big_green',
						'slide_big_red','slide_big_black']
var jump_big_animation=['jump_big','jump_big_green',
						'jump_big_red','jump_big_black']	
var landing_big_animation=['landing_big','landing_big_green',
						'landing_big_red','landing_big_black']						
var crouch_animation=['crouch','crouch_green',
						'crouch_red','crouch_black']
var throw_animation=['throw','throw_green',
						'throw_red','throw_black']
var death_jump_animation=['death','death_green',
						'death_red','death_black']
var swim_small_animation=['swim_small','swim_small_green',
						'swim_small_red','swim_small_black']
var swim_big_animation=['swim_big','swim_big_green',
						'swim_big_red','swim_big_black']


var ball=preload("res://scenes/fireball.tscn")
var bubble=preload("res://scenes/bubble.tscn")

var keymap={"up":0,"down":0,"left":0,"right":0,'jump':0,'action':0}
							
var aniIndex=0	#动画索引					
onready var ani=$ani
onready var shadow=$shadow
onready var jump=$jump
onready var bigjump=$bigjump
onready var fireball=$fireball
onready var slide=$slide
onready var _swim=$swim

func _ready():
	mask=[constants.box,constants.brick,constants.mushroom,constants.star,
		constants.mushroom1up,constants.fireflower,constants.platform,constants.bigCoin,constants.plant,
		constants.pipe,constants.pole,constants.collision,constants.goomba,
		constants.koopa,constants.spinFireball,constants.bridge,
		constants.axe,constants.figures,constants.fireball,constants.bowser,
		constants.fire,constants.vine,constants.jumpingBoard,constants.bloober,
		constants.bulletBill,constants.cannon,constants.hammer,constants.staticPlatform,
		constants.hammerBro,constants.cheapcheap,constants.flyingfish,constants.spiny,
		constants.podoboo,constants.lakitu,constants.beetle,constants.mazeGate]
	maxXVel=constants.marioWalkMaxSpeed
	maxYVel=constants.marioMaxYVel #y轴最大速度
#	status=constants.stop
	type=constants.mario
#	debug=true
	if big:
#		rect=Rect2(Vector2(-11,-30),Vector2(22,60))	
		adjustBigRect()
		position.y-=14
	else:	
#		rect=Rect2(Vector2(-10,-16),Vector2(20,32))	
		adjustSmallRect()
	gravity=constants.marioGravity
	if big && fire:
		aniIndex=2
	animation("stand")
	shadowIndex=aniIndex
	var jump1=jump.stream as AudioStreamOGGVorbis
	jump1.set_loop(false)
	var bigjump1=bigjump.stream as AudioStreamOGGVorbis
	bigjump1.set_loop(false)
	var fireball1=fireball.stream as AudioStreamOGGVorbis
	fireball1.set_loop(false)
	var slide1=slide.stream as AudioStreamOGGVorbis
	slide1.set_loop(false)
	var swim1=_swim.stream as AudioStreamOGGVorbis
	swim1.set_loop(false)
	
	
	if status==constants.fall:
		if underwater:
			if big:
				ani.animation=swim_big_animation[aniIndex]
			else:
				ani.animation=swim_small_animation[aniIndex]
		else:	
			if big:
				ani.animation=walk_big_animation[aniIndex]
			else:
				ani.animation=	walk_small_animation[aniIndex]
				ani.frame=2
	if underwater:
		gravity=constants.marioUnderWaterGravity
		maxYVel=constants.underwatermarioMaxYVel
		status=constants.fall
		animation('swim')
#		ani.stop()

#设置按键
func setKeyMap(playerId:int):
	if playerId==1:
		keymap["up"]="p1_up"
		keymap["down"]="p1_down"
		keymap["left"]="p1_left"
		keymap["right"]="p1_right"
		keymap["jump"]="p1_jump"
		keymap["action"]="p1_action"

func _update(delta):
	if status==constants.stand:
		stand(delta)
	elif status==constants.walk:
		walk(delta)
	elif status==constants.fall:
		fall(delta)
	elif status==constants.jump:
		jump(delta)	
	elif status==constants.small2big:
		pass
	elif status==constants.big2fire:
		fireState(delta)
	elif status==constants.big2small:
		pass
	elif status==constants.crouch:
		crouch(delta)
	elif status==constants.deadJump:
		deathJump(delta)	
	elif status==constants.poleSliding:
		poleSliding(delta)
	elif status==constants.walkingToCastle:
		walkingToCastle(delta)
	elif status==constants.sitBottomOfPole:
		sitBottomOfPole(delta)
	elif status==constants.stop:
		pass	
	elif status==constants.pipeIn:
		pipeIn(delta)	
	elif status==constants.walkInPipe:
		walkIntoPipe(delta)
	elif status==constants.pipeOut:
#		yVel=-40
#		position.y+=yVel*delta	
		pipeOut(delta)	
	elif status==constants.onlywalk:
		onlywalk(delta)	
	elif status==constants.grabVine:
		grabVine(delta)
	elif status==constants.autoGrabVine:
		autoGrabVine(delta)
	elif status==constants.onBoard:
		onBoard(delta)
	elif status==constants.swim:
		swim(delta)
		
	if status!=constants.big2small&&status!=constants.big2fire&&\
		status!=constants.small2big:	
		specialState(delta)
		
	if status!=constants.stop && underwater:
		bubbletimer+=1
		if bubbletimer>bubbleDelta:
			bubbletimer=0
			addBubble()
		
	if debug:	
		update()	
	self._delta=delta
	pass
	
func specialState(_delta):
	if invincible:
		if invincibleEndime-invincibleStartTime>200:
			if invincibleStartTime%4==0:
				if shadowIndex==3:
					shadowIndex=0
				else:
					shadowIndex+=1
		elif invincibleEndime-invincibleStartTime>=0:		
			if invincibleStartTime%11==0:
				if shadowIndex==3:
					shadowIndex=0
				else:
					shadowIndex+=1
		else:
			if status!=constants.poleSliding&&status!=constants.walkingToCastle\
				&&status!=constants.sitBottomOfPole&&status!=constants.deadJump:
				Game.emit_signal("invincibleFinish")
			invincible=false
			shadow.visible=false
			if fire:
				shadowIndex=2
			else:
				shadowIndex=0			
		invincibleStartTime+=1
	if hurtInvincible:
		if hurtInvincibleEndime-hurtInvincibleStartTime>=0:
			if hurtInvincibleStartTime%3==0:
				modulate.a=0.1
			else:
				modulate.a=1
		else:
			hurtInvincible=false
			hurtInvincibleStartTime=0
			modulate.a=1
		hurtInvincibleStartTime+=1
		pass

#设置无敌
func setInvincible():
	invincible=true
	invincibleStartTime=0
	shadow.visible=true

#设置受伤无敌
func setHurtInvincible():
	hurtInvincible=true
	hurtInvincibleStartTime=0
	
	
func stand(_delta):
	if ani.animation in throw_animation&&throwAniFinish:	
		animation("stand")
	elif !(ani.animation  in throw_animation):
		animation("stand")
		
	if Input.is_action_pressed("ui_left"):
		dir=constants.left
		status = constants.walk
	elif Input.is_action_pressed("ui_right"):
		dir=constants.right
		status = constants.walk
	elif Input.is_action_pressed("ui_jump"):	
		if underwater:
			status=constants.swim
			pass
		else:	
			yVel=-constants.marioJumpSpeed
			gravity=constants.marioJumpGravity
			status=constants.jump
			playJumpSound()

	if Input.is_action_just_pressed("ui_down") &&big:
		startCrouch()
		return
	if Input.is_action_just_pressed("ui_action")&&fire:
		shootFireball()
		pass
	
	if !isOnFloor:
#		position.y+=yVel*delta	
		status=constants.fall


func walk(delta):
	if xVel>0 || xVel<0:
		ani.speed_scale=1+abs(xVel)/constants.marioAniSpeed
	
	if Input.is_action_pressed("ui_action"):
		if underwater:
			acceleration=constants.underwaterRunAcceleration
			maxXVel=constants.underwaterRunMaxSpeed
		else:	
			acceleration=constants.runAcceleration
			maxXVel=constants.marioRunMaxSpeed
		if fire&&allowShoot:
			shootFireball(false)
			allowShoot=false
	else:
		if underwater:
			acceleration=constants.underwaterAcceleration
			maxXVel=constants.underwaterWalkMaxSpeed
		else:	
			acceleration=constants.acceleration
			maxXVel=constants.marioWalkMaxSpeed	
		allowShoot=true
		
	#跳跃
	if Input.is_action_pressed("ui_jump"):
		if underwater:
			status=constants.swim
		else:	
			yVel=-constants.marioJumpSpeed
			gravity=constants.marioJumpGravity
			status=constants.jump
			playJumpSound()
		return
	
	if Input.is_action_pressed("ui_down") &&big:
		startCrouch()
		return
	elif isCrouch and big:
		adjustBigRect()
		position.y-=14
		ani.position.y=0
		isCrouch=false
	
	if Input.is_action_pressed("ui_left"):
		if xVel>0: #反方向
			slide.play()
			animation("slide")
			acceleration=constants.slideFriction
		else:
			if underwater:
				acceleration=constants.underwaterAcceleration
			else:	
				acceleration=constants.acceleration
			dir=constants.left
			animation('walk')
			
		if 	xVel>-maxXVel:
			xVel-=acceleration*delta
		else:
			xVel=-maxXVel
			
	elif Input.is_action_pressed("ui_right"):
		if xVel<0:
			slide.play()
			animation("slide")
			acceleration=constants.slideFriction
		else:
			if underwater:
				acceleration=constants.underwaterAcceleration
			else:	
				acceleration=constants.acceleration
			dir=constants.right
			animation('walk')
			
		if 	xVel<maxXVel:
			xVel+=acceleration*delta
		else:
			xVel=maxXVel
	else:
		if dir==constants.right:
			if	xVel>0:
				xVel-=acceleration*delta
				animation("walk")
			else:
				xVel=0
				ani.speed_scale=1
				status=constants.stand	
		else:
			if xVel<0:
				xVel+=acceleration*delta
				animation("walk")
			else:
				xVel=0
				ani.speed_scale=1
				status=constants.stand	
			
	if !isOnFloor:
		ani.stop()
		status=constants.fall
	pass

func jump(delta):
	if isCrouch:
		animation("crouch")
	else:
		animation("jump")	
	if yVel>0:
		gravity=constants.marioGravity
		status=constants.fall	
#		print('jump')
		return
	if isOnFloor: #在地面上
		gravity=constants.marioGravity
		status=constants.walk	
		
		
	if Input.is_action_just_released("ui_jump"):#如果跳跃键放开重力修改
		gravity=constants.marioGravity
	
	if Input.is_action_just_pressed("ui_action")&&fire:
		shootFireball(false)
	
	if Input.is_action_pressed("ui_left"):
		if xVel>-maxXVel:
			xVel-=acceleration*delta
	elif Input.is_action_pressed("ui_right"):
		if xVel<maxXVel:
			xVel+=acceleration*delta
		

func fall(delta):
#	if yVel<maxYVel:
#		yVel+=gravity*delta
	animation("fall")
	if Input.is_action_pressed("ui_left"):
		if xVel>-maxXVel:
			xVel-=acceleration*delta
	elif Input.is_action_pressed("ui_right"):
		if xVel<maxXVel:
			xVel+=acceleration*delta
	if Input.is_action_just_pressed("ui_action")&&fire:
		shootFireball(false)		
	if underwater&& Input.is_action_pressed("ui_jump"):
		status = constants.swim
	
	if isOnFloor:
		status = constants.walk		

#调整变大的矩形大小
func adjustBigRect():
	rect=Rect2(Vector2(-11,-30),Vector2(22,60))	

func adjustSmallRect():
	rect=Rect2(Vector2(-11,-16),Vector2(22,32))	

func adjustCrouchlRect():
	rect=Rect2(Vector2(-11,-15),Vector2(22,30))	

#开始死亡跳跃
func startDeathJump():
	SoundsUtil.playDeath()
	status=constants.deadJump
	active=false
	yVel=-500
	gravity=constants.marioDeathGravity
	Game.emit_signal("marioDead",position.x)
	ani.play(death_jump_animation[aniIndex])
	z_index=5
	deadStartTime=0
	pass

func deathJump(delta):
	if deadEndTime-deadStartTime<0:
		yVel+=gravity*delta
		position.y+=yVel*delta	
	else:
		deadStartTime+=1

#开始蹲下
func startCrouch():
	status=constants.crouch	
	if !isCrouch:
		adjustCrouchlRect()
		position.y+=14  #
		ani.position.y-=15
	acceleration=constants.crouchFriction	
	isCrouch=true
	
func crouch(delta):
#	yVel+=gravity*delta
	animation("crouch")
	if Input.is_action_just_pressed("ui_action")&&fire:
		shootFireball(false)
		
	if Input.is_action_just_released("ui_down"):
		status=constants.walk	
#		rect=Rect2(Vector2(-12,-30),Vector2(24,60))	
		adjustBigRect()
		position.y-=14
		ani.position.y=0
		isCrouch=false
		pass
	elif Input.is_action_pressed("ui_jump"):
		yVel=-constants.marioJumpSpeed
		gravity=constants.marioJumpGravity
		status=constants.jump
		playJumpSound()
		pass
	
		
	if dir==constants.right:
		if	xVel>0:
			xVel-=acceleration*delta
		else:
			xVel=0
			ani.speed_scale=1
	else:
		if xVel<0:
			xVel+=acceleration*delta
		else:
			xVel=0
			ani.speed_scale=1		
#	position.x+=xVel*delta
#	position.y+=yVel*delta
	pass

#设置水管出来的位置
func setPipeOutStatus(y):
	active=false
	enterPipeY=y
	status=constants.pipeOut
	animation("stand")
	pass

#进入水管
func pipeIn(delta):
	if getTop()<enterPipeY:
		position.y+=yVel*delta	
	else:
		Game.emit_signal("marioIntoPipe",pipeNo)
		status=constants.empty
		print('end')	
	pass

func pipeOut(delta):
	yVel=-40
	position.y+=yVel*delta
	if getBottom()>enterPipeY:
		position.y+=yVel*delta
	else:
		active=true
		status=constants.stand	
	pass


func walkIntoPipe(delta):
	animation('walk')	
	if dir==constants.left:
		if getRight()>enterPipeX:
			position.x+=xVel*delta	
		else:
			Game.emit_signal("marioIntoPipe",pipeNo)
			status=constants.empty
			print("end")	
	elif dir==constants.right:
		if getLeft()<enterPipeX:
			position.x+=xVel*delta	
		else:
			Game.emit_signal("marioIntoPipe",pipeNo)
			status=constants.empty
			print("end")

#自动行走
func onlywalk(delta):
	if dir==constants.left:
		xVel=-90
	elif dir==constants.right:
		xVel=90	
	if xVel>0 || xVel<0:
		ani.speed_scale=1+abs(xVel)/constants.marioAniSpeed	
	animation('walk')	
	
	pass

#变大
func small2Big():
	if big:
		return
	if hurtInvincible:
		modulate.a=1
	active=false		
	preStatus=status
	status=constants.small2big
	ani.play("small2big")
	ani.speed_scale=1
	Game.emit_signal("marioStateChange")
	pass

#变成开火状态
func big2Fire():
	if fire:
		return
	if hurtInvincible:
		modulate.a=1	
	active=false	
	preStatus=status
	status=constants.big2fire
	Game.emit_signal("marioStateChange")
	ani.stop()
	var name=ani.animation
	var animationList = ['stand_big','jump_big',
						'walk_big','slide_big',
						'crouch']
	if invincible:
		shadow.visible=false
	for a in animationList:
		if a in name:
			if a =='stand_big':
				currentAnimation = stand_big_animation
			elif a=='jump_big':
				currentAnimation=jump_big_animation
			elif a=='walk_big':
				currentAnimation=walk_big_animation
			elif a=='slide_big':
				currentAnimation=slide_big_animation
			elif a=='crouch':
				currentAnimation=crouch_animation

#变成发射火球的状态
func fireState(_delta):	
	if big2FireTime%30==0:
		FireAniIndex+=1
		if FireAniIndex>=big2FireAni.size():
			FireAniIndex=0
		ani.animation=currentAnimation[big2FireAni[FireAniIndex]]
	big2FireTime+=5
	if big2FireTime>=390:
		status=preStatus
		aniIndex=2
		fire=true
		if invincible:
			shadow.visible=true
		active=true	
		Game.emit_signal('marioStateFinish')

#变小
func big2Small():
	SoundsUtil.playBig2small()
	active=false
	preStatus=status
	status=constants.big2small
	if isCrouch:
		position.y-=14
		ani.position.y=0
	ani.speed_scale=1
	ani.play("big2small")
	Game.emit_signal("marioStateChange")
	pass

#开始在旗杆上滑动
func startSliding(length=0):
	status=constants.poleSliding
	animation("poleSliding")
	ani.frame=0
	ani.stop()
	xVel=0
	gravity=0 #防止加速下落
	yVel=180
	dir=constants.right
	Game.emit_signal("marioStartSliding")
#	ani.flip_h=true
#	self.poleLength=length
	pass

func poleSliding(delta):
#	yVel=220
#	position.y+=yVel*delta
	animation("poleSliding")
	pass

#这个是在旗杆的底部位置
func setSitBottom():
	ani.frame=0
	ani.stop()
	status=constants.sitBottomOfPole
#	position.x=position.x+poleLength+getSize()
#	ani.flip_h=true

func sitBottomOfPole(_delta):		
	flagPoleTimer+=1

#设置走到城堡里面
func setwalkingToCastle():
	gravity=constants.marioGravity
	ani.stop()
	status=constants.walkingToCastle
	acceleration=constants.acceleration
	maxXVel=constants.marioWalkMaxSpeed	
	
func walkingToCastle(delta):
	if flagPoleTimer==31: #转向
#		position.x=position.x+poleLength+getSize()
#		ani.flip_h=true
		pass
	elif flagPoleTimer<80: #等待一段时间然后往右走
		dir=constants.right
		xVel=0
		acceleration=constants.acceleration
	else:
#		xVel+=2
#		yVel+=gravity*delta
#		if xVel>0 || xVel<0:
#			ani.speed_scale=1+abs(xVel)/constants.marioAniSpeed
		if xVel>0:
			ani.speed_scale=1+xVel/constants.marioAniSpeed
		elif xVel<0:
			ani.speed_scale=1+xVel/constants.marioAniSpeed*-1
		if xVel<maxXVel:
			xVel+=5
		animation("walk")	
	flagPoleTimer+=1	
	
#设置成爬藤蔓
func setGrabVine(obj):
	if position.x>obj.position.x:
		position.x=obj.getRight()+getSize()/2
	else:
		position.x= obj.getLeft()-getSize()/2
	vineObj=obj
	gravity=0
	xVel=0
	yVel=0
	animation("poleSliding")
	status=constants.grabVine
	ani.stop()
	pass

#爬藤曼的处理
func grabVine(delta):
	if Input.is_action_pressed("ui_up"):
		if getTop()>vineObj.getTop():
			yVel=-100
		else:
			yVel=0	
		if getTop()-getSizeY()/2<0:
			Game.emit_signal("marioGrapVineTop",vineObj.level,vineObj.subLevel)
			
		animation("poleSliding")
	elif Input.is_action_pressed("ui_down"):	
		if getBottom()<vineObj.getBottom():
			yVel=100
		else:
			yVel=0		
		animation("poleSliding")
	elif Input.is_action_pressed("ui_right"):
		if position.x>vineObj.position.x &&  Input.is_action_just_pressed("ui_right"): 
			animation("walk")
			ani.frame=2
			ani.stop()
			status=constants.fall
			position.x=vineObj.getRight()+getSize()/2+1
			gravity=constants.marioGravity
		else:
			position.x = vineObj.getRight()+getSize()/2
			dir=constants.left
			animation("poleSliding")
			ani.stop()
	elif Input.is_action_pressed("ui_left"):
		if position.x<vineObj.position.x && Input.is_action_just_pressed("ui_left"):
			animation("walk")
			ani.frame=2
			ani.stop()
			status=constants.fall
			position.x=vineObj.getLeft()-1-getSize()/2
			gravity=constants.marioGravity
		else:
			position.x = vineObj.getLeft()-getSize()/2
			dir=constants.right
			animation("poleSliding")
			ani.stop()
	else:
		yVel=0
		ani.stop()

#设置成爬藤蔓的状态
func setAutoGrabVine(obj):
	animation("poleSliding")
	vineObj=obj
	active=false
	position.x= obj.getLeft()-getSize()/2
	ani.stop()
	status=constants.autoGrabVine
	pass

#自动爬藤蔓
func autoGrabVine(delta):
	if startAutoGrabVine:
		if getTop()>vineObj.getTop():
			position.y+=yVel*delta
		else: #转到右边
			dir=constants.left
			position.x=vineObj.getRight()+getSize()/2
			ani.stop()
			status=	constants.grabVine
			active=true
		animation("poleSliding")
		yVel=-80

#设置在跳板上
func setOnBoard(obj):
	print('setOnBoard')
	obj.stretch()
	yVel=10
	onBoardTimer=0
	status=constants.onBoard
	animation("walk")
	ani.stop()
	pass
	
#在跳板上
func onBoard(delta):
	onBoardTimer+=1
	if onBoardTimer>onBoardDelta:
		if Input.is_action_pressed("ui_jump"):
			yVel=-1000
		else:	
			yVel=-500
		status=constants.fall

#水下
func swim(delta):
	if Input.is_action_pressed("ui_jump"):
		yVel=-140
		animation('swim')
		if !_swim.playing:
			_swim.play()

	if Input.is_action_pressed("ui_left"):	
		acceleration=constants.acceleration
		dir=constants.left
			
		if 	xVel>-maxXVel:
			xVel-=acceleration*delta
		else:
			xVel=-maxXVel
			
	elif Input.is_action_pressed("ui_right"):
		dir=constants.right
		acceleration=constants.acceleration
			
		if 	xVel<maxXVel:
			xVel+=acceleration*delta
		else:
			xVel=maxXVel
	else:
		if dir==constants.right:
			if	xVel>0:
				xVel-=acceleration*delta
			else:
				xVel=0
				ani.speed_scale=1
		else:
			if xVel<0:
				xVel+=acceleration*delta
			else:
				xVel=0
				ani.speed_scale=1
	if Input.is_action_just_pressed("ui_action")&&fire:
		shootFireball()
	
	if yVel>0:
#		gravity=constants.marioGravity
		ani.stop()
		status=constants.fall	
		return
	if isOnFloor: #在地面上
#		gravity=constants.marioGravity
		status=constants.walk		
	if getTop()<constants.underwaterMaxHeight:
		yVel=20
	

#判断右边碰撞
func rightCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box|| obj.type==constants.bridge\
		||obj.type==constants.cannon||obj.type==constants.jumpingBoard:

		#判断是不是跨过一个间隙
		if !Game.checkMapBrickIndex(obj.localx-1,\
			obj.localy)&&yVel>0 && getBottom()-obj.getTop()<constants.boxHeight:
			if (obj.type==constants.box && 	obj._visible) || obj.type==constants.brick\
			||obj.type==constants.bridge:
				position.y=obj.getTop()-getSizeY()/2
#				position.x=obj.getLeft()-getSize()/2+0.2
#				yVel=1
				return false
			
		if obj.type==constants.box&&!obj._visible:
			return false
		else:
			if xVel!=0:
				if obj.type==constants.jumpingBoard && yVel!=0:
					return false
				else:	
					return true	
	elif obj.type==	constants.goomba||obj.type==constants.koopa||obj.type==constants.bulletBill\
	||obj.type==constants.hammerBro||obj.type==constants.beetle||obj.type==constants.flyingfish\
	||obj.type==constants.lakitu:
		if! obj._dead:
			if invincible:
				obj.startDeathJump(constants.right)
				Game.addScore(Vector2(position.x,getTop()))
				SoundsUtil.playShoot()
			else:
				if obj.status==constants.shell|| obj.status==constants.revive:
					obj.startSliding(constants.right)
					Game.addScore(Vector2(position.x,getTop()),500)
					SoundsUtil.playShoot()
					obj.position.x+=abs(obj.slidingSpeed)*_delta+1
					xVel=abs(xVel)-abs(xVel)/4
				else:
					if yVel>5:
						jumpOnEnemy(obj)
					else:	
						if !hurtInvincible:
							if big:
								big2Small()
								setHurtInvincible()
							else:	
								startDeathJump()
	elif obj.type== constants.mushroom || obj.type==constants.fireflower||\
		obj.type==constants.star || obj.type==constants.mushroom1up||\
		obj.type==constants.bigCoin:
		getItem(obj)
	elif obj.type==constants.pipe:
		if obj.pipeType==constants.pipeIn:
			if status==constants.onlywalk || \
			(isOnFloor&&obj.dir==constants.right&&Input.is_action_pressed("ui_right")):
				enterPipe(obj)
			else:
				return true		
		else:		
			return true
	elif obj.type==constants.pole:
		if status!=constants.poleSliding&&status!=constants.sitBottomOfPole:
			position.x=obj.getLeft()-getSize()/2+1
			startSliding()
			SoundsUtil.stopBgm()
#			SoundsUtil.stopSpecialBgm()
			SoundsUtil.playLevelend()
			addPoleScore(obj.position.y,obj)
		elif status==constants.sitBottomOfPole:
			if flagPoleTimer>=31:
				position.x=obj.getRight()+getSize()/2
				ani.flip_h=true
				setwalkingToCastle()
	elif obj.type==constants.collision:
		if obj.value==constants.castlePos:
#			destroy=true
			Game.emit_signal("marioInCastle")
	elif obj.type==constants.cheapcheap||obj.type==constants.bloober\
	||obj.type==constants.plant||obj.type==constants.spiny:
		if! obj._dead:
			if invincible:
				if obj.type==constants.plant:
					obj.hit()
				else:	
					obj.startDeathJump(constants.right)
				Game.addScore(Vector2(position.x,getTop()))
				SoundsUtil.playShoot()
			elif !hurtInvincible:
				if big:
					big2Small()
					setHurtInvincible()
				else:	
					startDeathJump()	
	elif obj.type==constants.spinFireball||obj.type==constants.bowser||obj.type==constants.fire\
	||obj.type==constants.hammer||obj.type==constants.podoboo:
#		print(obj.type)
		if !invincible&&!hurtInvincible:
			if big:
				big2Small()
				setHurtInvincible()
			else:	
				startDeathJump()	
	elif obj.type==constants.axe:
		print('axe')
		yVel=0
		Game.emit_signal('marioContactAxe')		
	elif obj.type==constants.figures:
		status=constants.stop
		animation('stand')
#		Game.emit_signal("marioCastleEnd")
		return true
	elif obj.type==constants.vine:
		if status!=constants.grabVine:
			setGrabVine(obj)
	elif obj.type==constants.mazeGate:
#		print('mazeGate')
		if obj.vaild:
			obj.vaild=false
			Game.emit_signal("mazegate",obj.mazeId,obj.gateId)
		pass

#判断左边碰撞
func leftCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box|| obj.type==constants.bridge\
	||obj.type==constants.cannon||obj.type==constants.jumpingBoard:
		if!Game.checkMapBrickIndex(obj.localx+1,\
			obj.localy)&&yVel>0&& getBottom()-obj.getTop()<constants.boxHeight:
			if (obj.type==constants.box && 	obj._visible) || obj.type==constants.brick\
			||obj.type==constants.bridge:	
				position.y=obj.getTop()-getSizeY()/2
#				position.x=obj.getRight()+getSize()/2-0.2
#				yVel=1
				return false
			
		if obj.type==constants.box&&!obj._visible:
			return false
		else:
			if xVel!=0:
				if obj.type==constants.jumpingBoard && yVel!=0:
					return false
				else:	
					return true	
	elif obj.type==	constants.goomba|| obj.type==constants.koopa||obj.type==constants.bulletBill\
	||obj.type==constants.hammerBro||obj.type==constants.beetle||obj.type==constants.flyingfish\
	||obj.type==constants.lakitu:
		if! obj._dead:
			if invincible:
				obj.startDeathJump(constants.right)
				Game.addScore(Vector2(position.x,getTop()))
				SoundsUtil.playShoot()
			else:
				if obj.status==constants.shell|| obj.status==constants.revive:
					obj.startSliding()
					Game.addScore(Vector2(position.x,getTop()),500)
					SoundsUtil.playShoot()
					obj.position.x-=abs(obj.slidingSpeed)*_delta+1
					xVel=-(abs(xVel)-abs(xVel)/4)
				else:
					if yVel>5:
						jumpOnEnemy(obj)
					else:
						if !hurtInvincible:
							if big:
								big2Small()
								setHurtInvincible()
							else:	
								startDeathJump()	
	elif obj.type== constants.mushroom || obj.type==constants.fireflower||\
		obj.type==constants.star || obj.type==constants.mushroom1up||\
		obj.type==constants.bigCoin:
		getItem(obj)
	elif obj.type==constants.pipe:
		if obj.pipeType==constants.pipeIn:
			if isOnFloor&& obj.dir==constants.left&&Input.is_action_pressed("ui_left"):
				enterPipe(obj)
			else:
				return true		
		else:		
			return true
	elif obj.type==constants.pole:	
		pass
	elif obj.type==constants.collision:
		if obj.value==constants.castlePos:
#			destroy=true
			Game.emit_signal("marioInCastle")	
	elif obj.type==constants.cheapcheap||obj.type==constants.bloober\
	||obj.type==constants.plant||obj.type==constants.spiny:
		if! obj._dead:
			if invincible:
				if obj.type==constants.plant:
					obj.hit()
				else:	
					obj.startDeathJump(constants.right)
				Game.addScore(Vector2(position.x,getTop()))
				SoundsUtil.playShoot()
			elif !hurtInvincible:
				if big:
					big2Small()
					setHurtInvincible()
				else:	
					startDeathJump()	
	elif obj.type==constants.spinFireball||obj.type==constants.bowser||obj.type==constants.fire\
		||obj.type==constants.hammer||obj.type==constants.podoboo:
		if !invincible&&!hurtInvincible:
			if big:
				big2Small()
				setHurtInvincible()
			else:	
				startDeathJump()	
	elif obj.type==constants.axe:
		print('axe')
		Game.emit_signal('marioContactAxe')		
	elif obj.type==constants.vine:
		if status!=constants.grabVine:
			setGrabVine(obj)
	elif obj.type==constants.mazeGate:
#		print('mazeGate')
		if obj.vaild:
			obj.vaild=false
			Game.emit_signal("mazegate",obj.mazeId,obj.gateId)
	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box|| obj.type==constants.bridge\
	||obj.type==constants.cannon:	
#		if xVel==0:
#			if dir==constants.left:
#				if Game.checkMapBrick(position.x+getSize()/2,position.y-getSizeY()/2):
#					position.x-=1
#			elif dir==constants.right:
#				if Game.checkMapBrick(position.x-getSize()/2,position.y-getSizeY()/2):
#					position.x+=1
		if status==constants.poleSliding:#碰到地面
			setSitBottom()
#			status=constants.sitBottomOfPole
		
		if obj.type==constants.box&&!obj._visible:
			return false
		else:	
			combo=0
			return true
	elif obj.type== constants.mushroom || obj.type==constants.fireflower||\
		obj.type==constants.star || obj.type==constants.mushroom1up||\
		obj.type==constants.bigCoin:
		getItem(obj)
	elif obj.type==constants.platform||obj.type==constants.staticPlatform: #平台
		if status!=constants.jump&&yVel>0:
			combo=0	
			return true
	elif obj.type==constants.pipe:
		combo=0	
		if obj.pipeType==constants.pipeIn:
			if obj.dir==constants.down&&Input.is_action_pressed("ui_down"):
				if position.x+rect.size.x<obj.position.x+obj.rect.size.x:
					enterPipe(obj)
				else:
					return true		
			else:
				return true	
		else:		
			return true
	elif obj.type==constants.goomba||obj.type==constants.koopa\
		||obj.type==constants.bulletBill||obj.type==constants.hammerBro\
		||obj.type==constants.beetle||obj.type==constants.flyingfish||\
		obj.type==constants.lakitu:
		jumpOnEnemy(obj)
	elif obj.type==constants.axe:
		print('axe')
		Game.emit_signal('marioContactAxe')		
	elif obj.type==constants.cheapcheap||obj.type==constants.bloober\
	||obj.type==constants.plant||obj.type==constants.spiny:
		if! obj._dead:
			if invincible:
				if obj.type==constants.plant:
					obj.hit()
				else:	
					obj.startDeathJump(constants.right)
				Game.addScore(Vector2(position.x,getTop()))
				SoundsUtil.playShoot()
			elif !hurtInvincible:
				if big:
					big2Small()
					setHurtInvincible()
				else:	
					startDeathJump()	
	elif obj.type==constants.spinFireball||obj.type==constants.bowser||obj.type==constants.fire\
	||obj.type==constants.hammer||obj.type==constants.podoboo:
#		print(obj.type)
		if !invincible&&!hurtInvincible:
			if big:
				big2Small()
				setHurtInvincible()
			else:	
				startDeathJump()	
	elif obj.type==constants.jumpingBoard: #在跳板上
		if yVel>0&&status!=constants.onBoard:
			setOnBoard(obj)
	elif obj.type==constants.mazeGate:
#		print('mazeGate')
		if obj.vaild:
			obj.vaild=false
			Game.emit_signal("mazegate",obj.mazeId,obj.gateId)

func ceilcollide(obj):#上方的判断
	if obj.type==constants.brick || obj.type==constants.box|| obj.type==constants.bridge\
	||obj.type==constants.cannon:
		#如果跟边缘发生碰撞小于2px就修改马里奥的位置
		if position.x>obj.position.x:
			if abs(getLeft()-obj.getRight())<3:
				position.x=obj.getRight()+getSize()/2
			else:
				if obj.type==constants.box:
					if obj.status==constants.resting:
						obj.startBumped(big)
					else:
						SoundsUtil.playBrickHit()	
				else:			
					SoundsUtil.playBrickHit()
				yVel=1	
		else:
			if abs(getRight()-obj.getLeft())<=3:
				position.x=obj.getLeft()-getSize()/2
			else:
				if obj.type==constants.box:
					if obj.status==constants.resting:
						obj.startBumped(big)
					else:
						SoundsUtil.playBrickHit()	
				else:			
					SoundsUtil.playBrickHit()
				yVel=1	
	elif obj.type==constants.goomba||obj.type==constants.koopa\
		||obj.type==constants.bulletBill||obj.type==constants.hammerBro\
		||obj.type==constants.beetle||obj.type==constants.flyingfish||\
		obj.type==constants.cheapcheap||obj.type==constants.bloober\
		||obj.type==constants.plant||obj.type==constants.spiny\
		||obj.type==constants.lakitu:
			if! obj._dead:
				if invincible:
					if obj.type==constants.plant:
						obj.hit()
					else:	
						obj.startDeathJump(constants.right)
					Game.addScore(Vector2(position.x,getTop()))
					SoundsUtil.playShoot()
				elif !hurtInvincible:
					if big:
						big2Small()
						setHurtInvincible()
					else:	
						startDeathJump()	
	elif obj.type== constants.mushroom || obj.type==constants.fireflower||\
		obj.type==constants.star || obj.type==constants.mushroom1up||\
		obj.type==constants.bigCoin:
		getItem(obj)
	elif obj.type==constants.spinFireball||obj.type==constants.bowser||obj.type==constants.fire\
	||obj.type==constants.hammer||obj.type==constants.podoboo:
		if !invincible&&!hurtInvincible:
			if big:
				big2Small()
				setHurtInvincible()
			else:	
				startDeathJump()	
	elif obj.type==constants.mazeGate:
#		print('mazeGate')
		if obj.vaild:
			obj.vaild=false
			Game.emit_signal("mazegate",obj.mazeId,obj.gateId)

#获取物品
func getItem(i):
	print('getItem')
	if i.type==constants.mushroom:
		i.destroy=true
		small2Big()
		SoundsUtil.playMushroom()
		Game.addScore(Vector2(position.x,getTop()),1000)
#		addScore(m,1000)
	elif i.type==constants.fireflower:
		i.destroy=true
		if big:
			big2Fire()
		else:
			small2Big()	
		Game.addScore(Vector2(position.x,getTop()),1000)	
		SoundsUtil.playMushroom()
	elif i.type==constants.star:
		i.destroy=true
		setInvincible()
		Game.addScore(Vector2(position.x,getTop()),1000)	
#		SoundsUtil.stopBgm()
#		SoundsUtil.playSpecialBgm()
		SoundsUtil.changeBgm("star")
	elif i.type==constants.mushroom1up:	
		i.destroy=true
		Game.addLive(Vector2(position.x,getTop()),playerId)	
		SoundsUtil.playItem1up()
	elif i.type==constants.bigCoin:
		i.destroy=true
		SoundsUtil.playCoin()
		Game.addCoin(Vector2(position.x,getTop()))	
	pass

#进入水管
func enterPipe(obj): 
	pipeNo=obj.pipeNo
	if obj.dir==constants.down:
		SoundsUtil.playPipe()
		active=false
		xVel=0
		yVel=40
		enterPipeY=obj.getTop()
		if big:#因为有调整y的位置
			enterPipeY+=12

		status=constants.pipeIn
	elif obj.dir==constants.right||dir==constants.left:
		SoundsUtil.playPipe()
		active=false
		status=constants.walkInPipe
		if dir==constants.left:
			xVel=-50
		else:
			xVel=50	
		yVel=0
		ani.speed_scale=1
		if dir==constants.right:
			enterPipeX=getRight()+5
		else:
			enterPipeX=getLeft()-5
		print(enterPipeX)	

func addPoleScore(polePos,obj):
	if abs(position.y-polePos)<=50:
		obj.showScore(5000)
		
	elif abs(position.y-polePos)<=100:
		obj.showScore(2000)
		
	elif abs(position.y-polePos)<=150:	
		obj.showScore(1000)

	elif abs(position.y-polePos)<=200:
		obj.showScore(500)
		
	else:
		obj.showScore(200)
	obj.startFall()
	pass

#踩到敌人
func jumpOnEnemy(obj):
#	print('jumpOnEnemy')
	if! obj._dead:
		if invincible:
			obj.startDeathJump(constants.right)
			Game.addScore(Vector2(position.x,getTop()))
			SoundsUtil.playShoot()
		else:
#			if obj.type!=constants.plant||obj.type!=constants.spiny:	
			obj.jumpedOn()
			if combo<constants.scoreList.size():
				Game.addScore(position,constants.scoreList[combo])
				combo+=1
			else:
				Game.addLive(position,playerId)
				SoundsUtil.playItem1up()	
			SoundsUtil.playStomp()	
#			yVel=- max(constants.marioJumpMinSoeed,abs(abs(yVel)-abs(yVel)/3)) 
			yVel=- constants.marioJumpMinSoeed


#动画
func animation(type):
	if type=='stand':
		if big:
			ani.play(stand_big_animation[aniIndex])
			if invincible:
				shadow.animation=stand_big_animation[shadowIndex]
		else:	
			ani.play(stand_small_animation[aniIndex])
			if invincible:
				shadow.animation=stand_small_animation[shadowIndex]
	elif type=='slide':
		if big:
			ani.play(slide_big_animation[aniIndex])
			if invincible:
				shadow.animation=slide_big_animation[shadowIndex]
		else:	
			ani.play(slide_small_animation[aniIndex])
			if invincible:
				shadow.animation=slide_small_animation[shadowIndex]
	elif type=='walk':
		if big:
			ani.play(walk_big_animation[aniIndex])
			if invincible:
				shadow.animation=walk_big_animation[shadowIndex]
		else:	
			ani.play(walk_small_animation[aniIndex])
			if invincible:
				shadow.animation=walk_small_animation[shadowIndex]
	elif type=='jump':
		if big:
			ani.play(jump_big_animation[aniIndex])
			if invincible:
				shadow.animation=jump_big_animation[shadowIndex]
		else:	
			ani.play(jump_small_animation[aniIndex])
			if invincible:
				shadow.animation=jump_small_animation[shadowIndex]
	elif type=='crouch':
		if big:
			ani.play(crouch_animation[aniIndex])	
			if invincible:
				shadow.animation=crouch_animation[shadowIndex]		
	elif type=='fire':
		if big:
			throwAniFinish=false
			ani.play(throw_animation[aniIndex])		
			if invincible:
				shadow.animation=throw_animation[shadowIndex]
	elif type=='fall':
		if invincible&&getFallAni().size()>0:
			shadow.animation=getFallAni()[shadowIndex]
	elif type=='poleSliding':
		if 	big:
			ani.play(landing_big_animation[aniIndex])	
		else:
			ani.play(landing_small_animation[aniIndex])		
	elif type=='swim':
		if 	big:
			ani.play(swim_big_animation[aniIndex])	
		else:
			ani.play(swim_small_animation[aniIndex])	
								
	if dir==constants.right && ani.flip_h:
		ani.flip_h=false
	elif dir==constants.left && !ani.flip_h:
		ani.flip_h=true	
	if invincible:
		shadow.flip_h=ani.flip_h
		shadow.speed_scale=ani.speed_scale
		shadow.position.y=ani.position.y
	pass

#获取掉落的之前的动画列表
func getFallAni():
	if ani.animation in stand_big_animation:
		return stand_big_animation
	elif ani.animation in stand_small_animation:
		return stand_small_animation
	elif ani.animation in slide_big_animation:
		return slide_big_animation
	elif ani.animation in slide_small_animation:
		return slide_small_animation
	elif ani.animation in walk_big_animation:
		return walk_big_animation
	elif ani.animation in walk_small_animation:
		return walk_small_animation
	elif ani.animation in jump_big_animation:
		return jump_big_animation
	elif ani.animation in jump_small_animation:
		return jump_small_animation
	elif ani.animation in crouch_animation:
		return crouch_animation
	elif ani.animation in throw_animation:
		return throw_animation
	elif ani.animation in swim_big_animation:
		return swim_big_animation
	elif ani.animation in swim_small_animation:
		return 	swim_small_animation
	else:
		return []	

#发射火球
func shootFireball(play=true):
	if OS.get_system_time_msecs()-shootStart>shootDelay:
		if Game.getPlayerBulletCount(playerId)<2:
			shootStart=OS.get_system_time_msecs()
			if play:
				animation("fire")
			var temp=ball.instance()
			temp.position=position
			temp.dir=dir	
			Game.addObj(temp)
			fireball.play() #声音

#添加气泡
func addBubble():
	var temp=bubble.instance()
	temp.position=position
	Game.addObj(temp)
			
#播放跳跃声音			
func playJumpSound():
	if big:
		bigjump.play()
	else:
		jump.play()

func pause():
	preStatus=status
	status=constants.stop
	active=false
	ani.stop()

func resume():
	status=preStatus
	if status!=constants.small2big||status!=constants.big2small||\
	status!=constants.deadJump||status!=constants.walkInPipe||\
	status!=constants.pipeOut||status!=constants.pipeIn||status!=constants.big2fire:
		active=true
	ani.play()

func _on_ani_frame_changed():
	if status==constants.small2big:
		if ani.frame in [0,2,4]:
			ani.position.y= 0
		else:
			ani.position.y=-15
	elif ani.animation in throw_animation:
		throwAniFinish=true
	elif status	==constants.big2small:
#		if ani.frame in [0]:
#			ani.position.y= 0
		if ani.frame in [2,4,6,8,10]:
			ani.position.y=20	
		else:
			 ani.position.y= 0
		pass
	if invincible:
		shadow.frame=ani.frame


func _on_ani_animation_finished():
	if status==constants.small2big:
		big=true
		ani.position.y=0
		status=preStatus
		active=true
		adjustBigRect()
		position.y-=17
		Game.emit_signal('marioStateFinish')
	elif status==constants.big2small:
		hurtInvincible=true
		
		big=false
		fire=false
		active=true
		if isCrouch:
			if xVel!=0:
				status=constants.stand
			else:
				status=constants.walk
			isCrouch=false  #设置成没有蹲下
			position.y+=14
		else:
			status=preStatus
			position.y+=17	
		ani.position.y= 0
		aniIndex=0
		adjustSmallRect()
		Game.emit_signal('marioStateFinish')
