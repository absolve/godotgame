extends Node2D



var rect=Rect2(Vector2(-14,-14),Vector2(28,28))
var debug=true
var vec=Vector2.ZERO
var keymap={"up":0,"down":0,"left":0,"right":0,'fire':0}
var speed = 70
var level=0 #坦克的级别	0最小 1中等 2是大  3是最大
var dir=0 # 0上 1下 2左 3右
var shootTime=0	
var shootDelay=0.01
var bullets=[]
var bulletMax=1	#发射最大子弹数
var bullet=Game.bullet
var isInit=false
var state=Game.tank_state.IDLE
var initStartTime=0
var initTime=1200  #ms
var isInvincible=false
var invincibleStartTime=0
var invincibleTime=8000
var isStop=false#是否停止
var playId=1  #1=1p 2=2p

onready var _invincible=$invincible
onready var _ship=$ship

func _ready():
	$ani.play("flash")
	$ani.playing=true
	setIsInvincible()
	if playId==2:
		_ship.texture=Game.ship2
	setKeyMap(playId)
	pass

#获取矩形
func getRect()->Vector2:
	var temp =rect
	temp.position+=position
	return temp

func getSize():
	return rect.size.x

func getPos():
	return position
	
func setStop(isSto,dir):
	self.isStop=isStop	
	 
func setKeyMap(playerId:int):
	if playerId==1:
		keymap["up"]=Game.player1["up"]
		keymap["down"]=Game.player1["down"]
		keymap["left"]=Game.player1["left"]
		keymap["right"]=Game.player1["right"]
		keymap["fire"]=Game.player1["fire"]
	elif playerId==2:
		keymap["up"]=Game.player2["up"]
		keymap["down"]=Game.player2["down"]
		keymap["left"]=Game.player2["left"]
		keymap["right"]=Game.player2["right"]
		keymap["fire"]=Game.player2["fire"]	
	pass	
	
	
func _process(delta):
#	update()
	#print(rect.position)
#	if state==Game.tank_state.IDLE:
#		initStartTime+=delta*1000
#		if initStartTime>=initTime:
#			initStartTime=0
#			isInit=true
#			$ani.playing=false
#			setState(Game.tank_state.START)
#		pass
#	elif state==Game.tank_state.START:
#		if Input.is_key_pressed(keymap["up"]):
#			vec.y=-speed
#			vec.x=0
#			dir=0
#			isStop=false
#		elif Input.is_key_pressed(keymap["down"]):
#			vec.x=0
#			vec.y=speed
#			dir=1
#			isStop=false
#		elif Input.is_key_pressed(keymap["left"]):
#			vec.x=-speed
#			vec.y=0
#			isStop=false
#			dir=2	
#		elif Input.is_key_pressed(keymap["right"]):	
#			vec.y=0
#			vec.x=speed
#			dir=3
#			isStop=false
#		else:
#			vec=Vector2.ZERO	
#
#		if Input.is_key_pressed(keymap["fire"]):
#			print("fire")
#			fire()	
#
#		animation(dir,vec)	
#		if !isStop:
#			position+=vec*delta
#
#		if isInvincible:
#			invincibleStartTime+=delta*1000
#			if invincibleStartTime>=invincibleTime:
#				invincibleStartTime=0
#				isInvincible=false
#				_invincible.visible=false
#				_invincible.playing=false
		
	pass

func _update(delta):
	if state==Game.tank_state.IDLE:
		initStartTime+=delta*1000
		if initStartTime>=initTime:
			initStartTime=0
			isInit=true
			$ani.playing=false
			setState(Game.tank_state.START)
		pass
	elif state==Game.tank_state.START:
		if Input.is_key_pressed(keymap["up"]):
	#		print("up")
			vec.y=-speed
			vec.x=0
			dir=0
			isStop=false
		elif Input.is_key_pressed(keymap["down"]):
			vec.x=0
			vec.y=speed
			dir=1
			isStop=false
		elif Input.is_key_pressed(keymap["left"]):
			vec.x=-speed
			vec.y=0
			isStop=false
			dir=2	
		elif Input.is_key_pressed(keymap["right"]):	
			vec.y=0
			vec.x=speed
			dir=3
			isStop=false
		else:
			vec=Vector2.ZERO	
			
		if Input.is_key_pressed(keymap["fire"]):
			print("fire")
			fire()	
			
		animation(dir,vec)	
		if !isStop:
			position+=vec*delta
		
		if isInvincible:
			invincibleStartTime+=delta*1000
			if invincibleStartTime>=invincibleTime:
				invincibleStartTime=0
				isInvincible=false
				_invincible.visible=false
				_invincible.playing=false
	pass
	
	
func animation(dir,vec):
	if dir==0:
		$ani.flip_v=false
		$ani.flip_h=false
		$ani.rotation_degrees=0
		pass
	elif dir==1:
		$ani.flip_v=true
		$ani.flip_h=false
		$ani.rotation_degrees=0
		pass
	elif dir==2:
		$ani.flip_v=false
		$ani.flip_h=true
		if $ani.rotation_degrees!=-90:
			$ani.rotation_degrees=-90
		pass
	elif dir==3:
		$ani.flip_v=false
		$ani.flip_h=false
		if $ani.rotation_degrees!=90:
			$ani.rotation_degrees=90
		pass	
	if level==0:
		if vec!=Vector2.ZERO:
			$ani.play("small_run")
		else:	
			$ani.play("small")
	elif level==1:
		if vec!=Vector2.ZERO:
			$ani.play("middle_run")
		else:
			$ani.play("middle")
	elif level==2:
		if vec!=Vector2.ZERO:
			$ani.play("big_run")
		else:
			$ani.play("big")
	elif level==3:
		if vec!=Vector2.ZERO:
			$ani.play("super_run")
		else:
			$ani.play("super")	

func setState(state):
	if state==Game.tank_state.START:
		isInit=true
		self.state=state

func setIsInvincible():
	isInvincible=true
	_invincible.visible=true
	_invincible.playing=true

#开火
func fire():
	if OS.get_unix_time()-shootTime<shootDelay:
		return
	else:
		shootTime=OS.get_unix_time()
	print("dir",dir)	
	var del=[]
	for i in bullets: #清理无效对象
		print(is_instance_valid(i))
		if not is_instance_valid(i):
			del.append(i)
	for i in del:
		bullets.remove(bullets.find(i))
	if bullets.size()<bulletMax:
		var temp=bullet.instance()
		temp.setType("player")
		temp.position=position
		#temp.power=2
		temp.setDir(dir)
		bullets.append(temp)
		Game.mainScene.add_child(temp)

func get_class():
	return 'player'
	
func _draw():
	if debug:
		draw_rect(rect,Color.white,false,1,true)
	pass	


