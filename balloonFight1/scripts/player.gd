extends KinematicBody2D

var dir=Constants.right
var keymap={"up":0,"down":0,"left":0,"right":0,'accelerate':0}
var vec=Vector2.ZERO
var isInvincible=false #无敌
var balloonNum=2#气球数量
var onFloor=false
var gravity=100
var playerId=1  #1是1p 2是2p
#var moveSpeed=70
var upAccelerate=200
var moveMaxSpeed=200
var accelerate=120
var moveSpeedInAir=70
var life=2 #气球个数

onready var _ani=$ani

func _ready():
	if playerId==1:
		keymap.up="p1_up"
		keymap.right='p1_right'
		keymap.left='p1_left'
		keymap.accelerate='p1_action'
	elif playerId==2:
		keymap.up="p2_up"
		keymap.right='p2_right'
		keymap.left='p2_left'
		keymap.accelerate='p2_action'	

	
	
func _physics_process(delta):
	vec.y+=gravity*delta
	if is_on_floor():
		onFloor=true
	else:
		onFloor=false	
		
	if Input.is_action_pressed(keymap.left):	
		dir=Constants.left
		if onFloor:
			animation("run")
			if vec.x>-moveMaxSpeed:
				vec.x-=accelerate*delta
		else:
			if vec.x>-moveMaxSpeed:
				vec.x-=accelerate*delta		
	elif  Input.is_action_pressed(keymap.right):	
		dir=Constants.right
		if onFloor:
			animation("run")
			if vec.x<moveMaxSpeed:
				vec.x+=accelerate*delta
		else:
			if vec.x<moveMaxSpeed:
				vec.x+=accelerate*delta		
	else:
		if dir==Constants.left:
			if vec.x<0:
				vec.x+=accelerate*delta
				animation("run")
			else:
				vec.x=0
				if onFloor:
					animation("idle")	
		else:
			if vec.x>0:
				vec.x-=accelerate*delta
				animation("run")
			else:
				vec.x=0	
				if onFloor:
					animation("idle")
					
	if Input.is_action_pressed(keymap.accelerate):
		vec.y-=upAccelerate*delta
		animation("flap")
	else:
		if !onFloor:
			animation("fly")
		
	vec=move_and_slide(vec,Vector2.UP)
	
	


func animation(type):
	if type=='idle':
		_ani.play("idle_1")
	elif type=='run':
		_ani.play("run_1")
	elif type=='fly':
		_ani.play("fly_1")
	elif type=='flap':
		_ani.play("flap_1")	
		
	if dir==Constants.left:
		_ani.flip_h=true
	else:
		_ani.flip_h=false		
		

