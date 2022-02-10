extends "res://scripts/object.gd"


var maxXVel=constants.marioWalkMaxSpeed
var maxYVel=0
var big = false #是否变大
#var faceRight=true
var fire = false #是否能发射子弹
var status=constants.stand
var acceleration =constants.acceleration #加速度
var isOnFloor=false #是否在地面上
var dir=constants.right
var throwAniFinish=false
var playerId=1
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
var invincibleEndime=720
var invincibleAnimationTimer=0
var shadowIndex=0
var hurtInvincible=false
var hurtInvincibleStartTime=0
var hurtInvincibleEndime=420
var dead=false
var deadStartTime=0
var deadEndTime=30
var leftStop=false
var rightStop=false
var flagPoleTimer=0 #从旗杆上转身然后下来
var poleLength=0 #旗杆右边位置


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

func _ready():
	type=constants.mario
	debug=true
	if big:
		rect=Rect2(Vector2(-10,-30),Vector2(20,60))	
	else:	
		rect=Rect2(Vector2(-10,-16),Vector2(20,32))	
	gravity=constants.marioGravity
	if big && fire:
		aniIndex=2
	animation("stand")
	shadowIndex=aniIndex
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
		pass
	elif status==constants.big2small:
		pass
	elif status==constants.crouch:
		crouch(delta)
		pass
	elif status==constants.deadJump:
		deathJump(delta)	
	elif status==constants.poleSliding:
		poleSliding(delta)
		pass
	elif status==constants.walkingToCastle:
		walkingToCastle(delta)
		pass
	elif status==constants.sitBottomOfPole:
		sitBottomOfPole(delta)
		pass
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
				modulate.a=0
			else:
				modulate.a=1
		else:
			hurtInvincible=false
			hurtInvincibleStartTime=0
			modulate.a=1
		hurtInvincibleStartTime+=1
		pass

func setInvincible():
	invincible=true
	invincibleStartTime=0
	shadow.visible=true

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
		print("stand jump")
	if Input.is_action_just_pressed("ui_down") &&big:
		startCrouch()
		return
	if Input.is_action_just_pressed("ui_action")&&fire:
		shootFireball()
		pass
	
	if !isOnFloor:
#		position.y+=yVel*delta	
		status=constants.fall
		
	pass



func walk(delta):
	yVel+=gravity*delta
	if xVel>0:
		ani.speed_scale=1+xVel/constants.marioAniSpeed
	elif xVel<0:
		ani.speed_scale=1+xVel/constants.marioAniSpeed*-1
#	else:
#		ani.speed_scale=1
	
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
#		print('walk jump')
		return
	
	if Input.is_action_just_pressed("ui_down") &&big:
		startCrouch()
		return
	
	if Input.is_action_pressed("ui_left"):
		if xVel>0: #反方向
			animation("slide")
			acceleration=constants.slideFriction
		else:
			acceleration=constants.acceleration
#			faceRight=false
			dir=constants.left
			animation('walk')
			
		if xVel>-maxXVel:
			xVel-=acceleration
		elif xVel<-maxXVel:
			xVel+=acceleration
	elif Input.is_action_pressed("ui_right"):
		if xVel<0:
			animation("slide")
			acceleration=constants.slideFriction
		else:
			dir=constants.right
			acceleration=constants.acceleration
			animation('walk')
			
		if xVel<maxXVel:
			xVel+=acceleration
		elif xVel>maxXVel:
			xVel-=acceleration
	else:
		if dir==constants.right:
			if	xVel>0:
				xVel-=acceleration
				animation("walk")
			else:
				xVel=0
				ani.speed_scale=1
				status=constants.stand	
		else:
			if xVel<0:
				xVel+=acceleration
				animation("walk")
			else:
				xVel=0
				ani.speed_scale=1
				status=constants.stand	
	if 	(xVel>0 && !rightStop)||(xVel<0&& !leftStop):			
		position.x+=xVel*delta
		
#	position.y+=yVel*delta	
	if !isOnFloor:
		ani.stop()
		status=constants.fall
	pass

func jump(delta):
	yVel+=gravity*delta
	animation("jump")
