extends Node2D
#参考资料 https://developer.ibm.com/technologies/javascript/tutorials/wa-build2dphysicsengine/

var state=Game.game_state.START
var level

var enemyCount=20  #数量
var basePos
var new=false
var hasClock=false#时钟是否处于开启+
var maxClockTick=8000 #ms
var clockTick=0
var hasShovel=false #是否获取道具铲子
var maxShoveTime=20000 #ms
var getShoveTime=0	#获取道具铲子的时间
var changeBrickTime=0  #ms
var brickType=Game.brickType.brickWall	#变化类型
var minEnemyCount=4	#最小敌人数量 2人就6个
var gamePause=false	#游戏暂停
var isNoBase=false #基地被摧毁游戏不结束

#每个人击中的数量
var p1Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
var p2Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}

var bonus=preload("res://scenes/bonus.tscn")
var scoreScene=preload("res://scenes/fontLabel.tscn")


onready var _tank = $map/tanks
onready var _brick=$map/brick
onready var _bullet=$map/bullets
onready var _bonus=$map/bonus
onready var _map=$map
onready var _base=$map/base
onready var _ani=$ani
onready var _addEnemy=$addEnemy
onready var _nextLevel=$nextLevel
onready var _clock=$clockTimer
onready var _shovel=$shovelTimer
onready var _pause=$gui/pause
onready var _p1Over=$gui/p1Over
onready var _p2Over=$gui/p2Over

func _ready():
	randomize()
#	print(OS.get_system_time_msecs())
	Game.connect("baseDestroyed",self,"baseDestroy")
	Game.otherObj=$map/obj
	Game.mainScene=$map/bullets
#	Game.level=15
	print(Game.mapNameList[Game.level])
	_map.loadMap(Game.mapDir+"/"+Game.mapNameList[Game.level])
	_map.mode=0
#	_map.loadMap(Game.mapDir+"/5.json")
	if Game.mode==1:
		_map.addNewPlayer(1,false,Game.p1State)
	elif Game.mode==2:
		minEnemyCount=6
		if Game.playerLive[0]>0:
			_map.addNewPlayer(1,false,Game.p1State)
		if Game.playerLive[1]>0:	
			_map.addNewPlayer(2,false,Game.p2State)	
#	_map.addNewPlayer(1,false,Game.p1State)	
#	_map.addNewPlayer(2,false,Game.p2State)		
	basePos=Vector2(_map.basePos.x*_map.cellSize,_map.basePos.y*_map.cellSize)
#	_map.addEnemy(basePos)	#添加敌人

	_map.setLevelName(Game.level+1)
	#设置生命数量
	_map.setPlayerLive(1,Game.playerLive[0])
	_map.setPlayerLive(2,Game.playerLive[1])
	_addEnemy.connect("timeout",self,"addEnemyDelay")
	_addEnemy.start()
	_nextLevel.connect("timeout",self,"nextLevel")
	Game.connect("hitEnemy",self,"hitEnemy")
	Game.connect("addBonus",self,"addBonus")
	Game.connect("hitPlayer",self,"hitPlayer")
	_clock.connect("timeout",self,"stopClock")
	_shovel.connect("timeout",self,"shovelTimerEnd")
	
	pass 


