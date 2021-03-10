extends Node2D

#class_name enemy

var rect=Rect2(Vector2(-14,-14),Vector2(28,28))
var speed=40 
var dir=1 # 0上 1下 2左 3右

var type=0  # 0 typeA  1 typeB 2 typeC 3 typeD
var bulletMax=1	#发射最大子弹数
var armour=0  #护甲等级  不同等级护甲不同
var vec=Vector2.ZERO
var isStop=false#是否停止
var keepDirectionTime=0 #保持方向的时间 ms
var directionTime=0
var targetPos=Vector2(0,0)	#目标位置
var bullet=Game.bullet
var bullets=[]
var fireTime=0
var reloadTime=800
var newDir=0
var bulletPower=Game.bulletPower.normal

var isInit=false
var state=Game.tank_state.IDLE
var initStartTime=0
var initTime=1200  #ms
#var nextState=Game.tank_state.STOP
var isFreeze=false	#冻结
var hasItem=true #是否有物品
var aniStartTime=0	#变化
var aniDelayTime=240 #ms

onready var _ani=$ani
onready var _hit=$hit

func _ready():
	randomize()
	$ani.play("flash")
	$ani.playing=true
	print("isFreeze",isFreeze)
#	if type==0:
#		$ani.play("typeA")
#	elif type==1:
#		$ani.play("typeB")
#	elif type==2:
#		$ani.play("typeC")
#	elif type==3:
#		$ani.play("typeD")
#	if hasItem:
#		aniStartTime=OS.get_system_time_msecs()
	keepDirectionTime = randi()%1800+300	
	pass


#获取矩形
func getRect()->Vector2:
	var temp =rect
	temp.position+=position
	return temp

func getSize():
	return rect.size.x
	

func _update(delta):
	if state==Game.tank_state.IDLE:
		initStartTime+=delta*1000
		if initStartTime>=initTime:
			initStartTime=0
			isInit=true
			$ani.playing=false
			setState(Game.tank_state.START)
	elif state==Game.tank_state.START:
		if dir==0:
			vec.y=-speed
			vec.x=0
		elif dir==1:
			vec.x=0
			vec.y=speed
		elif dir==2:
			vec.x=-speed
			vec.y=0
		elif dir==3:
			vec.y=0
			vec.x=speed		
		else:
			vec=Vector2.ZERO	
		
		directionTime+=delta*1000
		fireTime+=delta*1000
		if isStop:
			keepDirectionTime-=20
			#vec=Vector2.ZERO
	
		if directionTime>keepDirectionTime:
	#		print("change")
			keepDirectionTime=randi()%1800+300	
			directionTime=0
			var p=randf()   #随机概率值
				
			var dx=position.x-targetPos.x
			var dy=position.y-targetPos.y 
			if p>0.4:
				if abs(dx)>abs(dy):
					if dx<0:
						newDir=2
					else:
						newDir=3
					if p>0.7:
						var temp = getNewDir(dir)
						newDir=temp[randi()%temp.size()]	
#					if p<0.7:
#						if dx<0:
#							newDir=2
#						else:
#							newDir=3	
#					else:
#						var temp = getNewDir(dir)
#						newDir=temp[randi()%temp.size()]			
				else:
					if dy<0:
						newDir=1
					else:
						newDir=0
					if p>0.7:
						var temp = getNewDir(dir)
						newDir=temp[randi()%temp.size()]		
