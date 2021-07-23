extends Node2D



var rect=Rect2(Vector2(-14,-14),Vector2(28,28))
var debug=true
var vec=Vector2.ZERO
var keymap={"up":0,"down":0,"left":0,"right":0,'fire':0}
var level=0 #坦克的级别	0最小 1中等 2是大  3是最大
var dir=0 # 0上 1下 2左 3右
var shootTime=0	
var shootDelay=60
var bullets=[]
var bulletMax=1	#发射最大子弹数
var bullet=Game.bullet
var isInit=false
var state=Game.tank_state.IDLE
var initStartTime=0
var initTime=1200  #ms
var isInvincible=false #无敌
var invincibleStartTime=0
var invincibleTime=8000
var isStop=false#是否停止
var playId=2  #1=1p 2=2p
var life=1  #生命默认1
var speed = 70 #移动速度
var bulletPower=Game.bulletPower.normal
var hasShip=false	#是否有船
var isFreeze=false	#冻结
var lastDir=0#上次的方向

onready var _invincible=$invincible
onready var _ship=$ship
onready var _sound=$sound
onready var _hit=$hit
onready var _invincibleTimer=$invincibleTimer
onready var _initTimer = $initTimer
onready var _ani=$ani

func _ready():
	var shot = _sound.stream as AudioStreamOGGVorbis
	shot.set_loop(false)
	var hit=_hit.stream as AudioStreamOGGVorbis
	hit.set_loop(false)
	get_children()
	_ani.play("flash")
	_ani.playing=true
	_invincibleTimer.connect("timeout",self,"invincibleTimerEnd")
	_initTimer.connect("timeout",self,"initEnd")
	_initTimer.start()
	if playId==2:
		_ship.texture=Game.ship2
	setKeyMap(playId)
	setEnableInvincible(3)
	if level==1:
		bulletPower=Game.bulletPower.fast
	elif level==2:	
		bulletPower=Game.bulletPower.fast
		bulletMax+=1
	elif level==3:
		bulletMax+=1
		bulletPower=Game.bulletPower.super
	if hasShip:
		_ship.visible=true
			
#	addMaxPower()
#	addship()


#获取矩形
func getRect()->Vector2:
	var temp =rect
	temp.position+=position
	return temp

func getSize():
	return rect.size.x

func getPos():
	return position
	
func setStop(isStop):
	self.isStop=isStop	
	 
func setKeyMap(playerId:int):
	if playerId==1:
#		keymap["up"]=Game.player1["up"]
#		keymap["down"]=Game.player1["down"]
#		keymap["left"]=Game.player1["left"]
#		keymap["right"]=Game.player1["right"]
#		keymap["fire"]=Game.player1["fire"]
		keymap["up"]="p1_up"
		keymap["down"]="p1_down"
		keymap["left"]="p1_left"
		keymap["right"]="p1_right"
		keymap["fire"]="p1_fire"
	elif playerId==2:
#		keymap["up"]=Game.player2["up"]
#		keymap["down"]=Game.player2["down"]
#		keymap["left"]=Game.player2["left"]
#		keymap["right"]=Game.player2["right"]
#		keymap["fire"]=Game.player2["fire"]	
		keymap["up"]="p2_up"
		keymap["down"]="p2_down"
		keymap["left"]="p2_left"
		keymap["right"]="p2_right"
		keymap["fire"]="p2_fire"	
	
#增加力量	
func addPower():
	if level==0:
		level+=1
		bulletPower=Game.bulletPower.fast
	elif level==1:
		level+=1
		bulletMax+=1
	elif level==2:
		level+=1
		bulletPower=Game.bulletPower.super
	elif level==3:
		pass	

#添加最大为例
func addMaxPower():
	if level<3:
		level=3
		bulletMax=2
		if life<=2:
			life+=1
		bulletPower=Game.bulletPower.super
	
func addship():
	if !hasShip:
		hasShip=true
		_ship.visible=true
		
func delship():
	hasShip=false
	_ship.visible=false

func hasShip():
	return hasShip

func _update(delta):
	if state==Game.tank_state.IDLE:
		pass	
	elif state==Game.tank_state.START:
		animation(dir,vec)	
		if isFreeze:
			return
		lastDir=dir
		
		if Input.is_action_pressed(keymap["up"]):
			vec.y=-speed
			vec.x=0
			dir=0
		elif Input.is_action_pressed(keymap["down"]):
			vec.x=0
			vec.y=speed
			dir=1
		elif Input.is_action_pressed(keymap["left"]):
			vec.x=-speed
			vec.y=0
			dir=2	
		elif Input.is_action_pressed(keymap["right"]):	
			vec.y=0
			vec.x=speed
			dir=3
		else:
			vec=Vector2.ZERO	
		
		if lastDir!=dir:
			turnDir()
		
		if vec!=Vector2.ZERO:
			if !$walk.playing:
				$walk.play()
			if $idle.playing:
				$idle.stop()	
		else:
			if $walk.playing:
				$walk.stop()
			if !$idle.playing:
				$idle.play()
			
		if Input.is_action_pressed(keymap["fire"]):
			fire()	
			
		if !isStop:
			position+=vec*delta	
	
	