#	print(yVel)
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
			xVel-=acceleration
	elif Input.is_action_pressed("ui_right"):
		if xVel<maxXVel:
			xVel+=acceleration
		
	position.x+=xVel*delta
	position.y+=yVel*delta	
	pass

func fall(delta):
	yVel+=gravity*delta
	animation("fall")
	if Input.is_action_pressed("ui_left"):
		if xVel>-maxXVel:
			xVel-=acceleration
	elif Input.is_action_pressed("ui_right"):
		if xVel<maxXVel:
			xVel+=acceleration	
	if Input.is_action_just_pressed("ui_action")&&fire:
		shootFireball(false)		
	position.x+=xVel*delta
	position.y+=yVel*delta	
	
	if isOnFloor:
		status = constants.walk
#		print('fall end')			
	pass

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

func startCrouch():
	status=constants.crouch	
	rect=Rect2(Vector2(-10,-15),Vector2(20,30))	
	position.y+=15  #不能到边界
#	position.y+=16
#	rect.size.y-=32
	ani.position.y-=15
	
func crouch(delta):
	yVel+=gravity*delta
	animation("crouch")
	if Input.is_action_just_pressed("ui_action")&&fire:
		shootFireball(false)
		
	if Input.is_action_just_released("ui_down"):
		status=constants.walk	
		rect=Rect2(Vector2(-10,-30),Vector2(20,60))	
		position.y-=15
#		rect.size.y+=32
		ani.position.y=0
		pass
	elif Input.is_action_pressed("ui_jump"):
		yVel=-constants.marioJumpSpeed
		gravity=constants.marioJumpGravity
		status=constants.jump
		pass
		
	if dir==constants.right:
		if	xVel>0:
			xVel-=acceleration
		else:
			xVel=0
			ani.speed_scale=1
	else:
		if xVel<0:
			xVel+=acceleration
		else:
			xVel=0
			ani.speed_scale=1		
	position.x+=xVel*delta
	position.y+=yVel*delta
	pass

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
#	print(name)
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
	self.poleLength=length
	pass

func poleSliding(delta):
	yVel+=7
	position.y+=yVel*delta
	animation("poleSliding")
	pass

func setSitBottom():
	ani.frame=0
	ani.stop()
	status=constants.sitBottomOfPole
#	position.x=position.x+poleLength+getSize()
#	ani.flip_h=true

func sitBottomOfPole(_delta):
#	if flagPoleTimer==31:
#		position.x=position.x+poleLength+getSize()
#		ani.flip_h=true
#		pass
#	elif flagPoleTimer>80:
#		dir=constants.right
#		xVel=0
#		acceleration=constants.acceleration
#		status=constants.walkingToCastle
#
#	flagPoleTimer+=1			
	pass

func setwalkingToCastle():
	status=constants.walkingToCastle

func walkingToCastle(delta):
	if flagPoleTimer==31:
		position.x=position.x+poleLength+getSize()
		ani.flip_h=true
		pass
	elif flagPoleTimer<80:
		dir=constants.right
		xVel=0
		acceleration=constants.acceleration
#		status=constants.walkingToCastle
	else:
		xVel+=5
		yVel+=gravity*delta
		if xVel>0:
			ani.speed_scale=1+xVel/constants.marioAniSpeed
		elif xVel<0:
			ani.speed_scale=1+xVel/constants.marioAniSpeed*-1
		if xVel>maxXVel:
			xVel-=acceleration	
		position.x+=xVel*delta
		if !isOnFloor:
			position.y+=yVel*delta
		animation("walk")	
	flagPoleTimer+=1	
	pass

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

func shootFireball(play=true):
	if OS.get_system_time_msecs()-shootStart>shootDelay:
		if Game.getPlayerBulletCount(playerId)<2:
			shootStart=OS.get_system_time_msecs()
			if play:
				animation("fire")
			Game.addObj2Bullet(position,dir)
			


func _on_ani_frame_changed():
	if status==constants.small2big:
		print(ani.frame)
		if ani.frame in [0,2,4]:
			ani.position.y= 0
		else:
			ani.position.y=-20
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
		ani.position.y= 0
		status=preStatus
		rect=Rect2(Vector2(-10,-30),Vector2(20,60))	
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
		pass
	pass # Replace with function body.
