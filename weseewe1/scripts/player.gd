extends KinematicBody2D


var speed=550	#跳跃速度
var gravity=1300
var velocity = Vector2.ZERO	#速度

var animationInterval=240
var animationTime=0

var rotateDeg=0
var rotateSpeed=320
var jumpAgain=true	#再次跳跃
var size=30 #形状大小

var state = Game.playerState.IDLE

func _ready():
	add_to_group("player")
	pass 

func setState(state):
	self.state=state

	
func playAni():
	$dialog/Label.text=Game.words[randi()%Game.words.size()]
	$ani.play("show")

#显示新分数
func playMewScoreAni():
	$dialog/Label.text="you got new score"
	$ani.play("show")
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
	velocity=move_and_slide(velocity,Vector2.UP)	
	

func stand(delta):
	velocity.y+=gravity*delta
	
	if Input.is_action_pressed("jump"):
		SoundUtil.playJumpA()
		velocity.y=-speed
		state=Game.playerState.JUMP
		return
	velocity=move_and_slide(velocity,Vector2.UP)	



func jump(delta):
	velocity.y+=gravity*delta
	if Input.is_action_just_pressed("jump") and jumpAgain:
		SoundUtil.playJumpB()
		velocity.y=-speed
		jumpAgain=false
	
	rotateDeg+=rotateSpeed*delta
	$sprite.rotation_degrees=round(rotateDeg)
	$bg.rotation_degrees=round(rotateDeg)
	if rotateDeg>360:
		rotateDeg=0
		
	velocity=move_and_slide(velocity,Vector2.UP)	
	
	if is_on_floor():
		jumpAgain=true
		state=Game.playerState.STAND
		rotateDeg=0
		$sprite.rotation_degrees=0
		$bg.rotation_degrees=0
	pass

func dead(delta):
	
	pass

func _unhandled_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed or (event is InputEventMouseButton and 
							event.button_index == BUTTON_LEFT and event.pressed):
			if state==Game.playerState.STAND:
				SoundUtil.playJumpA()
				velocity.y=-speed
				state=Game.playerState.JUMP
			elif state==Game.playerState.JUMP and jumpAgain:
				SoundUtil.playJumpB()
				velocity.y=-speed
				jumpAgain=false
				
	pass	
