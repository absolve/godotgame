extends KinematicBody2D

var dir=0 # 0左 1右
var keymap={"up":0,"down":0,"left":0,"right":0,'accelerate':0}
var vec=Vector2.ZERO
var isInvincible=false #无敌
var balloonNum=2#气球数量
var onFloor=false
var gravity=900

func _ready():
	pass
	
	
func _physics_process(delta):
	vec.y+=gravity
	
	var temp=move_and_collide(vec)
	if temp:
		print(temp)
	else:
		print(21212)
	
	if is_on_floor():
		onFloor=true
	else:
		onFloor=false	
	
	pass

func animation(dir,vec):
	
	pass
