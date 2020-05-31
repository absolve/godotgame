extends KinematicBody2D


var speed=450	#跳跃速度
var gravity=1000
var velocity = Vector2.ZERO	#速度

var animationInterval=240
var animationTime=0

var rotateDeg=0
var rotateSpeed=320
var jumpAgain=true	#再次跳跃


var state = Game.playerState.STAND

func _ready():
	add_to_group("player")
	pass 


func _physics_process(delta):
	
	if state==Game.playerState.IDLE:
		idle(delta)
	elif state==Game.playerState.STAND:
		stand(delta)
	elif state==Game.playerState.JUMP:
		jump(delta)
	elif state==Game.playerState.DEAD:
		dead(delta)
	
	
	
	animationTime+=1
	if animationTime>animationInterval:
		animationTime=0
		$sprite.play("blink",true)


func idle(delta):
	velocity.y+=gravity*delta
	move_and_slide(velocity,Vector2.UP)	
	

func stand(delta):
	velocity.y+=gravity*delta
	
	if Input.is_action_pressed("jump"):
		velocity.y=-speed
		state=Game.playerState.JUMP
		return
	velocity=move_and_slide(velocity,Vector2.UP)	



func jump(delta):
	velocity.y+=gravity*delta
	if Input.is_action_just_pressed("jump") and jumpAgain:
		velocity.y=-speed
		jumpAgain=false
	
	rotateDeg+=rotateSpeed*delta
	$sprite.rotation_degrees=round(rotateDeg)
	$bg.rotation_degrees=round(rotateDeg)
	if rotateDeg>360:
		rotateDeg=0
		
	velocity=move_and_slide(velocity,Vector2.UP)	
	
	if is_on_floor():
		print(222)
		jumpAgain=true
		state=Game.playerState.STAND
		rotateDeg=0
		$sprite.rotation_degrees=0
		$bg.rotation_degrees=0
	
	
	
	#判断是否超出品墓
	
	pass

func dead(delta):
	
	pass

	
