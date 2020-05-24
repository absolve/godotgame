extends Area2D


var speed = constants.mario_speed  #移动速度
var jump_speed = constants.jumpSpeed #跳跃
var _gravity=constants.gravity #重力
var velocity = Vector2.ZERO	#速度
var acceleration = constants.acceleration	#加速度
var faceRight=true	#面向右边
var animation_speed=1 #动画速度
#var dropSpeed=constants.dropSpeed	#下落最大速度
var isCrouch=false 	#是否蹲下
var toFireTime=0 #变成开火的时间


export var big = false #是否是变大的状态
export var fire = false #发射子弹
var invincible=false  #是否无敌
var hurtInvincible=false #受伤无敌


#动画列表
var idle_small_animation=['idle_small','idle_small_red','idle_small_black']
var jump_small_animation=['jump_small','jump_small_red','jump_small_black']
var run_small_animation=['run_small','run_small_red','run_small_black']
var slide_small_animation=['slide_small','slide_small_red','slide_small_black']
var idle_big_animation=['idle_big','idle_big_red','idle_big_black']
var jump_big_animation=['jump_big','jump_big_red','jump_big_black']
var run_big_animation=['run_big','run_big_red','run_big_black']
var slide_big_animation=['slide_big','slide_big_red','slide_big_black']
var crouch_animation = ['crouch','crouch_red','crouch_black']
var fire_animation=['fire','fire_red','fire_black']


var index=0 #默认设置动画列表为0  1是红色  2是黑色

#mario状态
var status=constants.stand
var preStatus=constants.stand

#形状大小
var smallShape=Vector2(13,16)
var bigShape=Vector2(16,32)


var currentAnimation  #当前动画列表
var invincibleStartTime=0	 #无敌开始时间 12s左右
var invincibleAnimationTimer=0 #定时器

func _ready():
	pass

func _physics_process(delta):
	if status==constants.stand:
		stand(delta)
	elif status==constants.walk:
		walk(delta)
	elif status==constants.fall:
		fall(delta)
	elif status==constants.jump:
		jump(delta)
	elif status==constants.small2big:#变大状态
		small2big(delta)
	elif status==constants.crouch:	#蹲着
		crouch(delta)
	elif status==constants.big2fire:
		big2fire(delta)
	#特殊状态
	specialState(delta)


#在进入站着状态之前
func beforeStand()->void:
	velocity = Vector2.ZERO
	$ani.speed_scale=1
	status=constants.stand
	

#站着
func stand(delta):
	#$ani.speed_scale=1
	if $ani.animation==fire_animation[index]:
		if $ani.frame==1:
			animation("stand")
	else:
		animation("stand")
	#发射子弹
	if Input.is_action_just_pressed("ui_action"):
		animation("fire")
		pass

	if Input.is_action_just_pressed("ui_down") and big:	#只有变大的情况才能蹲
		beforeCrouch()

	if Input.is_action_pressed("ui_left"):
		faceRight=false
		status = constants.walk
	elif Input.is_action_pressed("ui_right"):
		faceRight=true
		status = constants.walk
	elif Input.is_action_just_pressed("ui_jump"):
		beforeJump()
		#beforeSmall2big()

	velocity.y+=_gravity*delta
	#velocity = move_and_slide(velocity, Vector2.UP)
	
	if $ray.is_colliding():
		velocity.y=0
		position +=velocity*delta
	else:
		position +=velocity*delta
	

#	if not is_on_floor():	#不在地面上
#		print("stand  not is_on_floor")
#		status=constants.fall

#移动
func walk(delta):
	velocity.y+=_gravity*delta
	#计算动画速度
	if round(velocity.x)==0:	#如果遇到墙壁等 速度就不变化
		pass
	elif velocity.x>0:
		animation_speed=1+velocity.x/constants.animation_speed
	else:
		animation_speed=1+velocity.x/constants.animation_speed*-1
	#print(animation_speed)
	$ani.speed_scale=animation_speed


	if Input.is_action_pressed("ui_action"):
		acceleration=constants.runAccel
		speed = constants.mario_max_speed
		#animation("fire")
	else:
		acceleration=constants.acceleration
		speed = constants.mario_speed
		#animation("fire")

	#跳跃
	if Input.is_action_pressed("ui_jump"):
		print("jump")
		beforeJump()
		return

	if Input.is_action_pressed("ui_down") and big:
		print("Crouch")
		beforeCrouch()
		return
	elif isCrouch and big:	#还原大小回去
		$ani.position.y=-16
		isCrouch=false
		adjustShape("crouch")


	if Input.is_action_pressed("ui_left"):
		if velocity.x>0:
			#$ani.play("slide_small")
