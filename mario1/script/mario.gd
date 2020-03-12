extends KinematicBody2D


var speed = constants.mario_speed  #移动速度
#var maxSpeed=200 #加速最大速度
var jump_speed = 800 #跳跃
var gravity=1500 #重力
var velocity = Vector2.ZERO	#速度
#var friction = 4 #摩檫力
var acceleration = constants.acceleration	#加速度
var faceRight=true	#面向右边
var animation_speed=1 #动画速度

var shapeSize=Vector2(30,32)
var shapeSizelvup=Vector2(30,64)
#动画列表
var idle_small_animation=['idle_small','idle_small_red','idle_small_black']
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
		jump(delta)
		pass
		
#	var input_dir = 0
#	if Input.is_action_pressed("ui_right"):
#		input_dir += 1
#		faceRight=true
#	if Input.is_action_pressed("ui_left"):
#		input_dir -= 1
#		faceRight=false
#
#	$ani.flip_h=!faceRight
#
#	if input_dir != 0:
#		velocity.x = lerp(velocity.x, input_dir * speed, acceleration)
#		$ani.play("run_small")
#	else:
#		velocity.x = lerp(velocity.x, 0, friction)
#		$ani.play("idle_small")
#
#	velocity = move_and_slide(velocity, Vector2.UP)

#站着
func idle(delta):
	#$ani.speed_scale=1
	$ani.play("idle_small")
	if Input.is_action_pressed("ui_left"):
		faceRight=false
		status = constants.walk
	elif Input.is_action_pressed("ui_right"):
		faceRight=true
		status = constants.walk
		pass
	elif Input.is_action_pressed("ui_jump"):
		print("跳跃")
	
	
	
#移动
func walk(delta):
	
	#计算动画速度
	if round(velocity.x)==0:
		animation_speed = 1
	elif velocity.x>0:
		animation_speed=1+velocity.x/constants.animation_speed
	else:
		animation_speed=1+velocity.x/constants.animation_speed*-1
	print(animation_speed)
	$ani.speed_scale=animation_speed
	
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

	
	
#跳跃
func jump(delta):
	
	pass	


	
	
	
