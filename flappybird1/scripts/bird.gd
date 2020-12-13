extends RigidBody2D


var state = game.idle #默认状态

var ypos=3	#上下飞行的距离
var filp=true
var flyspeed=25 #上下飞行的速度
var speed=150	#向上飞的速度
signal birdStateChange  #状态改变
var ani= ["idle","fly","flap"]
var ani2=["idle_blue","fly_blue","flap_blue"]
var ani3=["idle_yellow","fly_yellow","flap_yellow"]
var list=[ani,ani2,ani3]
var index=0


func _ready():
	friction=1
	randomize()
	index=randi()%3
	$ani.play(list[index][0])
	add_to_group(game.group_bird)
	


func _physics_process(delta):
	if state==game.idle:
		idle(delta)
	elif state==game.fly:
		fly(delta)
	elif state==game.play:
		play(delta)
	elif state==game.dead:
		dead(delta)

#设置状态
func setState(newState:int):
	if newState==game.idle:
		gravity_scale=0
	elif newState==game.fly:
		gravity_scale=0
		$ani.play(list[index][1])
	elif newState==game.play:
		gravity_scale=5
		flap()
	elif newState==game.dead:
		angular_velocity=1.4
#		$ani.play("idle")
		$ani.play(list[index][0])
	state=newState

#拍动翅膀
func flap():
	if AudioPlayer:
		AudioPlayer.playSfxWing()
	$ani.play(list[index][2],true)
	linear_velocity.y=-speed
	angular_velocity=-3

#默认状态
func idle(delta):
	pass
	
#上下飞行的状态
func fly(delta):
	if filp:
		if $ani.position.y>ypos:
			filp=false
		else:
			$ani.position.y+=flyspeed*delta
	else:
		if $ani.position.y<-ypos:
			filp=true
		else:
			$ani.position.y-=flyspeed*delta


#游戏开始时 飞行的状态
func play(delta):
	if Input.is_action_just_pressed("ui_accept"):
		flap()
	
	#计算角度避免一直旋转
	if rotation_degrees<-30:
		rotation_degrees=-30
		angular_velocity=0
	
	if linear_velocity.y>0:
		angular_velocity=1.5
	
func dead(delta):
	pass

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if state==game.play:
				flap()
	
#如果碰到水管和地面就发出信号
func _on_bird_body_entered(body):
	if state!=game.play:	#不是开始的状态就跳过
		return
	if body.is_in_group(game.group_ground):
		if AudioPlayer:
			AudioPlayer.playSfxHit()
		emit_signal("birdStateChange")
	elif body.is_in_group(game.group_pipe):
		if AudioPlayer:
			AudioPlayer.playSfxHit()
			AudioPlayer.playSfxDie()
		emit_signal("birdStateChange")
		var other_body = get_colliding_bodies()[0]
		add_collision_exception_with(other_body)