func _process(delta):
	if state==Game.game_state.LOAD:
		if Input.is_action_just_pressed("ui_accept"):
			setState(Game.game_state.START)
			pass
	elif state==Game.game_state.START:
		for i in _tank.get_children():  #更新
			i._update(delta)
		
		for i in _tank.get_children():	#检查坦克与砖块的碰撞
			var rect=i.getRect()
			var isStop=false
			var isOnIce=false
			for y in _brick.get_children():
				if y.get_class()=="brick":
					var type=y.getType() #装快的类型
					var rect1=y.getRect()	#砖块矩形
					if type==Game.brickType.bush or type==Game.brickType.ice:	#草丛
						if type==Game.brickType.ice:
							if i.get_class()=='player' && rect.intersects(rect1):
								isOnIce=true
							
						continue
					if type==Game.brickType.water: #水
						if i.has_method("hasShip"):
							if i.hasShip():
								continue
					
					if rect.intersects(rect1):  #碰撞  只判断坦克前进的方向是否有物体
						if rect1.encloses(rect):#完全叠一起
							continue

						var iTankDir=i.dir
						var xVal =i.position.x-y.position.x
						var yVal =i.position.y-y.position.y
						var absXVal=abs(xVal)
						var absYVal=abs(yVal)
						if iTankDir in [Game.up,Game.down]:	#上下
							if absYVal<i.getSize() and absYVal>i.getSize()/2:
								if yVal<0 and iTankDir==Game.down:
									isStop=true
								elif yVal>0	and iTankDir==Game.up:
									isStop=true
							else:
								isStop=false
						elif iTankDir in [Game.left,Game.right]:	#左右
							if absXVal<i.getSize() and absXVal>i.getSize()/2:			
								if xVal<0 and iTankDir==Game.right:
									isStop=true
								elif xVal>0 and iTankDir==Game.left:
									isStop=true
							else:
								isStop=false	
			i.setStop(isStop)
			if i.get_class()=='player':
				i.setOnIce(isOnIce)				
					
		for i in _bullet.get_children():	#子弹跟方块
			if i.get_class()=="bullet":
				var rect=i.getRect()
				for y in _brick.get_children():
					if y.get_class()=="brick":
						var rect1=y.getRect()
						var type=y.getType()
						if type==Game.brickType.bush or type==Game.brickType.ice or \
							type==Game.brickType.water:
								continue	
						if rect.intersects(rect1,false):  #碰撞
							if y.getType()==Game.brickType.stoneWall and \
								i.getType()==Game.bulletType.players:
								SoundsUtil.playBullet()
							i.addExplode(false)
							y.hit(i.getDir(),i.getPower())
							
		for i in _bullet.get_children():	#同一个子弹
			if i.get_class()=="bullet":
				var typeA = i.getType()
				var rect=i.getRect()
				for y in _bullet.get_children():
					if i!=y && y.get_class()=="bullet": #排除同一个
						var rect1=y.getRect()
						if rect.intersects(rect1,false):
							var typeB=y.getType()
							if typeA==Game.bulletType.players and typeB==Game.bulletType.enemy:
								i.destroy()
								y.destroy()
							elif typeA==Game.bulletType.enemy and typeB==Game.bulletType.players:
								i.destroy()
								y.destroy()
		
	
		for i in _tank.get_children():	#坦克与坦克的碰撞
			var isStop=false
			for y in _tank.get_children():
				if i!=y:
					if i.isInit && y.isInit:
						var rect=i.getRect()
						var rect1=y.getRect()
						var iTankDir=i.dir
						var yTankDir=y.dir
						var xVal =i.position.x-y.position.x
						var yVal =i.position.y-y.position.y
						var absXVal=abs(xVal)
						var absYVal=abs(yVal)
						
						if rect.intersects(rect1,false):
							if iTankDir in [Game.up,Game.down]:	#上下 判断坦克前面的位置有没有坦克
								if absYVal<i.getSize() and absYVal>i.getSize()/2:
									if yVal<0 and iTankDir==Game.down:
										isStop=true
									elif yVal>0	and iTankDir==Game.up:
										isStop=true
								else:
									isStop=false
							elif iTankDir in [Game.left,Game.right]:	#左右
								if absXVal<i.getSize() and absXVal>i.getSize()/2:			
									if xVal<0 and iTankDir==Game.right:
										isStop=true
									elif xVal>0 and iTankDir==Game.left:
										isStop=true
								else:
									isStop=false
			if !i.isStop:#已经停止就不设置
				i.setStop(isStop)
	
		
		for i in _tank.get_children():	#子弹与坦克
			for y in _bullet.get_children():
				var rect=i.getRect()
				var rect1=y.getRect()
				if !i.isInit:
					continue
				if i.isDead():	#坦克死亡
					continue	
				if rect.intersects(rect1,false):
					var typeA = i.get_class()
					var typeB=y.getType()
					if typeA=="player" and typeB==Game.bulletType.enemy:
						y.destroy()
						i.hit(typeB)
					elif typeA=="enemy" and typeB==Game.bulletType.players:
						y.destroy()
						i.hit(y.playerID)
						
		for i in _bullet.get_children(): #子弹边界
			if i.position.x<_map.offset.x or i.position.x>_map.mapRect.size.x+_map.mapRect.position.x:
				if i.type==Game.bulletType.players:
					SoundsUtil.playBullet()
				i.addExplode(false)
			if	i.position.y<_map.offset.y or i.position.y>_map.mapRect.size.y+_map.mapRect.position.y:
				if i.type==Game.bulletType.players:
					SoundsUtil.playBullet()
				i.addExplode(false)
			pass
		
		for i in _tank.get_children():		#边界
			var type=i.get_class()
			var rect=i.getRect()
			if i.position.x-i.getSize()/2 <_map.mapRect.position.x:
				i.position.x = _map.mapRect.position.x+i.getSize()/2
			if i.position.x+i.getSize()/2>_map.mapRect.size.x+_map.mapRect.position.x:
				i.position.x = _map.mapRect.size.x+_map.mapRect.position.x-i.getSize()/2
			if i.position.y-i.getSize()/2<_map.mapRect.position.y:
				i.position.y= _map.mapRect.position.y+i.getSize()/2	
			if i.position.y+i.getSize()/2>_map.mapRect.size.y+_map.mapRect.position.y:
				i.position.y = _map.mapRect.size.y+_map.mapRect.position.y-i.getSize()/2	
		
		
		for i in _bonus.get_children():
			var rect=i.getRect()
			for y in _tank.get_children():
				if y.get_class()=="player":
					var rect1=y.getRect()
					if rect.intersects(rect1,false):
						var type=i.getType()
						i.destroy()
						getBonus(type,y.getPlayId())
		
		for i in _base.get_children():
			if !i.destroy:
				var rect=i.getRect()
				for y in _bullet.get_children():
					var rect1=y.getRect()
					if rect.intersects(rect1,false):
						i.setBaseDestroyed()
						y.destroy()
						
		for y in _base.get_children():  # 基地和坦克的碰撞
			if !y.destroy:
				for i in _tank.get_children():
					var rect=y.getRect()
					var rect1=i.getRect()
					if rect1.intersects(rect,false):
						if rect1.encloses(rect):
							continue

						var dx=(y.getPos().x-i.position.x)/(y.getSize()/2)
						var dy=(y.getPos().y-i.position.y)/(y.getSize()/2)
						var absDX = abs(dx)
						var absDY = abs(dy)

						if abs(absDX - absDY) < .1:
							if dx<0:
								i.position.x=y.getPos().x+y.getSize()/2+i.getSize()/2			
							else:
								i.position.x=y.getPos().x-y.getSize()/2-i.getSize()/2	

							if dy<0:
								i.position.y=y.getPos().y+y.getSize()/2+i.getSize()/2			
							else:
								i.position.y=y.getPos().y-y.getSize()/2-i.getSize()/2						
						elif absDX > absDY:
							
							if dx<0:
								i.position.x=y.getPos().x+y.getSize()/2+i.getSize()/2					
							else:
								i.position.x=y.getPos().x-y.getSize()/2-i.getSize()/2		
						else:
							
							if dy<0:
								i.position.y=y.getPos().y+y.getSize()/2+i.getSize()/2
							else:
								i.position.y=y.getPos().y-y.getSize()/2-i.getSize()/2
						i.setStop(true)	
		

		if hasShovel:	#铲子
			if _shovel.get_time_left()<=5:
				if OS.get_system_time_msecs()-changeBrickTime>=350:
					changeBrickTime=OS.get_system_time_msecs()	
					_map.changeBasePlaceBrickType(brickType)	
					if brickType==Game.brickType.brickWall:
						brickType=Game.brickType.stoneWall
					elif brickType==Game.brickType.stoneWall:
						brickType=Game.brickType.brickWall
			pass
		
	elif state==Game.game_state.NEXT_LEVEL:
		
		pass
	elif state==Game.game_state.OVER:
		pass
	pass

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if (event as InputEventKey).scancode==KEY_ENTER:	
				gamePause()

