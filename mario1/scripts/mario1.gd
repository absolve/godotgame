extends "res://scripts/object.gd"


var maxXVel=constants.marioWalkMaxSpeed
var maxYVel=constants.marioMaxYVel #y轴最大速度
var big = false #是否变大
#var faceRight=true
var fire = false #是否能发射子弹
var status=constants.stand
var acceleration =constants.acceleration #加速度
var isOnFloor=true #是否在地面上
var dir=constants.right
var throwAniFinish=false
var playerId=1  #玩家id
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
var poleLength=0 #旗杆右边位置
var isCrouch=false 	#是否蹲下

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

							
var aniIndex=0	#动画索引					
onready var ani=$ani
onready var shadow=$shadow
onready var jump=$jump
onready var bigjump=$bigjump
onready var fireball=$fireball

func _ready():
#	status=constants.stop
	type=constants.mario
#	debug=true
	if big:
		rect=Rect2(Vector2(-11,-30),Vector2(22,60))	
		position.y-=14
	else:	
		rect=Rect2(Vector2(-10,-16),Vector2(20,32))	
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
	pass 


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
#		yVel=40
#		position.y+=yVel*delta	
		pipeIn(delta)
		pass	
	elif status==constants.walkInPipe:
		walkIntoPipe(delta)
#		if dir==constants.left:
#			xVel=-50
#		elif dir==constants.right:
#			xVel=50
#		animation('walk')	
#		position.x+=xVel*delta
		pass
	elif status==constants.pipeOut:
#		yVel=-40
#		position.y+=yVel*delta	
		pipeOut(delta)	
	if status!=constants.big2small&&status!=constants.big2fire&&\
		status!=constants.small2big:	
		specialState(delta)
	if debug:	
		update()	
	pass
	
func specialState(_delta):
	if invincible:
		if invincibleEndime-invincibleStartTime>200:
			if invincibleStartTime%6==0:
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
	xVel=0
	yVel=0
#	yVel+=gravity*delta
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
		yVel=-constants.marioJumpSpeed
		gravity=constants.marioJumpGravity
		status=constants.jump
		playJumpSound()
#		print("stand jump")
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
#	yVel+=gravity*delta
#	if xVel>0:
#		ani.speed_scale=1+xVel/constants.marioAniSpeed
#	elif xVel<0:
#		ani.speed_scale=1+xVel/constants.marioAniSpeed*-1
#	else:
#		ani.speed_scale=1
	if xVel>0 || xVel<0:
		ani.speed_scale=1+abs(xVel)/constants.marioAniSpeed
	
	if Input.is_action_pressed("ui_action"):
		acceleration=constants.runAcceleration
		maxXVel=constants.marioRunMaxSpeed
		if fire&&allowShoot:
			shootFireball(false)
			allowShoot=false
	else:
		acceleration=constants.acceleration
		maxXVel=constants.marioWalkMaxSpeed	
		allowShoot=true
		
	#跳跃
	if Input.is_action_pressed("ui_jump"):
		yVel=-constants.marioJumpSpeed
		gravity=constants.marioJumpGravity
		status=constants.jump
		playJumpSound()
#		print('walk jump')
		return
	
	if Input.is_action_pressed("ui_down") &&big:
		startCrouch()
		return
	elif isCrouch and big:
		rect=Rect2(Vector2(-11,-30),Vector2(22,60))	
		position.y-=14
		ani.position.y=0
		isCrouch=false
	
	if Input.is_action_pressed("ui_left"):
		if xVel>0: #反方向
			animation("slide")
			acceleration=constants.slideFriction
		else:
			acceleration=constants.acceleration
			dir=constants.left
			animation('walk')
			
#		if xVel>-maxXVel:
#			xVel-=acceleration*delta
#		elif xVel<-maxXVel:
#			xVel+=acceleration*delta
		if 	xVel>-maxXVel:
			xVel-=acceleration*delta
		else:
			xVel=-maxXVel
			
	elif Input.is_action_pressed("ui_right"):
		if xVel<0:
			animation("slide")
			acceleration=constants.slideFriction
		else:
			dir=constants.right
			acceleration=constants.acceleration
			animation('walk')
			
#		if xVel<maxXVel:
#			xVel+=acceleration*delta
#		elif xVel>maxXVel:
#			xVel-=acceleration*delta
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
#				xVel=0
				ani.speed_scale=1
				status=constants.stand	
		else:
			if xVel<0:
				xVel+=acceleration*delta
				animation("walk")
			else:
#				xVel=0
				ani.speed_scale=1
				status=constants.stand	
		
	position.x+=xVel*delta
		
#	position.y+=yVel*delta	
	if !isOnFloor:
		ani.stop()
		status=constants.fall
	pass

func jump(delta):
	yVel+=gravity*delta
	
	if isCrouch:
		animation("crouch")
	else:
		animation("jump")	
	if yVel>0:
		gravity=constants.marioGravity
		status=constants.fall	
#		print('jump')
		return
		
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
		
	position.x+=xVel*delta
	position.y+=yVel*delta	

func fall(delta):
	if yVel<maxYVel:
		yVel+=gravity*delta
	animation("fall")
	if Input.is_action_pressed("ui_left"):
		if xVel>-maxXVel:
			xVel-=acceleration*delta
	elif Input.is_action_pressed("ui_right"):
		if xVel<maxXVel:
			xVel+=acceleration*delta
	if Input.is_action_just_pressed("ui_action")&&fire:
		shootFireball(false)		
	position.x+=xVel*delta
	position.y+=yVel*delta	
	
	if isOnFloor:
		status = constants.walk		


