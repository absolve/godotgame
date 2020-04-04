extends KinematicBody2D


var speed = constants.mario_speed  #移动速度
var jump_speed = constants.jumpSpeed #跳跃
var gravity=constants.gravity #重力
var velocity = Vector2.ZERO	#速度
var acceleration = constants.acceleration	#加速度
var faceRight=true	#面向右边
var animation_speed=1 #动画速度
#var dropSpeed=constants.dropSpeed	#下落最大速度

var big = false #是否是变大的状态
var fire = false #发射子弹

#动画列表
var idle_small_animation=['idle_small','idle_small_red','idle_small_black']
var idle_big_animation=['idle_big','idle_big_red','idle_big_black']



#mario状态
var status=constants.idle

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if status==constants.idle:
		idle(delta)
		pass
	elif status==constants.walk:
		walk(delta)
		pass
	elif status==constants.fall:
		fall(delta)
		pass
	elif status==constants.jump:
		jump(delta)
	elif status==constants.small2big:#变大状态
		small2big(delta)
		


#在进入站着状态之前
func beforeIdle()->void:
	velocity = Vector2.ZERO
	status=constants.idle
	

#站着
func idle(delta):
	#$ani.speed_scale=1
	if big:
		$ani.play("idle_big")
	else:
		$ani.play("idle_small")
		
	#发射子弹
	if Input.is_action_just_pressed("ui_action"):
		pass
	
	if Input.is_action_pressed("ui_left"):
		faceRight=false
		status = constants.walk
	elif Input.is_action_pressed("ui_right"):
		faceRight=true
		status = constants.walk
	elif Input.is_action_just_pressed("ui_jump"):
		#beforeJump()
		status = constants.small2big
		
	if not is_on_floor():	#不在地面上
		status=constants.fall
	
#移动
func walk(delta):
	
	#计算动画速度
	if round(velocity.x)==0:
		animation_speed = 1.3
	elif velocity.x>0:
		animation_speed=1+velocity.x/constants.animation_speed
	else:
		animation_speed=1+velocity.x/constants.animation_speed*-1
	print(animation_speed)
	$ani.speed_scale=animation_speed
	
	
	if Input.is_action_pressed("ui_action"):
		acceleration=constants.runAccel
		speed = constants.mario_max_speed
	else:
		acceleration=constants.acceleration
		speed = constants.mario_speed
	
	#跳跃
	if Input.is_action_just_pressed("ui_jump"):
		print("jump")
		beforeJump()
	
	if Input.is_action_pressed("ui_left"):
		if velocity.x>0:
			$ani.play("slide_small")
			acceleration=constants.friction
		else:
			faceRight=false
			acceleration=constants.acceleration
			$ani.flip_h=true
			$ani.play("run_small")
		#velocity.x = lerp(velocity.x, -1 * speed, acceleration)	
		if velocity.x>-speed:
			velocity.x-=acceleration
		elif velocity.x<-speed:
			velocity.x+=acceleration
		velocity = move_and_slide(velocity, Vector2.UP)
	elif Input.is_action_pressed("ui_right"):
		if velocity.x<0:	#这个时候速度还没有大于0
			$ani.play("slide_small")
			acceleration=constants.friction
		else:
			faceRight=true
			acceleration=constants.acceleration
			$ani.flip_h=false
			$ani.play("run_small")
		if velocity.x<speed:
			velocity.x+=acceleration
		elif velocity.x>speed:
			velocity.x-=acceleration
		#velocity.x = lerp(velocity.x,  speed, acceleration)	
		velocity = move_and_slide(velocity, Vector2.UP)
	else: #没有按键
		print("speed ",velocity.x)
		print("a ",acceleration)
		if faceRight:
			if velocity.x>0:
				velocity.x-=acceleration
			else:
				velocity.x=0
				status=constants.idle
		else:
			if velocity.x<0:
				velocity.x+=acceleration
			else:
				velocity.x=0
				status=constants.idle
		print("speed ",velocity.x)
		velocity = move_and_slide(velocity, Vector2.UP)


#在进入跳跃状态之前设置数据
func beforeJump()->void:
	velocity.y=-jump_speed
	status=constants.jump
	gravity = constants.gravityJump
		
#跳跃
func jump(delta):
	#gravity = constants.gravityJump
	velocity.y+=gravity*delta
	$ani.play("jump_small")
	
	if velocity.y>=0 :
		print(11111111)
		gravity=constants.gravity
		status=constants.fall
	
	if Input.is_action_just_released("ui_jump"):
		print("2121")
		gravity = constants.gravity
	
	if Input.is_action_pressed("ui_left"):
		if velocity.x>-speed:
			velocity.x-=acceleration
	elif Input.is_action_pressed("ui_right"):
		if velocity.x<speed:
			velocity.x+=acceleration
			
	velocity = move_and_slide(velocity, Vector2.UP)

#下降
func fall(delta):
		
	velocity.y+=gravity*delta
	
	if Input.is_action_pressed("ui_left"):
		if velocity.x>-speed:
			velocity.x-=acceleration
	elif Input.is_action_pressed("ui_right"):
		if velocity.x<speed:
			velocity.x+=acceleration
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		status=constants.walk

#变大	
func small2big(delta):
	
	$ani.play("power_up")
	yield($ani,"animation_finished")
	$ani.offset.y=-16
	status=constants.idle
	big=true
	
	