#显示分数
func addScore(num,pos):
	var temp=scoreScene.instance()
	temp.setNum(num)
	temp.position=pos
	Game.otherObj.add_child(temp)
	pass

func addEnemyDelay():
#	print("addEnemyDelay")
	if _addEnemy.is_stopped():
		addEnemy()
	#	_addEnemy.start()
		pass
	else:
		_addEnemy.stop()
		_addEnemy.start()
		pass
	pass

func addEnemy():
	if enemyCount>0:
		if getEnemyCount()<minEnemyCount:
			if hasClock:
				_map.addEnemy(basePos,true)
			else:
				_map.addEnemy(basePos)
			enemyCount-=1
			print('enemyCount ',enemyCount)	
			_addEnemy.start()	
		else:
			_addEnemy.start()				
	else:  #所有敌人全部消灭
		if getEnemyCount()<=0:
			print("next ",enemyCount)
			_nextLevel.start()
		else:
			_addEnemy.start()

#获取敌人数量
func getEnemyCount():
	var num=0
	for i in _tank.get_children():
		if i.get_class()=="enemy" and !i.isDead():
			num+=1
	return num

#下一关
func nextLevel():
	print("nextLevel")
	#保存玩家的状态
	var data=_map.getPlayerStatus()
	Game.p1State['level']=data['p1']['level']
	Game.p1State['life']=data['p1']['life']
	Game.p1State['hasShip']=data['p1']['hasShip']
	Game.p2State['level']=data['p2']['level']
	Game.p2State['life']=data['p2']['life']
	Game.p2State['hasShip']=data['p2']['hasShip']
	Game.p1Score=p1Score
	Game.p2Score=p2Score
	Game.changeScene("res://scenes/menu.tscn")
	pass

