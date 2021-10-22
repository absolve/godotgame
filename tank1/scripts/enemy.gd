extends "res://scripts/tank.gd"


#var rect=Rect2(Vector2(-14,-14),Vector2(28,28))
var speed=42  #移动速度
#var dir=1 # 0上 1下 2左 3右

var type=0  # 0 typeA  1 typeB 2 typeC 3 typeD
#var bulletMax=1	#发射最大子弹数
var armour=0  #护甲等级  不同等级护甲不同 最大3
var vec=Vector2.ZERO
#var isStop=false#是否停止
var keepDirectionTime=0 #保持方向的时间 ms
var directionTime=0
var targetPos=Vector2(0,0)	#目标位置
#var bullet=Game.bullet
#var bullets=[]
var fireTime=0
var reloadTime=800
var newDir=Game.up
var bulletPower=Game.bulletPower.normal

var isInit=false
var state=Game.tank_state.IDLE
var initStartTime=0
var initTime=1200  #ms
#var nextState=Game.tank_state.STOP
var isFreeze=false	#冻结
var hasItem=false #是否有物品
var aniStartTime=0	#动画变化
var aniDelayTime=240 #ms

onready var _ani=$ani
onready var _hit=$hit
onready var _timer=$Timer #初始化时间

func _ready():
	randomize()
	dir=Game.down
	$ani.play("flash")
	$ani.playing=true
	var hit=_hit.stream as AudioStreamOGGVorbis
	hit.set_loop(false)
	if type==0:
		armour=randi()%2
		pass
	elif type==1:
		speed=100
		armour=randi()%4
	elif type==2:
		bulletPower=Game.bulletPower.fast
		armour=randi()%4	
	elif type==3:
		bulletPower=Game.bulletPower.fast
		armour=randi()%4
		speed-=5
		
	if randi()%100>=75:
		hasItem=true

	_timer.connect("timeout",self,'initFinish')
	_timer.start()
	keepDirectionTime = randi()%1800+300	



#获取矩形
func getRect()->Vector2:
	var temp =rect
	temp.position+=position
	return temp

func getSize():
	return rect.size.x
	
func _update(delta):
	if state==Game.tank_state.IDLE:
		pass
	elif state==Game.tank_state.START:
		animation(dir,vec)	
		if isFreeze:
			return
		
		if dir==Game.up:
			vec.y=-speed
			vec.x=0
		elif dir==Game.down:
			vec.x=0
			vec.y=speed
		elif dir==Game.left:
			vec.x=-speed
			vec.y=0
		elif dir==Game.right:
			vec.y=0
			vec.x=speed		
		else:
			vec=Vector2.ZERO	
		
		directionTime+=delta*1000
		fireTime+=delta*1000
		if isStop:
			keepDirectionTime-=20
			vec=Vector2.ZERO
	
		if directionTime>keepDirectionTime:
			keepDirectionTime=randi()%1800+300	
			directionTime=0
			var p=randf()   #随机概率值		
			var dx=position.x-targetPos.x
			var dy=position.y-targetPos.y 
			
			
			if type==0:
				if p>0.3:
					targetEagle(p)
				else:
					var temp = getNewDir(dir)
					newDir=temp[randi()%temp.size()]			
			elif type==1 ||type==2:
				if p>0.5:
					targetEagle(p)
				else:
					var temp = getNewDir(dir)
					newDir=temp[randi()%temp.size()]	
			elif type==3:
				if p>0.1:
					targetEagle(p)
				else:
					var temp = getNewDir(dir)
					newDir=temp[randi()%temp.size()]				

			if dir!=newDir:
				dir=newDir
				turnDir() #位置调整
			else:
				dir=newDir	
			
			
		if fireTime>reloadTime:
			fireTime=0
			if type==0 || type==1: #类型s 类型b开火间隔长
				reloadTime=randi()%2000+300
			else:
				reloadTime=randi()%1000+200
			fire()			
		if !isStop:
			position+=vec*delta		
	elif state==Game.tank_state.STOP:
		pass
	elif state==Game.tank_state.DEAD:
		pass
	pass

func animation(dir,vec):
	if dir==Game.up:
		_ani.flip_v=true
		_ani.flip_h=true
		_ani.rotation_degrees=0
	elif dir==Game.down:
		_ani.flip_v=false
		_ani.flip_h=false
		_ani.rotation_degrees=0
	elif dir==Game.left:
		_ani.flip_v=false
		_ani.flip_h=false
		if _ani.rotation_degrees!=90:
			_ani.rotation_degrees=90
	elif dir==Game.right:
		_ani.flip_v=false
		_ani.flip_h=false
		if _ani.rotation_degrees!=-90:
			_ani.rotation_degrees=-90
	if type==0:
		if !hasItem:
			if armour==0:
				_ani.play("typeA")
			elif armour==1:
				_ani.play("typeA_1")	
			elif armour==2:	
				_ani.play("typeA_2")	
			elif armour==3:		
				_ani.play("typeA_3")	
			else:	
				_ani.play("typeA")