#			print("velocity.x>0")
			animation("slide")
			acceleration=constants.friction
		#	print('new',acceleration)
		else:
			faceRight=false
			acceleration=constants.acceleration
			$ani.flip_h=true
			#$ani.play("run_small")
			animation("walk")
		#velocity.x = lerp(velocity.x, -1 * speed, acceleration)
		if velocity.x>-speed:
			velocity.x-=acceleration
		elif velocity.x<-speed:
			velocity.x+=acceleration
		#velocity = move_and_slide(velocity, Vector2.UP)
	elif Input.is_action_pressed("ui_right"):
		if velocity.x<0:	#这个时候速度还没有大于0
			animation("slide")
			acceleration=constants.friction
		else:
			faceRight=true
			acceleration=constants.acceleration
			$ani.flip_h=false
			#$ani.play("run_small")
			animation("walk")
		if velocity.x<speed:
			velocity.x+=acceleration
		elif velocity.x>speed:
			velocity.x-=acceleration
		#velocity.x = lerp(velocity.x,  speed, acceleration)
		#velocity = move_and_slide(velocity, Vector2.UP)
	else: #没有按键
		#print("acceleration",acceleration)
		if faceRight:
			if velocity.x>0:
				velocity.x-=acceleration
				animation("walk")
			else:
				velocity.x=0
				beforeStand()
				#status=constants.stand
		else:
			if velocity.x<0:
				velocity.x+=acceleration
				animation("walk")
			else:
				velocity.x=0
				beforeStand()
				#status=constants.stand
		#print("speed ",velocity.x)

	
	position+=velocity*delta

	if not $ray.is_colliding():
		$ani.stop()
		preStatus = constants.walk
		status=constants.fall

#	velocity = move_and_slide(velocity, Vector2.UP)
#
#	if not is_on_floor():	#不在地面上
#		print("is_on_floor")
#		$ani.stop()
#		preStatus = constants.walk
#		status=constants.fall
#



#在进入跳跃状态之前设置数据
func beforeJump()->void:
#	if Input.is_action_pressed("ui_down") and big:
#		animation("crouch")
#	else:
#		animation("jump")
	print('beforeJump')
	velocity.y=-jump_speed
	status=constants.jump
	_gravity = constants.gravityJump
	#$ani.play("jump_small")


#跳跃
func jump(delta):
	#gravity = constants.gravityJump
	velocity.y+=_gravity*delta
#	print(212121)
#	print("-------------",velocity.y)
	if isCrouch:
		animation("crouch")
	else:
		animation("jump")

	if velocity.y>=0 :	#状态变化
		_gravity=constants.gravity
		preStatus= constants.jump
		status=constants.fall

	if Input.is_action_just_released("ui_jump"):#如果跳跃键放开重力修改
#		print("2121")
		_gravity = constants.gravity

	if Input.is_action_pressed("ui_left"):
		if velocity.x>-speed:
			velocity.x-=acceleration
	elif Input.is_action_pressed("ui_right"):
		if velocity.x<speed:
			velocity.x+=acceleration

	
	position+=velocity*delta
	
#	velocity = move_and_slide(velocity, Vector2.UP)



#下降
func fall(delta):
#	if isCrouch:
#		animation("crouch")
#	else:
#		animation("jump")
	print('fall')
	#判断之前的状态
	if preStatus==constants.jump:
		if isCrouch:
			animation("crouch")
		else:
			animation("jump")
		pass
	elif preStatus==constants.walk:
		if big:		#如果是滑行的动作就全部换成行走的动画
			if $ani.animation in slide_big_animation:
				$ani.frame=0
				$ani.animation=run_big_animation[index]
			else:
				$ani.animation=run_big_animation[index]
		else:
			if $ani.animation in slide_small_animation:
				$ani.frame=0
				$ani.animation=run_small_animation[index]
			else:
				$ani.animation=run_small_animation[index]
		pass
	
	
	velocity.y+=_gravity*delta

	if Input.is_action_pressed("ui_left"):
		if velocity.x>-speed:
			velocity.x-=acceleration
	elif Input.is_action_pressed("ui_right"):
		if velocity.x<speed:
			velocity.x+=acceleration
	#velocity = move_and_slide(velocity, Vector2.UP)

	position+=velocity*delta

	if $ray.is_colliding():
		status=constants.walk

#	if is_on_floor():
#		status=constants.walk


#进入蹲着状态之前
func beforeCrouch():
	print(1111)
	status=constants.crouch
	$ani.position.y=-6
	isCrouch=true
	adjustShape("crouch")
#	animation("crouch")


#蹲着
func crouch(delta):
	animation("crouch")
	if Input.is_action_released("ui_down"):
		$ani.position.y=-16
		status=constants.walk
		isCrouch=false
		adjustShape("big")
		#beforeStand()
	elif Input.is_action_pressed("ui_jump"):
		beforeJump()

	if faceRight:
		if velocity.x>0:
			velocity.x-=acceleration
		else:
			velocity.x=0
#		else:
#			velocity.x=0
#			beforeStand()
			#status=constants.stand
	else:
		if velocity.x<0:
			velocity.x+=acceleration
		else:
			velocity.x=0
#		else:
#			velocity.x=0
#			beforeStand()
			#status=constants.stand
	position+=velocity*delta
	#velocity = move_and_slide(velocity, Vector2.UP)