#设置状态
func setState(state):
	if state==Game.game_state.START:
		#print('loadMap')
		
		pass
	elif state==Game.game_state.NEXT_LEVEL:
		
		pass	
	elif state==Game.game_state.OVER:
		
		pass
	elif state==Game.game_state.PAUSE:
		pass	
	self.state=state

#击中敌人
func hitEnemy(enemyType,players,pos):
	if enemyType==Game.enemyType.TYPEA:
		if players==1:
			p1Score["typeA"]+=1
			Game.playerScore['player1']+=100
		elif players==2:
			p2Score["typeA"]+=1
			Game.playerScore['player2']+=100				
		addScore(100,pos)
	elif enemyType==Game.enemyType.TYPEB:	
		if players==1:
			p1Score["typeB"]+=1
			Game.playerScore['player1']+=200
		elif players==2:
			p2Score["typeB"]+=1
			Game.playerScore['player2']+=200
		addScore(200,pos)	
	elif enemyType==Game.enemyType.TYPEC:		
		if players==1:
			p1Score["typeC"]+=1
			Game.playerScore['player1']+=300
		elif players==2:
			p2Score["typeC"]+=1	
			Game.playerScore['player2']+=300
		addScore(300,pos)		
	elif enemyType==Game.enemyType.TYPED:	
		if players==1:
			p1Score["typeD"]+=1
			Game.playerScore['player1']+=400
		elif players==2:
			p2Score["typeD"]+=1	
			Game.playerScore['player2']+=400
		addScore(400,pos)				
#	print(p1Score)
#	print(p2Score)
	SoundsUtil.playEnemyDestroy()
	#addEnemyDelay()
#	if _addEnemy.is_stopped():#添加新坦克
#		_addEnemy.start()
	pass

#基地毁灭	
func baseDestroy():
	print('baseDestroy')
	SoundsUtil.playBaseDestroy()
	if isNoBase: #五基地继续战斗
		return
	gameOver()
	#setState(Game.game_state.OVER)
	pass

#游戏结束
func gameOver():
	if !Game.isGameOver:
		_ani.play("gameover")
		Game.isGameOver=true
		_map.setPlayerFreeze()
		yield(_ani,"animation_finished")
		_nextLevel.start()
	pass