#开始死亡跳跃
func startDeathJump():
	status=constants.deadJump
	dead=true
	yVel=-500
	gravity=constants.marioDeathGravity
	Game.emit_signal("stateChange")
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
	pass

#开始蹲下
func startCrouch():
	status=constants.crouch	
	if !isCrouch:
		rect=Rect2(Vector2(-11,-15),Vector2(22,30))	
		position.y+=14  #
		ani.position.y-=8
	acceleration=constants.crouchFriction	
	isCrouch=true
	
func crouch(delta):
	yVel+=gravity*delta
	animation("crouch")
	if Input.is_action_just_pressed("ui_action")&&fire:
		shootFireball(false)
		
	if Input.is_action_just_released("ui_down"):
		status=constants.walk	
		rect=Rect2(Vector2(-11,-30),Vector2(22,60))	
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
	position.x+=xVel*delta
	position.y+=yVel*delta
	pass

func pipeIn(delta):
	yVel=40
	position.y+=yVel*delta	
	pass

func pipeOut(delta):
	yVel=-40
	position.y+=yVel*delta
	pass

func walkIntoPipe(delta):
	if dir==constants.left:
			xVel=-50
	elif dir==constants.right:
		xVel=50
	animation('walk')	
	position.x+=xVel*delta

#变大
func small2Big():
	if big:
		return
	if hurtInvincible:
		modulate.a=1
	preStatus=status
	status=constants.small2big
	ani.play("small2big")
	ani.speed_scale=1
	Game.emit_signal("stateChange")
	pass

#变成开火状态
func big2Fire():
	if fire:
		return
	if hurtInvincible:
		modulate.a=1	
	preStatus=status
	status=constants.big2fire
	Game.emit_signal("stateChange")
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
		Game.emit_signal('stateFinish')

#变小
func big2Small():
	preStatus=status
	status=constants.big2small
	ani.speed_scale=1
	ani.play("big2small")
	Game.emit_signal("stateChange")
	pass

#开始在旗杆上滑动
func startSliding(length=0):
	status=constants.poleSliding
	animation("poleSliding")
	ani.frame=0
	ani.stop()
	xVel=0
	yVel=0
	dir=constants.right
#	ani.flip_h=true
	self.poleLength=length
	pass

func poleSliding(delta):
	yVel=220
	position.y+=yVel*delta
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
	pass

#设置走到城堡里面
func setwalkingToCastle():
#	ani.frame=0
	ani.stop()
	status=constants.walkingToCastle
	acceleration=constants.acceleration
	maxXVel=constants.marioWalkMaxSpeed	

func walkingToCastle(delta):
	if flagPoleTimer==31:
		position.x=position.x+poleLength+getSize()
		ani.flip_h=true
		pass
	elif flagPoleTimer<80: #更换到旗杆的另一个侧
		dir=constants.right
		xVel=0
		acceleration=constants.acceleration
#		status=constants.walkingToCastle
	else:
#		xVel+=5
		yVel+=gravity*delta
		if xVel>0 || xVel<0:
			ani.speed_scale=1+abs(xVel)/constants.marioAniSpeed
#		if xVel>0:
#			ani.speed_scale=1+xVel/constants.marioAniSpeed
#		elif xVel<0:
#			ani.speed_scale=1+xVel/constants.marioAniSpeed*-1
		if xVel<maxXVel:
			xVel+=5
		position.x+=xVel*delta
		if !isOnFloor:
			position.y+=yVel*delta
		animation("walk")	
	flagPoleTimer+=1	
	pass

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
		pass
	elif type=='poleSliding':
		if 	big:
			ani.play(landing_big_animation[aniIndex])	
		else:
			ani.play(landing_small_animation[aniIndex])		
								
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
	else:
		return []	

#发射火球
func shootFireball(play=true):
	if OS.get_system_time_msecs()-shootStart>shootDelay:
		if Game.getPlayerBulletCount(playerId)<2:
			shootStart=OS.get_system_time_msecs()
			if play:
				animation("fire")
			Game.addObj2Bullet(position,dir)
			fireball.play()
			
#播放跳跃声音			
func playJumpSound():
	if big:
		bigjump.play()
	else:
		jump.play()

func _on_ani_frame_changed():
	if status==constants.small2big:
#		print(ani.frame)
		if ani.frame in [0,2,4]:
			ani.position.y= 0
		else:
			ani.position.y=-18
	elif ani.animation in throw_animation:
		throwAniFinish=true
	elif status	==constants.big2small:
		if ani.frame in [0]:
			ani.position.y= 0
		elif ani.frame in [2,4,6,8]:
			ani.position.y=20	
		else:
			 ani.position.y= 0
		pass
	if invincible:
		shadow.frame=ani.frame
	pass # Replace with function body.


func _on_ani_animation_finished():
	if status==constants.small2big:
		big=true
		ani.position.y=0
		status=preStatus
		rect=Rect2(Vector2(-11,-30),Vector2(22,60))	
		Game.emit_signal('stateFinish')
	elif status==constants.big2small:
		hurtInvincible=true
		status=preStatus
		big=false
		fire=false
		position.y+=15
		aniIndex=0
		rect=Rect2(Vector2(-10,-16),Vector2(20,32))	
		Game.emit_signal('stateFinish')
	
	pass # Replace with function body.
