extends KinematicBody2D

# 0 是硬币 1是8个硬币 2是蘑菇 3是花 4是装快
export var content=0
export var isvisible=true  #是否可见
export var iscollide=true	#是否可碰撞
export var framenum=3	#默认显示动画数量
export var frameIndex=0

var gravity=1500	#重力
var yoffset=-200 #偏移
var y_pos=0	#保存之前的位置
var state=constants.resting	#静止状态
var current_time=0
var first_half=true
var firstframetime=0.38
var frametime=0.15

var velocity = Vector2() #速度

var block1 =preload("res://sprites/blockq_0.png")
var block2 = preload("res://sprites/blockq_1.png")
var block3 = preload("res://sprites/blockq_2.png")
var opened1 = preload("res://sprites/blockq_used.png")
var blocklist1=[block1,block3,block2,opened1]


func _ready():

	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	

func _physics_process(delta):
	if state==constants.bumped:
		bumped(delta)
	elif state==constants.opened:
		opened()
	elif state==constants.resting:
		resting(delta)
	
	if Input.is_action_just_pressed("ui_up"):
		start_bump()
		#y_pos = position.y
	#	position+=Vector2(0,yoffset)
#		move_and_slide(Vector2(0,yoffset),Vector2(0,0))

#静止的状态
func resting(delta):
	if framenum>1:	#大于1
		current_time+=delta
		if first_half:
			if frameIndex==0:
				if current_time>firstframetime:
					current_time=0
					frameIndex+=1
					$sprite.texture=blocklist1[frameIndex]
			elif frameIndex<2:
				if current_time>frametime:
					current_time=0
					frameIndex+=1
					$sprite.texture=blocklist1[frameIndex]
			elif frameIndex==2:
				if current_time>frametime:
					current_time=0
					frameIndex-=1
					first_half=false
					$sprite.texture=blocklist1[frameIndex]
		else:
			if frameIndex==1:
				if current_time>frametime:
					frameIndex-=1
					first_half=true
					current_time=0
					$sprite.texture=blocklist1[frameIndex]
			
#突起的状态
func bumped(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	print(velocity)
	if velocity.y>=-yoffset-5:
		printt(position.y,y_pos)
		state = constants.opened
		move_and_slide(Vector2(0,(y_pos-position.y)*60),Vector2(0, -1))
		
		$sprite.texture=blocklist1[3]
#	if position.y<y_pos:	#判断是否小于原来的坐标
#		if position.y+gravity>=y_pos:
#			position.y+=y_pos-position.y
#		else:
#			position.y+= gravity
#	else:
#		state = constants.opened

#开始突起
func start_bump():
	y_pos = position.y
	#position+=Vector2(0,yoffset)
	velocity.y=yoffset
	state = constants.bumped

#已经打开的状态
func opened():
	pass