#添加坦克生命
func addTankLife(id):
	if id==1:
		Game.playerLive[0]+=1
		_map.setPlayerLive(1,Game.playerLive[0])	
	elif id==2:
		Game.playerLive[1]+=1
		_map.setPlayerLive(2,Game.playerLive[1])

#获取到物品 id 1=1p 2=2p
func getBonus(type,id):
	print("type",type,"id",id)
	if id==1:
		Game.playerScore['player1']+=500
	elif id==2:
		Game.playerScore['player2']+=500	
	
	var tank=_map.getPlayerById(id)
	if tank:
		addScore(500,tank.getPos())		
	if type==0:	#手雷
		var list=_map.clearEnemyTank()
		if id==1:
			p1Score["typeA"]+=list['typeA']
			p1Score["typeB"]+=list['typeB']
			p1Score["typeC"]+=list['typeC']
			p1Score["typeD"]+=list['typeD']
		elif id==2:
			p2Score["typeA"]+=list['typeA']
			p2Score["typeB"]+=list['typeB']
			p2Score["typeC"]+=list['typeC']
			p2Score["typeD"]+=list['typeD']
#		print('手雷',list)
		SoundsUtil.playBomb()
#		if _addEnemy.is_stopped():#添加新坦克
#			_addEnemy.start()
	elif type==4:#坦克增加
		SoundsUtil.playLife()
		addTankLife(id)
	else:
		if type==1: #帽子
			if tank:
				tank.setEnableInvincible()	
		elif type==2:#时钟
			startClock()
		elif type==3:	#铲子
			getShovel()
		elif type==5:  #星星
			if tank:
				tank.addPower()		
		elif type==6:	#手枪
			if tank:
				tank.addMaxPower()	
		elif type==7:
			if tank:
				tank.addship()	
		elif type==8: #没有基地游戏继续
			isNoBase=true
		SoundsUtil.playGetBouns()
	pass

#定时器
func startClock():
	hasClock=true
	_map.setEnemyFreeze()
	if _clock.is_stopped():
		_clock.start()
	else:
		_clock.stop()
		_clock.start()

func stopClock():
	print('stopClock')
	hasClock=false
	_map.setEnemyFreeze(false)

#铲子定时器
func shovelTimerEnd():
	hasShovel=false
	brickType==Game.brickType.brickWall
	_map.changeBasePlaceBrickType(Game.brickType.brickWall)
	pass

#获取到铲子	
func getShovel():
	_map.delBaseBrickPos()
	_map.addBaseStone()
	hasShovel=true
	if _shovel.is_stopped():
		_shovel.start()
	else:
		_shovel.stop()
		_shovel.start()
	pass

#添加物品
func addBonus(enemyType):
	SoundsUtil.playBouns()
	_map.addBonus()
	pass

#玩家被消灭 id=1 1p, =2 2p
func hitPlayer(id):
#	print('id',id)
	SoundsUtil.playTankDestroy()
	if Game.mode==1: #一个人的时候
		if Game.playerLive[0]<=0:
			gameOver()
	elif Game.mode==2:		
		if Game.playerLive[0]<=0 and Game.playerLive[1]<=0:
			gameOver()
		if Game.playerLive[0]==0:
			_p1Over.startHideTimer()
		elif Game.playerLive[1]==0:
			_p2Over.startHideTimer()	
	if id==1 and Game.playerLive[0]>0:
		Game.playerLive[0]-=1
		_map.addNewPlayer(1,Game.isGameOver)
	elif id==2 and Game.playerLive[1]>0:
		Game.playerLive[1]-=1
		_map.addNewPlayer(2,Game.isGameOver)

		
#游戏暂停	
func gamePause():
	if Game.isGameOver:
		return
	if gamePause:
		gamePause=false
		_pause.visible=false
		setState(Game.game_state.START)
		get_tree().paused=false
		_addEnemy.paused=false
		_nextLevel.paused=false
		_clock.paused=false
		_shovel.paused=false
	else:
		gamePause=true
		_pause.visible=true
		setState(Game.game_state.PAUSE)
		get_tree().paused=true
		_addEnemy.paused=true
		_nextLevel.paused=true
		_clock.paused=true
		_shovel.paused=true
	SoundsUtil.playPause()
	pass