#					if p<0.7:
#						if dy<0:
#							newDir=1
#						else:
#							newDir=0
#					else:
#						var temp = getNewDir(dir)
#						newDir=temp[randi()%temp.size()]						
			else:
				var temp = getNewDir(dir)
				newDir=temp[randi()%temp.size()]				
			
			if dir!=newDir:
				if isStop:
					isStop=false	
				dir=newDir
			else:
				dir=newDir	
			
			
		if fireTime>reloadTime:
			fireTime=0
			reloadTime=randi()%1000+200
			fire()
				
		animation(dir,vec)		
		if !isStop:
			position+=vec*delta		
	elif state==Game.tank_state.STOP:
		if !hasItem:
			return
		if type==0:
			if OS.get_system_time_msecs()-aniStartTime>=aniDelayTime:
				aniStartTime=OS.get_system_time_msecs()
				var index=_ani.frame
			#	print("frame",index)
				if _ani.get_animation()=="typeA":
					_ani.animation="typeA_4"
				else:
					_ani.animation="typeA"
				_ani.frame=	index  #设置动画帧数发生变化
			#	print("frame==",_ani.frame)	
			#_ani.play()
			pass	
		elif type==1:
			if OS.get_system_time_msecs()-aniStartTime>=aniDelayTime:
				aniStartTime=OS.get_system_time_msecs()
				var index=_ani.frame
				if _ani.get_animation()=="typeB":
					_ani.animation="typeB_4"
				else:
					_ani.animation="typeB"
				_ani.frame=	index  #设置动画帧数发生变化
		elif type==2:
			if OS.get_system_time_msecs()-aniStartTime>=aniDelayTime:
				aniStartTime=OS.get_system_time_msecs()
				var index=_ani.frame
				if _ani.get_animation()=="typeC":
					_ani.animation="typeC_4"
				else:
					_ani.animation="typeC"
				_ani.frame=	index  #设置动画帧数发生变化
		elif type==3:
			if OS.get_system_time_msecs()-aniStartTime>=aniDelayTime:
				aniStartTime=OS.get_system_time_msecs()
				var index=_ani.frame
				if _ani.get_animation()=="typeD":
					_ani.animation="typeD_4"
				else:
					_ani.animation="typeD"
				_ani.frame=	index  #设置动画帧数发生变化
		pass
	pass

func animation(dir,vec):
	if dir==0:
		_ani.flip_v=true
		_ani.flip_h=true
		_ani.rotation_degrees=0
		pass
	elif dir==1:
		_ani.flip_v=false
		_ani.flip_h=false
		_ani.rotation_degrees=0
		pass
	elif dir==2:
		_ani.flip_v=false
		_ani.flip_h=false
		if _ani.rotation_degrees!=90:
			_ani.rotation_degrees=90
		pass
	elif dir==3:
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
		else:
			if OS.get_system_time_msecs()-aniStartTime>=aniDelayTime:
				aniStartTime=OS.get_system_time_msecs()
				var index=_ani.frame
			#	print("frame",index)
				if _ani.get_animation()=="typeA":
					_ani.animation="typeA_4"
				else:
					_ani.animation="typeA"
				_ani.frame=	index  #设置动画帧数发生变化
			#	print("frame==",_ani.frame)	
			_ani.play()
			pass	
	elif type==1:
		_ani.play("typeB")
	elif type==2:
		_ani.play("typeC")
	elif type==3:
		_ani.play("typeD")
	
#改变方向
func turnDirection():
	newDir=randi()%4	
	pass

func setStop(isStop,dir):
	self.isStop=isStop
	vec=Vector2.ZERO

func getNewDir(dir):
	var temp=[]
	for i in range(4):
		if dir!=i:
			temp.append(i)
	return temp
		
func setPos(pos:Vector2):
	position=pos

func getPos():
	return position

func hit(playerId):
	if armour>0:
		armour-=1
		# todo 播放击中的声音
		
		pass
	else:	
		addExplode(true)
		Game.emit_signal("hitEnemy",type,playerId,position)
		
	if hasItem:
		Game.emit_signal("addBonus",type)
	pass

func addExplode(big):
	var temp=Game.explode.instance()
	if big:
		temp.big=true
	temp.position=position
	Game.otherObj.add_child(temp)
	destroy()

func destroy():
	queue_free()

func setState(state):
	print('setState',state) 
	if state==Game.tank_state.START:
		isInit=true
		self.state=state	
		if isFreeze:
			print("isFreeze",isFreeze)
			animation(dir,vec)
			_ani.stop()
			self.state=Game.tank_state.STOP	
	elif state==Game.tank_state.STOP:
		_ani.stop()
		self.state=state	
		pass
	elif state==Game.tank_state.RESTART:
		isFreeze=false
		self.state=Game.tank_state.START
		
#开火
func fire():
	var del=[]
	for i in bullets: #清理无效对象
		#print(is_instance_valid(i))
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

func get_class():
	return 'enemy'