func animation(dir,vec):
	if dir==0:
		_ani.flip_v=false
		_ani.flip_h=false
		_ani.rotation_degrees=0
	elif dir==1:
		_ani.flip_v=true
		_ani.flip_h=false
		_ani.rotation_degrees=0
	elif dir==2:
		_ani.flip_v=false
		_ani.flip_h=true
		if _ani.rotation_degrees!=-90:
			_ani.rotation_degrees=-90
	elif dir==3:
		_ani.flip_v=false
		_ani.flip_h=false
		if _ani.rotation_degrees!=90:
			_ani.rotation_degrees=90	
	if level==0:
		if vec!=Vector2.ZERO:
			if playId==1:
				_ani.play("small_run")
			else:
				_ani.play("small_green_run")	
		else:
			if playId==1:	
				_ani.play("small")
			else:
				_ani.play("small_green")	
	elif level==1:
		if vec!=Vector2.ZERO:
			if playId==1:	
				_ani.play("middle_run")
			else:
				_ani.play("middle_green_run")	
		else:
			if playId==1:	
				_ani.play("middle")
			else:
				_ani.play("middle_green")	
	elif level==2:
		if vec!=Vector2.ZERO:
			if playId==1:	
				_ani.play("big_run")
			else:
				_ani.play("big_green_run")		
		else:
			if playId==1:	
				_ani.play("big")
			else:
				_ani.play("big_green")	
	elif level==3:
		if vec!=Vector2.ZERO:
			if playId==1:	
				_ani.play("super_run")
			else:
				_ani.play("super_green_run")	
		else:
			if playId==1:
				_ani.play("super")	
			else:
				_ani.play("super_green")		

func setState(state):
	if state==Game.tank_state.START:
		isInit=true
		self.state=state


#设置无敌
func setEnableInvincible(time=15):
	if _invincibleTimer.is_stopped():
		_invincibleTimer.start(time)
		_invincible.visible=true
		_invincible.playing=true
	else:
		_invincibleTimer.stop()
		_invincibleTimer.start(time)
	isInvincible=true

#定时器结束
func invincibleTimerEnd():
	_invincible.visible=false
	_invincible.playing=false
	isInvincible=false

#开火
func fire():
	if OS.get_system_time_msecs()-shootTime<shootDelay:
		return
	else:
		shootTime=OS.get_system_time_msecs()
	var del=[]
	for i in bullets: #清理无效对象
	#	print(is_instance_valid(i))
		if not is_instance_valid(i):
			del.append(i)
	for i in del:
		bullets.remove(bullets.find(i))
	if bullets.size()<bulletMax:
		playShot()
		var temp=bullet.instance()
		temp.setType("player")
		temp.position=position
		temp.setPower(bulletPower)
		temp.setDir(dir)
		temp.setPlayerId(playId)
		bullets.append(temp)
		Game.mainScene.add_child(temp)

func playShot():
	_sound.play()

#被击中  属于玩家 还是敌人
func hit(bulletType):
	if bulletType==Game.bulletType.enemy:
		if hasShip:	#有船
			delship()
			return
		if isInvincible: #无敌
			return
		if life>1:
			life-=1
			if level>=3:
				level-=1
				bulletPower=Game.bulletPower.fast
			playhit()	
		else:
			addExplode()
			Game.emit_signal("hitPlayer",playId)	
			pass
	elif bulletType==Game.bulletType.players:
		pass
	pass

#设置冻结
func setFreeze(flag=true):
	self.isFreeze=flag
	if flag:
		$walk.stop()	
		$idle.stop()
		vec=Vector2.ZERO	
		
#初始化完毕
func initEnd():
	isInit=true
	_ani.playing=false
	setState(Game.tank_state.START)

func addExplode(big=true):
	var temp=Game.explode.instance()
	if big:
		temp.big=true
	temp.position=position
	Game.otherObj.add_child(temp)
	destroy()

func destroy():
	queue_free()

func playhit():
	if !_hit.playing:
		_hit.play()

func getPlayId():
	return playId

func isDead():
	if state==Game.tank_state.DEAD:
		return true
	else:
		return false	

func get_class():
	return 'player'

#改变方向
#每个方块的大小是16px 坦克大小32px 图片大小差不多是28px
#坦克的位置一定是16的倍数这样就可以每次旋转都正好在每个方块的边缘
#这样的话就不会出现叠在一起的情况
func turnDir(): 
	position.y=round((position.y)/16)*16
	position.x=round((position.x)/16)*16
#	if dir%2!=0:
#		position.y=round((position.y)/16)*16
#	else:
#		position.x=round((position.x)/16)*16
	pass

func _draw():
#	if debug:
#		draw_rect(rect,Color.white,false,1,true)
	pass	