#在变化之前
func beforeSmall2big():
	status = constants.small2big
	$ani.play("power_up")
	$ani.connect("frame_changed",self,"_on_frame_changed")

#变大
func small2big(delta):
#	yield($ani,"animation_finished")
#	status=constants.idle
	pass

#判断frame
func _on_frame_changed():
	print($ani.frame)
	if $ani.frame in [1,3,5,7]:
		$ani.position.y=-8
	elif $ani.frame in [2,4,8,10]:
		$ani.position.y=0
	elif $ani.frame in [6,9,11]:
		$ani.position.y=-16

	if $ani.frame==11:	#最后一帧
		$ani.disconnect("frame_changed",self,"_on_frame_changed")
		big=true
		#beforeStand()
		adjustShape("big")
		status=constants.walk
		index=0

#开始之前的准备
func beforebig2fire()->void:
	print(status)
	if !big:
		return

	preStatus = status
	status = constants.big2fire
	$ani.stop()
	#获取动画列表进行变化
	var name=$ani.animation
	print(name)
	var animationLisr = ['idle_big','jump_big',
						'run_big','slide_big',
						'crouch']
	for ani in animationLisr:
		if ani in name:
			print(ani)
			if ani =='idle_big':
				currentAnimation = idle_big_animation
			elif ani=='jump_big':
				currentAnimation=jump_big_animation
			elif ani=='run_big':
				currentAnimation=run_big_animation
			elif ani=='slide_big':
				currentAnimation=slide_big_animation
			elif ani=='crouch':
				currentAnimation=crouch_animation
	toFireTime=0



#变成开火形态
func big2fire(delta):

	toFireTime+=delta*1800

	if toFireTime<=200:
		print(111)
		$ani.animation=currentAnimation[1]
	elif toFireTime<=400:
		$ani.animation=currentAnimation[0]
	elif toFireTime<=600:
		$ani.animation=currentAnimation[2]
	elif toFireTime<=800:
		$ani.animation=currentAnimation[1]
	elif toFireTime<=1000:
		$ani.animation=currentAnimation[0]
	elif toFireTime<=1200:
		$ani.animation=currentAnimation[2]
	elif toFireTime<=1400:
		$ani.animation=currentAnimation[1]
	elif toFireTime<=1600:
		$ani.animation=currentAnimation[0]
	elif toFireTime<=1800:
		$ani.animation=currentAnimation[2]
	elif toFireTime<=2000:
		$ani.animation=currentAnimation[1]
	elif toFireTime<=2200:
		$ani.animation=currentAnimation[0]
	elif toFireTime<=2400:
		$ani.animation=currentAnimation[2]
	elif toFireTime<=2600:
		$ani.animation=currentAnimation[1]
	elif toFireTime<=2800:	#结束
		index=1
		status = preStatus


#特殊状态
func specialState(delta)->void:
	if invincible: #无敌
		invincibleAnimationTimer+=1
		if OS.get_unix_time()-invincibleStartTime<=10:
			if invincibleAnimationTimer%7==0:
				if index==2:
					index=0
				else:
					index+=1	
		elif OS.get_unix_time()-invincibleStartTime<=12:
			if invincibleAnimationTimer%10==0:
				if index==2:
					index=0
				else:
					index+=1
		else:
			invincible=false
			if fire:
				index=1
			else:
				index=0
	elif hurtInvincible: #受伤无敌
		pass


#设置无敌
func setInvincible():
	if !invincible:
		invincible=true
		invincibleStartTime=OS.get_unix_time()
		invincibleAnimationTimer=0




#设置形状大小
func adjustShape(shape:String)->void:
	if shape=="big":
		$shape.scale.x=1.3
		$shape.scale.y=2
		$shape.position.y=-16
	elif shape=="crouch":
		$shape.scale.x=1.2
		$shape.scale.y=1
		$shape.position.y=0
	elif shape=="small":
		$shape.scale.x=1
		$shape.scale.y=1
		$shape.position.y=0


#动画效果
func animation(name:String)->void:
	if name=="stand":
		if big:
			$ani.play(idle_big_animation[index])
		else:
			$ani.play(idle_small_animation[index])
	elif name=="walk":
		if big:
			$ani.play(run_big_animation[index])
		else:
			$ani.play(run_small_animation[index])
	elif name=="jump":
		if big:
			$ani.play(jump_big_animation[index])
		else:
			$ani.play(jump_small_animation[index])
	elif name=="slide":
		if big:
			$ani.play(slide_big_animation[index])
		else:
			$ani.play(slide_small_animation[index])
	elif name=="small2big":
		pass
	elif name=="big2fire":
		pass
	elif name=="big2small":
		pass
	elif name=="crouch":
		if big:
			$ani.play(crouch_animation[index])
	elif name=="fire":
		if big:
			print(fire_animation[index])
			#$ani.play("fire")
			$ani.play(fire_animation[index])



func _on_mario_body_entered(body):
	velocity.y=0
	print(1111111111111)
	pass # Replace with function body.