#			if isFreeze:
#				_ani.stop()	
		else:
			if OS.get_system_time_msecs()-aniStartTime>=aniDelayTime:
				aniStartTime=OS.get_system_time_msecs()
				var index=_ani.frame
				if _ani.get_animation()!="typeA_4":
					_ani.animation="typeA_4"
				else:
					_ani.animation="typeA"
				_ani.frame=	index  #设置动画帧数发生变化
	elif type==1:
		if !hasItem:
			if armour==0:
				_ani.play("typeB")
			elif armour==1:
				_ani.play("typeB_1")	
			elif armour==2:	
				_ani.play("typeB_2")	
			elif armour==3:		
				_ani.play("typeB_3")	
			else:	
				_ani.play("typeB")
		else:
			if OS.get_system_time_msecs()-aniStartTime>=aniDelayTime:
				aniStartTime=OS.get_system_time_msecs()
				var index=_ani.frame
				if _ani.get_animation()!="typeB_4":
					_ani.animation="typeB_4"
				else:
					_ani.animation="typeB"
				_ani.frame=	index  #设置动画帧数发生变化
	elif type==2:
		if !hasItem:
			if armour==0:
				_ani.play("typeC")
			elif armour==1:
				_ani.play("typeC_1")	
			elif armour==2:	
				_ani.play("typeC_2")	
			elif armour==3:		
				_ani.play("typeC_3")	
			else:	
				_ani.play("typeC")
		else:
			if OS.get_system_time_msecs()-aniStartTime>=aniDelayTime:
				aniStartTime=OS.get_system_time_msecs()
				var index=_ani.frame
				if _ani.get_animation()!="typeC_4":
					_ani.animation="typeC_4"
				else:
					_ani.animation="typeC"
				_ani.frame=	index  #设置动画帧数发生变化		
	elif type==3:
		if !hasItem:
			if armour==0:
				_ani.play("typeD")
			elif armour==1:
				_ani.play("typeD_1")	
			elif armour==2:	
				_ani.play("typeD_2")	
			elif armour==3:		
				_ani.play("typeD_3")	
			else:	
				_ani.play("typeD")
		else:
			if OS.get_system_time_msecs()-aniStartTime>=aniDelayTime:
				aniStartTime=OS.get_system_time_msecs()
				var index=_ani.frame
				if _ani.get_animation()!="typeD_4":
					_ani.animation="typeD_4"
				else:
					_ani.animation="typeD"
				_ani.frame=	index  #设置动画帧数发生变化					
	if isFreeze:
		_ani.stop()	
	else:	
		_ani.play()
	
#改变方向
func turnDirection():
	var temp=[Game.up,Game.down,Game.left,Game.right]
	newDir=temp[randi()%4]

#向基地出发
func targetEagle(p):
	var dx=position.x-targetPos.x
	var dy=position.y-targetPos.y 
	if abs(dx)>abs(dy):
		if dx<0:
			newDir=Game.right
		else:
			newDir=Game.left
		if p>0.8:
			var temp = getNewDir(dir)
			newDir=temp[randi()%temp.size()]			
	else:
		if dy<0:
			newDir=Game.down
		else:
			newDir=Game.up
		if p>0.8:
			var temp = getNewDir(dir)
			newDir=temp[randi()%temp.size()]	

func setStop(isStop):
	self.isStop=isStop

func getNewDir(dir):
	var temp=[]
	var tempdir=[Game.up,Game.down,Game.left,Game.right]
	for i in tempdir:
		if dir!=i:
			temp.append(i)
	return temp
		
func setPos(pos:Vector2):
	position=pos

func getPos():
	return position

#被击中
func hit(playerId):
	if hasItem:
		Game.emit_signal("addBonus",type)
	if armour>0:
		armour-=1
		playhit()
	else:	
		setState(Game.tank_state.DEAD)
		Game.emit_signal("hitEnemy",type,playerId,position)
		addExplode(true)

func addExplode(big):
	var temp=Game.explode.instance()
	if big:
		temp.big=true
	temp.position=position
	Game.otherObj.add_child(temp)
	state=Game.tank_state.DEAD
	destroy()

func destroy():
	queue_free()

func setState(state):
	if state==Game.tank_state.START:
		self.state=state		
	elif state==Game.tank_state.STOP:
		pass
	elif state==Game.tank_state.RESTART:
		pass	
	elif state==Game.tank_state.DEAD:
		self.state=state

func isDead():
	if state==Game.tank_state.DEAD:
		return true
	else:
		return false	
		
#设置冻结
func setFreeze(flag=true):
	self.isFreeze=flag
	if flag:
		vec=Vector2.ZERO			
		
func initFinish():
	isInit=true
	setState(Game.tank_state.START)
	
func playhit():
	if !_hit.playing:
		_hit.play()		
#开火
func fire():
	var del=[]
	for i in bullets: #清理无效对象
		if not is_instance_valid(i):
			del.append(i)
	for i in del:
		bullets.remove(bullets.find(i))
	if bullets.size()<bulletMax:
		var temp=bullet.instance()
		temp.setType("enemy")
		temp.position=position
		temp.setDir(dir)
		temp.setPower(bulletPower)
		bullets.append(temp)
		Game.mainScene.add_child(temp)

#改变方向
#每个方块的大小是16px 坦克大小32px 图片大小差不多是28px
#坦克的位置一定是16的倍数这样就可以每次旋转都正好在每个方块的边缘
#这样的话就不会出现叠在一起的情况
func turnDir(): 
	if dir==Game.left||dir==Game.right:
		position.y=round((position.y)/16)*16
	else:
		position.x=round((position.x)/16)*16
	

func get_class():
	return 'enemy'
