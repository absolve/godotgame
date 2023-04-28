extends Node2D
#新的地图 新的碰撞检测
#参考资料(关于碰撞) https://developer.ibm.com/technologies/javascript/tutorials/wa-build2dphysicsengine/
#https://developer.ibm.com/tutorials/wa-build2dphysicsengine/?mhsrc=ibmsearch_a&mhq=wa-build2dphysicsengine

const blockSize=32  #方块的大小
const minWidthNum=20  #一个屏幕宽20块
const heightNun=15 #一个屏幕高15块


var brick=preload("res://scenes/brick.tscn")
var box=preload("res://scenes/box1.tscn")
var pipe=preload("res://scenes/pipe.tscn")
var background=preload("res://scenes/bg.tscn")
var mario=preload("res://scenes/mario1.tscn")
var pole=preload("res://scenes/pole.tscn")
var goomba=preload("res://scenes/goomba.tscn")
var collision=preload("res://scenes/collision.tscn")
var plant=preload("res://scenes/plant.tscn")
var score=preload("res://scenes/score.tscn")
var koopa=preload("res://scenes/koopa.tscn")
var menu=preload("res://scenes/menu.tscn")
var firework=preload("res://scenes/firework.tscn")
var castleFlag=preload("res://scenes/flag.tscn")
var bigCoin=preload("res://scenes/bigCoin.tscn")
var platform=preload("res://scenes/platform.tscn")
var label=preload("res://scenes/label.tscn")
var spinFireball=preload("res://scenes/spinFireball.tscn")
var bridge=preload("res://scenes/bridge.tscn")
var bowser=preload("res://scenes/bowser.tscn")
var axe=preload("res://scenes/axe.tscn")
var figures=preload("res://scenes/figures.tscn")
var vine=preload("res://scenes/vine.tscn")
var jumpingBoard=preload("res://scenes/JumpingBoard.tscn")
var cheapcheap=preload("res://scenes/cheapcheap.tscn")
var bloober=preload("res://scenes/bloober.tscn")
var podoboo=preload("res://scenes/podoboo.tscn")
var lakitu=preload("res://scenes/lakitu.tscn")
var cannon=preload("res://scenes/cannon.tscn")
var hammerBro=preload("res://scenes/hammerBro.tscn")
var staticPlatform=preload("res://scenes/staticPlatform.tscn")
var linkPlatform=preload("res://scenes/linkPlatform.tscn")
var fire=preload("res://scenes/fire.tscn")
var bulletBill=preload("res://scenes/bulletBill.tscn")
var beetle=preload("res://scenes/beetle.tscn")
var mazeGate=preload("res://scenes/mazeGate.tscn")

onready var _obj=$obj
onready var _tile=$tile
onready var _fps=$layer/fps
onready var _camera=$camera
onready var _timer=$Timer
onready var _gameover=$gameover
onready var _title=$title

#var path="res://levels/1-1.json"
var mapDir="res://levels"	#内置地图路径
var currentLevel
var mapWidthSize=0
var mapName=''  #地图的名字
var time=0		#时间
var music
var marioPos={} #mario地图出生地
#var mode="game"  #game正常游戏  edit编辑  test测试  show展示
var mapData={}  #地图以x,y为key value为对象
var marioList=[]
var winWidth  #屏幕大小
var winHeight
var specialEntrance=[] #特殊入口
var subLevel="" #子关卡 是否从水管或者树里面出来
var isLoadsubLevel=false
var nextLevel=""  #下一关
var nextSubLevel="" #下一关 从水管或者树里面出来或者从天上
var enemyList=[]	#敌人的列表 等屏幕移动后在初始化
var enemyPosList={} #敌人位置列表
var marioDeathPos={}  #记录上次死亡的地方
var checkPoint=[] #检查点 用于判断马里奥死亡后重新复活的位置
var warpZone=[]	#就是可以跳关的水管
var hasAddWarpZone=false
var isShow=false #仅仅展示
var marioStatus='' #mairio状态
var debug=false #调试模式
var castleBridge=[]  #保存桥的数据
var castleEndX=0 #城堡最后斧头的位置
var scrollEnd = false #摄像机滚动到最后
var bonusLevel=false  #是否是奖励关卡
var underwater=false #是否水下
var areaList=[] #区域列表
var flyingFishStart=false
var flyingFishTimer=0
var flyingFishDelay=60
var fireStart=false  #火焰发射是否开始
var fireTimer=0
var fireDelay=70
var bulletStart=false #炮弹准备开始
var bulletTimer=0
var bulletDelay=80
var gamePause=false  #游戏暂停
var gameOver=false #游戏结束
var mazeList={}  #迷宫列表  key 迷宫id value 迷宫数据
var mazeObjList={} #迷宫中场景的方块和箱子的数据 key 迷宫id value 迷宫场景数据

func _ready():
	randomize()
	Game.setMap(self)
#	winWidth= ProjectSettings.get_setting("display/window/size/width")
#	winHeight=ProjectSettings.get_setting("display/window/size/height")
	winWidth=get_viewport_rect().size.x
	winHeight=get_viewport_rect().size.y
#	print(winWidth,winHeight)
	Game.connect("marioStateChange",self,'marioStateChange')
	Game.connect("marioStateFinish",self,'marioStateFinish')
	Game.connect("invincibleFinish",self,"invincibleFinish")
	Game.connect("marioInCastle",self,"marioInCastle")
	Game.connect("marioIntoPipe",self,"marioIntoPipe")
	Game.connect("timeOut",self,"timeOut")
	Game.connect("hurryup",self,"hurryup")
	Game.connect("countFinish",self,"countFinish")
	Game.connect("marioDead",self,"marioDead")
	Game.connect("marioStartSliding",self,"marioStartSliding")
	Game.connect('marioContactAxe',self,'marioContactAxe')
	Game.connect('vineEnd',self,'vineEnd')
	Game.connect('marioGrapVineTop',self,'marioGrapVineTop')

	
	if isShow:
		_fps.visible=false
		return
		

#	loadMapFile("res://levels/test37.json")
	var dir = Directory.new()
	if dir.file_exists(mapDir+'/'+Game.playerData['level']+".json"):
		print("ok")
		loadMapFile(mapDir+'/'+Game.playerData['level']+".json")
	else:
		print("文件不存在")
	
	var tempTime=Game.playerData['time']
	subLevel=Game.playerData['subLevel']
	if subLevel=='':
		if !marioDeathPos.empty():
			checkPoint.sort_custom(self,'sort')
			var temp=null
			for i in checkPoint:
				if marioDeathPos['x']>=i['x']:
					temp=i
					continue
			if temp!=null: #设置复活点
				for i in marioList:
					i.position.x=temp['x']
					i.position.y=temp['y']
				_camera.position.x=temp['x']-int(winWidth/3)
				if _camera.position.x<0:
					_camera.position.x=0
				initPlantEnemy()
			else:
				initEnemy()
		else:
			initEnemy()	#初始化当前画面的敌人
	else:
		for i in specialEntrance:
			if i.has('pipeNo') && i['pipeNo']==subLevel&&i['pipeType']==constants.pipeOut:
				for y in marioList:
					y.position.x = i['x']*blockSize
					y.position.y= i['y']*blockSize+\
						blockSize+y.getSizeY()/2
					y.setPipeOutStatus(i['y']*blockSize)
					_camera.position.x=	i['x']*blockSize-int(winWidth/3)
					if _camera.position.x<0:
						_camera.position.x=0
					initEnemy()	#初始化当前画面的敌人
					break
				break
			elif i['type']==constants.collision && i['pos']==subLevel: #从天上掉下来
				for y in marioList:
					y.position.x = i['x']*blockSize
					y.position.y= i['y']*blockSize+\
						blockSize+y.getSizeY()/2
#					y.setPipeOutStatus(i['y']*blockSize)
					_camera.position.x=	i['x']*blockSize-int(winWidth/3)
					if _camera.position.x<0:
						_camera.position.x=0
					initEnemy()	#初始化当前画面的敌人
					break
				break
			
	if time<100:
		SoundsUtil.isLowTime=true
	SoundsUtil.playBgm()	
	if tempTime!=0:
		_title.setTime(tempTime)
	else:
		_title.setTime(time)

	if marioStatus!=constants.onlywalk&&!bonusLevel: #排除自动进入水管和奖励关卡
		_title.startCountDown()
		pass
	
	if marioStatus==constants.autoGrabVine:  #从藤蔓下方爬出来
		for i in marioList:
			var temp = vine.instance()
			temp.position.x=i.position.x
			temp.position.y=get_viewport_rect().size.y+blockSize/2
			temp.length=5
			_obj.add_child(temp)
			i.setAutoGrabVine(temp)
			i.position.y=get_viewport_rect().size.y+i.getSizeY()#自动设置成屏幕外
			break
		SoundsUtil.playItem()
		
	if castleBridge.size()>0:
		castleBridge.sort_custom(self,'bridgeSort')
		
	_title.setScore(Game.playerData['score'])
	_title.setCoin(Game.playerData['coin'])
	_title.setLevel(mapName)
#	print(enemyPosList)

#排序大到小
func bridgeSort(a,b):
	if a['localx']>b['localx']:
		return true
	else:
		return false

func sort(a,b):
	if a['x']>b['x']:
		return true
	else:
		return false

func _physics_process(delta):
#	_update(delta)
	_fps.set_text(str("fps:",Engine.get_frames_per_second()))
	_title._update(delta)
	
	for i in _obj.get_children():	
		if i.destroy:
			i.queue_free()
		if i.type!=constants.box&&i.type!=constants.pole&&i.type!=constants.collision&&\
			i.type!=constants.bigCoin&&i.type!=constants.castleFlag&&i.type!=constants.platform\
			&&i.type!=constants.spinFireball&&i.type!=constants.axe&&i.type!=constants.figures&&\
			i.type!=constants.bowser&&i.type!=constants.podoboo&&i.type!=constants.cannon&&\
			i.type!=constants.jumpingBoard&&i.type!=constants.vine&&i.type!=constants.staticPlatform\
			&&i.type!=constants.linkPlatform&&i.type!=constants.flyingfish:
			if i.getRight()<_camera.position.x||i.getLeft()>_camera.position.x+winWidth*1.6:
				i.queue_free()
			if i.getTop()>winHeight:
				if i.type==constants.mario :
					if i.status!=constants.autoGrabVine:
						if bonusLevel:
							loadSubLevelMap(nextLevel,nextSubLevel)
						else:
							if i.status!=constants.deadJump:
								marioDead(i.position.x)
							_gameover.start()	
							i.queue_free()
								
				else:	
					i.queue_free()
		elif i.type==constants.bowser:
			if i.getTop()>winHeight:
				if i.status!=constants.deadJump:
					bowserDrop()	
				i.queue_free()	
		elif i.type==constants.staticPlatform:
			if i.getLeft()>mapWidthSize*blockSize:
				i.queue_free()
			if i.getTop()>winHeight:
				i.queue_free()
		elif i.type==constants.flyingfish:
			if i.getLeft()>_camera.position.x+winWidth*1.6:
				i.queue_free()
			if i.getTop()>winHeight&&i.yVel>0:
				i.queue_free()	
				
	#todo 改为只更新屏幕内的箱子	
#	for i in _tile.get_children():
#		if i.type==constants.box||i.type==constants.bridge:
#			if i.active:
#				i.yVel+=i.gravity*delta		#增加y速度
#				if i.yVel>i.maxYVel:
#					i.yVel=i.maxYVel
#			if i.destroy:
#				mapData[str(i.localx,',',i.localy)]=null
#				i.queue_free()
#			else:
#				i._update(delta)
	
	for i in range(floor(_camera.position.x/blockSize),
		floor((_camera.position.x+winWidth)/blockSize)+1):
		for y in range(0,winHeight/blockSize+1):
			if mapData.has(str(i,',',y)):
				var b=mapData[str(i,',',y)]
				if b.type==constants.box||b.type==constants.bridge:	
					if b.active:
						b.yVel+=b.gravity*delta		#增加y速度
						if b.yVel>b.maxYVel:
							b.yVel=b.maxYVel
					if b.destroy:
						mapData[str(b.localx,',',b.localy)]=null
						b.queue_free()
						mapData.erase(str(b.localx,',',b.localy))
					else:
						b._update(delta)
	
		
	for i in _obj.get_children():
		if i.active:
			i.yVel+=i.gravity*delta		#增加y速度
			if i.yVel>i.maxYVel:
				i.yVel=i.maxYVel
		i._update(delta)
	
	if marioList.size()>0:
		var mario1=marioList[0]
		if is_instance_valid(mario1):
			if mario1.getLeft()<_camera.position.x:
				mario1.position.x=_camera.position.x+mario1.getSize()/2
				if mario1.dir==constants.left:
					mario1.xVel=0
			elif mario1.getRight()>mapWidthSize*blockSize:
				mario1.position.x=mapWidthSize*blockSize-mario1.getSize()/2
				if mario1.dir==constants.right:
					mario1.xVel=0
			elif castleEndX!=0&&mario1.getRight()>castleEndX: #防止跳过斧头
				mario1.position.x=castleEndX-mario1.getSize()/2
				if mario1.dir==constants.right:
					mario1.xVel=0
					
			#前进
			if mario1.status!=constants.sitBottomOfPole&& mario1.xVel>0 \
				&& mario1.position.x>_camera.get_camera_screen_center().x&&\
					_camera.position.x <mapWidthSize*blockSize-winWidth:
				if _camera.position.x>mapWidthSize*blockSize-winWidth:
					_camera.position.x=mapWidthSize*blockSize-winWidth
				else:
					if castleEndX!=0: #判断是否到了斧头的那一边
						if _camera.position.x+winWidth<castleEndX:
							_camera.position.x+=mario1.xVel*delta
					else:
						_camera.position.x+=mario1.xVel*delta
			#如果马里奥是最后通关的话 摄像机直接拉到最后	
			if 	scrollEnd:
				if _camera.position.x<mapWidthSize*blockSize-winWidth:
					_camera.position.x+=100*delta
				else:
					marioCastleEnd()
					scrollEnd=false
			
			#后退		
			if mario1.xVel<0 && mario1.position.x<_camera.get_camera_screen_center().x-40&&\
				_camera.position.x>0:
				if _camera.position.x<0:
					_camera.position.x=0
				else:
					_camera.position.x-=abs(mario1.xVel*delta)

			#判断屏幕右侧的敌人是否需要添加
			var startPos=floor((_camera.position.x+winWidth)/blockSize)
			var endPos=floor((_camera.position.x+winWidth*1.2)/blockSize)
			for i in range(startPos,endPos+1):
				if enemyPosList.has(str(i)):
					for y in enemyPosList[str(i)]:
						if y['init']:
							continue
						else:	
							addEnemy(y)
							y['init']=true
			#判断warpzone
			if warpZone.size()>0:
				if !hasAddWarpZone:
					if mario1.position.x>warpZone[0].x*blockSize-blockSize*2:
						addWarpZoneMsg()
						hasAddWarpZone=true
						
	#对区域进行判断					
	flyingFishStart=false
	fireStart=false
	bulletStart=false
	for i in marioList:
		if is_instance_valid(i):
			for y in areaList:
				if y.type==constants.flyingfish:
					if y['startX']<i.position.x && y['endX']>i.position.x:
						flyingFishStart=true
				elif y.type==constants.fire:
					if y['startX']<i.position.x && y['endX']>i.position.x:
						fireStart=true
				elif y.type==constants.bulletBill:
					if y['startX']<i.position.x && y['endX']>i.position.x:
						bulletStart=true	
			#如果马里奥到了迷宫的尽头判断游戏地图是不是只有一个屏幕大小
			#如果不是就在屏幕外部添加一段迷宫地图，并把原先地图后移，在把迷宫信息
			#设置成新的位置，如果迷宫失效直接忽略	
#			for m in mazeList:
#				if mazeList[m].vaild:
#					if mazeList[m]['endX']<i.position.x:
#						print(mazeList[m])		
#						var tempMapList=[]
#						var mazeLength=(mazeList[m]['endX']-mazeList[m]['startX'])
#						print('mazeLength',mazeLength)
#						for z in range(floor((_camera.position.x+winWidth)/blockSize)+1,mapWidthSize):
#							for w in range(0,winHeight/blockSize+1):
#								if mapData.has(str(z,',',w)):
#									var b=mapData[str(z,',',w)]
#									b.position.x+=mazeLength
#									b.localx+=mazeLength/blockSize
#									tempMapList.append(b)
#									mapData.erase(str(z,',',w))
#
#						for t in tempMapList:	#重建方块的字典
#							mapData[str(t.localx,",",t.localy)]=t
#						#移动屏幕外敌人的位置	
#						for z in range(mapWidthSize,floor((_camera.position.x+winWidth)/blockSize)):
#							if enemyPosList.has(str(z)):	
#								var temp=enemyPosList[str(z)]
#								enemyPosList[str(z+mazeLength)]=temp
#								for e in temp:
#									e.x+=mazeLength/blockSize
#								enemyPosList.erase(str(z))
#
#						mapWidthSize+=mazeLength/blockSize
#						if castleEndX!=0:	#把斧头的位置移动
#							castleEndX+=mazeLength
#						#复制迷宫里面的场景信息
#						var offsetx=floor((_camera.position.x+winWidth-mazeList[m]['startX'])/blockSize)+1
#						print(offsetx,' ',offsetx/blockSize)
#						var tempList=mazeObjList[m]
##						print(tempList)
#						for x in tempList:
#							var temp=x.duplicate()
#							for property in x.get_property_list():
#								if(property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE): 
#									temp[property.name] = x[property.name]
#							temp.localx+=offsetx
#							temp.position.x+=offsetx*blockSize
#							x.localx+=offsetx
#							x.position.x+=offsetx*blockSize
#							_tile.add_child(temp)
##							print(str(temp.localx,",",temp.localy))
#							mapData[str(temp.localx,",",temp.localy)]=temp
#
#						#移动迷宫内敌人的位置
#						for w in range(mazeList[m].startX/blockSize,mazeList[m].endX/blockSize):
#							if enemyPosList.has(str(w)):
#								var temp=enemyPosList[str(w)]
#								enemyPosList[str(w+offsetx)]=temp.duplicate(true)
#								for e in enemyPosList[str(w+offsetx)]:
#									e.x+=offsetx
#									e.init=false
#
#
#
#						mazeList[m].startX+=offsetx*blockSize
#						mazeList[m].endX+=offsetx*blockSize
#						print(mazeList[m])
#						mazeList[m].vaild=false	
					
									
	#飞鱼
	if flyingFishStart:
		flyingFishTimer+=1
		if flyingFishTimer>flyingFishDelay&&!gamePause:
			flyingFishTimer=0
			flyingFishDelay=randi()%130+30
			var temp=cheapcheap.instance()
			temp.position.x=_camera.get_camera_position().x+randi()%20*32
			temp.position.y=winHeight+temp.rect.size.y/2
			temp.status='flying'
			if temp.position.x>_camera.get_camera_screen_center().x:
				temp.dir=constants.left
			else:
				temp.dir=constants.right	
			if marioList.size()>0:
				var mario1=marioList[0]
				if is_instance_valid(mario1)&&mario1.status!=constants.deadJump:
					temp.flyingXSpeed=max(constants.flyingFishXSpeed,abs(mario1.xVel))
					_obj.add_child(temp)					
#			print('start flyingFish')
	
	#火焰
	if fireStart:
		fireTimer+=1
		if fireTimer>fireDelay&&!gamePause:
			fireTimer=0
			fireDelay=randi()%60+200
			var temp=fire.instance()
			temp.position.x=_camera.get_camera_screen_center().x+winWidth/2+32
#			print(_camera.get_camera_screen_center().x)
#			print(_camera.position.x+20*32)
			temp.position.y=temp.rect.size.y/2+randi()%(14*32)
			if marioList.size()>0:
				var mario1=marioList[0]
				if is_instance_valid(mario1)&&mario1.status!=constants.deadJump:
					temp.position.y=rand_range(max(32,mario1.position.y-32*4),
						min(32*14,mario1.position.y+32*2)) 
					_obj.add_child(temp)	
					
#			print('start fire')
	
	#炮弹
	if bulletStart:
		bulletTimer+=1
		if bulletTimer>bulletDelay&&!gamePause:
			bulletTimer=0
			bulletDelay=randi()%70+110
			var temp=bulletBill.instance()
			temp.position.x=_camera.get_camera_screen_center().x+winWidth/2+32
			temp.position.y=temp.rect.size.y/2+randi()%(15*32)
			if marioList.size()>0:
				var mario1=marioList[0]
				if is_instance_valid(mario1)&&mario1.status!=constants.deadJump:
					temp.position.y=rand_range(max(32,mario1.position.y-32*4),
						min(32*14,mario1.position.y+32*2)) 
					_obj.add_child(temp)
#		print('start bullet')
	
				
	for y in _obj.get_children():
		var hCollision=false
		var vCollision=false
#		if y.active:
#			y.yVel+=y.gravity*delta		#增加y速度
#			if y.yVel>y.maxYVel:
#				y.yVel=y.maxYVel
				
		#检测附近的砖块根据方向来决定方块的位置
		var xstart=floor((y.position.x-y.rect.size.x)/blockSize)
		var xend=floor((y.position.x+y.rect.size.x)/blockSize)
#		var xend=floor((y.position.x+y.getSize())/blockSize)


#		var ystart=floor((y.position.y-y.getSizeY())/blockSize)
#		var yend=floor((y.position.y+y.getSizeY())/blockSize)
		var ystart=floor((y.position.y-y.rect.size.y)/blockSize)
		var yend=floor((y.position.y+y.rect.size.y)/blockSize)
	
#		print(xstart,'-',xend)
#		print(ystart,'-',yend)
		#与方块的配置 在这个循环中直接访问元素属性
		for a in range(xstart,xend+1):
			for b in range(ystart,yend+1):
				if mapData.get(str(a,",",b),null)!=null&&y.active:
					if y.mask.has(mapData[str(a,",",b)].type):
						var result=checkCollision(y,mapData[str(a,",",b)],delta)
						if result[0]:
							hCollision=true
						if result[1]:
							vCollision=true

		
		#与物体间的碰撞 选择x轴y轴最近的物体
		for x in _obj.get_children():
			if y!=x&&y.mask.has(x.type)&&!x.destroy&&!y.destroy&&y.active:
#				if y.getLeft()<=x.getRight()-1 &&y.getRight()>=x.getLeft()+1&&\
#					y.getTop()<=x.getBottom()-1&&y.getBottom()>=x.getTop()+1:
				#除了旗杆和藤蔓不是中心对称的	
				if (x.type==constants.pole ||x.type==constants.vine)&& y.position.x-y.rect.size.x/2<=x.position.x+x.rect.size.x/2 -1&&\
					y.position.x+y.rect.size.x/2>=x.position.x-x.rect.size.x/2+1:
					var result=checkCollision(y,x,delta)
					if result[0]:
						hCollision=true
					if result[1]:
						vCollision=true
				elif y.position.x-y.rect.size.x/2<=x.position.x+x.rect.size.x/2 -1&&\
					y.position.x+y.rect.size.x/2>=x.position.x-x.rect.size.x/2+1&&\
					y.position.y-y.rect.size.y/2<=x.position.y+x.rect.size.y/2-1&&\
					y.position.y+y.rect.size.y/2>=x.position.y-x.rect.size.y/2:
					var result=checkCollision(y,x,delta)
					if result[0]:
						hCollision=true
					if result[1]:
						vCollision=true
				
			
			pass
		
		if !vCollision&&y.active:
			y.position.y+=y.yVel*delta
			y.isOnFloor=false
		else:
			y.isOnFloor=true
		
		if !hCollision&&y.active:
			y.position.x+=y.xVel*delta
					


func checkCollision(a,b,delta):
	var hCollision=false
	var vCollision=false

	#如果a物体x轴和y轴移动发生于b物体的碰撞 判断是那个方向上的碰撞

	if !is_instance_valid(a)||!is_instance_valid(b):
		return [hCollision,vCollision]
	var aRect= a.getRect()
	var bRect=b.getRect()

	
	aRect.position.x+=a.xVel*delta
	if  aRect.intersects(bRect):	#判断左右是否碰撞  这个排除了边框的判断
		var xVal =a.position.x-b.position.x
		var dx=(b.position.x-a.position.x)/b.getSize()/2
		var dy=(b.position.y-a.position.y)/b.getSizeY()/2
		if abs(dx)>abs(dy): #左右的碰撞
			if xVal<0&&a.xVel>=0:
				if hCollision(a,b,delta)==true:
					hCollision=true
			elif xVal>0 &&a.xVel<=0:
				if hCollision(a,b,delta)==true:
					hCollision=true

	
	aRect.position.x-=a.xVel*delta
	aRect.position.y+=a.yVel*delta
	if  aRect.intersects(bRect,true)&&a.getLeft()<b.getRight()&&a.getRight()>b.getLeft():
		var yVal =a.position.y-b.position.y
		var dx=(b.position.x-a.position.x)/b.getSize()/2
		var dy=(b.position.y-a.position.y)/b.getSizeY()/2
#		if b.type==constants.platform:
#			print(dx,' ',dy)
		if abs(dy)>abs(dx):	# a在b的上方或者下方
#			if b.type==constants.platform:
#				print(1111)
			if dy<0 &&a.yVel<0 :# a在下方 b上方
				if vCollision(a,b,delta)==true:
					vCollision=true
			elif  dy>0	&&  a.yVel>=0:  #判断地面上是否有物体  a在上方 b在下方
				#如果只是走过一个间隙 判断重叠部分是x多还是y多	
#				if dx>=0 && abs(a.getRight()-b.getLeft())>abs(a.getBottom()-b.getTop()):
#					if vCollision(a,b,delta)==true:
#						vCollision=true
#				elif dx<0 && abs(a.getLeft()-b.getRight())>abs(a.getBottom()-b.getTop()):
#					if vCollision(a,b,delta)==true:
#						vCollision=true
				#这里需要排除那种对角线的那种碰撞
				if dx>0 && abs(a.getRight()-b.getLeft())>2:
					if vCollision(a,b,delta)==true:
						vCollision=true
				elif dx<=0 && abs(a.getLeft()-b.getRight())>2:
					if vCollision(a,b,delta)==true:
						vCollision=true		
				else:
					#属于两个物体位置在对角线的情况
					#如果下方有方块就不进行左右碰撞的判断	  
					if !checkMapBrick(a.position.x,a.getBottom()+blockSize/2):
						if dx>0&&a.xVel>=0:
							if hCollision(a,b,delta)==true:
								hCollision=true
						elif dx<0 &&a.xVel<0:
							if hCollision(a,b,delta)==true:
								hCollision=true			
	return [hCollision,vCollision]


#左右判断
func hCollision(a,b,delta):
	if a.xVel>=0:
		if b.has_method('leftCollide'):
			if b.leftCollide(a)==true:
#				print(b.type,a.type)
				if b.xVel<0:
					b.xVel=0
				b.position.x=a.getRight()+b.getSize()/2

	
		if a.has_method('rightCollide'):
			if a.rightCollide(b)==true: #需要处理位置
#				print(a.type,b.getLeft())
				if a.xVel>0:
					a.xVel=0
				a.position.x=b.getLeft()-a.getSize()/2
				return true
		else:
			if a.xVel>0:
				a.xVel=0
			a.position.x=b.getLeft()-a.getSize()/2
			return true
	else:
		if b.has_method('rightCollide'):
			if b.rightCollide(a)==true:
				if b.xVel>0:
					b.xVel=0
				b.position.x=a.getLeft()-b.getSize()/2
		
		if a.has_method('leftCollide'):
			if a.leftCollide(b)==true: #需要处理位置
				if a.xVel<0:
					a.xVel=0
				a.position.x=b.getRight()+a.getSize()/2
				return true
		else:
			if a.xVel<0:
				a.xVel=0
			a.position.x=b.getRight()+a.getSize()/2
			return true
	return false
	

#上下判断	
func vCollision(a,b,delta):
	if a.yVel>=0: #向下
		if b.has_method('ceilcollide'):
			if b.ceilcollide(a)==true:
				if b.yVel<0:
					b.yVel=0
				b.position.y=a.getBottom()+b.getSizeY()/2

				
		if a.has_method('floorCollide'):
			if a.floorCollide(b)==true:
				if a.yVel>0:
					a.yVel=0
				a.position.y=b.getTop()-a.getSizeY()/2
				return true
		else:
			if a.yVel>0:
				a.yVel=0
			a.position.y=b.getTop()-a.getSizeY()/2
			return true
	else: #向上
		if b.has_method('floorCollide'):
			if b.floorCollide(b)==true:
				if b.yVel>0:
					b.yVel=0
				b.position.y=a.getTop()-b.getSizeY()/2

				
		if a.has_method('ceilcollide'):
			if a.ceilcollide(b)==true:
				if a.yVel<0:
					a.yVel=0
				a.position.y=b.getBottom()+a.getSizeY()/2
				return true
		else:
			if a.yVel<0:
				a.yVel=0
			a.position.y=b.getBottom()+a.getSizeY()/2
			return true
	return false


#检查是否在地图中
func checkInMap(x,y):
	if x>=0 &&x<=mapWidthSize && y>=0&&y<=heightNun:
		return true
	else:
		return false
	pass

func hasTile(x,y):
	if mapData.get(str(x,",",y),null)!=null:
		return true
	else:
		return false
#	if mapData.has(str(x,",",y)):
#		return true
#	else:
#		return false	
	pass

#func setMapArray(row:int,col:int):
#	for y in range(row):
#		mapData.append([])
#		mapData[y].resize(col)
#		for x in range(col):
#			mapData[y][x] = null
#	pass

func checkHasObj(arr,x,name):
	var flag=false
	for i in arr:
		if 'flyingfishStart'==name:
			if i.type==constants.flyingfish:
				if i.startX==x:
					flag=true
		elif 'fireStart'==name:
			if i.type==constants.fire:
				if i.startX==x:
					flag=true
		elif 'bulletStart'==name:
			if i.type==constants.bulletBill:
				if i.startX==x:
					flag=true
		elif 'mazeStart'==name:
			if i.type==constants.maze:
				if i.startX==x:
					flag=true
	return flag

func setObjEnd(arr,x,name,groupId):
	for i in arr:
		if name=='flyingfishEnd':
			if i.type==constants.flyingfish&&i.groupId==groupId:
				i['endX']=x
				break
		elif name=='fireEnd':
			if i.type==constants.fire&&i.groupId==groupId:
				i['endX']=x
				break
		elif name=='bulletEnd':
			if i.type==constants.bulletBill&&i.groupId==groupId:
				i['endX']=x
				break
		elif name=='mazeEnd':
			if i.type==constants.maze&&i.mazeId==groupId:
				i['endX']=x
				break
			
#载入文件
func loadMapFile(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		currentLevel= parse_json(file.get_as_text())
		mapWidthSize=int(currentLevel['mapSize'])
		time =int(currentLevel['time'])
		if currentLevel['bg']=="overworld":
			VisualServer.set_default_clear_color(Color('#5C94FC'))
		elif currentLevel['bg']=="castle":
			VisualServer.set_default_clear_color(Color('#000'))
		elif currentLevel['bg']=="underwater":
			VisualServer.set_default_clear_color(Color('#2038EC'))

		if currentLevel.has('mapName'):
			mapName=str(currentLevel['mapName'])
		
		if currentLevel.has('nextLevel'):
			nextLevel=str(currentLevel['nextLevel'])
		
		if currentLevel.has('subLevel'): #从奖励关卡回到原来地图的位置
			nextSubLevel=str(currentLevel['subLevel'])
			
		if currentLevel.has('bonusLevel'): 
			if currentLevel['bonusLevel']=='true':
				bonusLevel=true
			
		music=str(currentLevel['music'])
		SoundsUtil.bgm=music
		if bonusLevel:
			SoundsUtil.bgm='star'
		SoundsUtil.isLowTime=false
		
#		var status=''
		if currentLevel.has('status'):
			marioStatus=currentLevel['status']
			
		if 	currentLevel.has('underwater'):
			if currentLevel['underwater']=='true':
				underwater=true
			
		print(marioStatus)
		var pos = currentLevel['marioPos']
		if !pos.empty():  #添加mario
#			if mode=='game' ||  mode=='show':
			var temp=mario.instance()
			temp.position.x=pos['x']*blockSize+blockSize/2
			temp.position.y=pos['y']*blockSize+blockSize/2
			temp.big=Game.playerData['mario']['big']
#			temp.big=true
			temp.fire=Game.playerData['mario']['fire']
#			temp.fire=true

			if marioStatus!='':
				temp.status=marioStatus
			if underwater:
				temp.underwater=true
				
			_obj.add_child(temp)
			marioList.append(temp)
				
#		marioPos=pos
		var tempArea=[]
		var tempAreaEnd=[]
		var tempMaze=[]
		var tempMazeEnd=[]
		for i in currentLevel['data']:
			if i['type'] =='brick':
				var temp=brick.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.localx=i['x']
				temp.localy=i['y']
				_tile.add_child(temp)
				mapData[str(i['x'],",",i['y'])]=temp
			elif i['type'] =='bridge':
				var temp=bridge.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.localx=i['x']
				temp.localy=i['y']
				_tile.add_child(temp)
				mapData[str(i['x'],",",i['y'])]=temp
				castleBridge.append(temp) #保存这些桥
			elif i['type']=='box':
				var temp=box.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.localx=i['x']
				temp.localy=i['y']
				temp.content=i['content']
				if typeof(i['visible'])==TYPE_BOOL:
					temp._visible=i['visible']
				elif typeof(i['visible'])==TYPE_STRING:
					if i['visible']=="false"||i['visible']=="f":
						temp._visible=false
					else:
						temp._visible=true
				if i.has('level'):
					temp.level=i['level']
				if i.has('subLevel'):
					temp.subLevel=i['subLevel']
				if i.has('itemIndex'):
					temp.itemIndex=int(i['itemIndex'])
					
				_tile.add_child(temp)
				mapData[str(i['x'],",",i['y'])]=temp
			elif i['type']=="platform":
				var temp=platform.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+8
				temp.lens=int(i['lens'])
				if i.has('platformType'):
					temp.status=i['platformType']
				if i.has('dir'):
					temp.dir=i['dir']
				if i.has('speed'):
					temp.speed=int(i['speed'])
						
				_obj.add_child(temp)
			elif i['type']=='coin':
				var temp=bigCoin.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				_obj.add_child(temp)
			elif i['type']=='pipe':
				var temp=pipe.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.rotate=int(i['rotate'])
				if i.has('pipeType'):
					temp.pipeType=i['pipeType']
				if i.has('pipeNo'):
					temp.pipeNo=i['pipeNo']
				if i.has("dir"):
					temp.dir=i['dir']
				_tile.add_child(temp)
				mapData[str(i['x'],",",i['y'])]=temp
				if i.has('pipeType')&&i['pipeType']!=constants.empty&&i['pipeType']!='':
					specialEntrance.append(i)
				if i.has('warpzoneNum')	&& i['warpzoneNum']!='':
					warpZone.append(i)
			elif  i['type']=='flag':  #旗杆
				var temp = pole.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.poleLen=int(i['len'])
				temp.spriteIndex=i['spriteIndex']
				_obj.add_child(temp)
			elif  i['type']=='collision':
				if i['value']=='checkPoint':
					checkPoint.append({"x":i['x']*blockSize+blockSize/2
						,"y":i['y']*blockSize+blockSize/2})
				elif i['value']=='subLevelPos':
					specialEntrance.append(i)
				elif i['value']=='flyingfishStart':
#					if !checkHasObj(tempArea,i['x']*blockSize,'flyingfishStart'):
					var temp={
						'type':constants.flyingfish,
						'startX':i['x']*blockSize,
						'endX':-1,
						'spriteIndex':-1,
						'groupId':str(i['groupId'])
					}
					if i.has('spriteType'):
						temp.spriteIndex=i.spriteType
					tempArea.append(temp)	
				elif i['value']=='flyingfishEnd':
					var temp={
						'type':constants.flyingfish,
						'startX':0,
						'endX':i['x']*blockSize,
						'spriteIndex':-1,
						'groupId':str(i['groupId'])
					}
					if i.has('spriteType'):
						temp.spriteIndex=i.spriteType
					tempAreaEnd.append(temp)	
#					setObjEnd(tempArea,i['x']*blockSize,'flyingfishEnd',str(i['groupId']))
				elif i['value']=='fireStart':
#					if !checkHasObj(tempArea,i['x']*blockSize,'fireStart'):
					var temp={
						'type':constants.fire,
						'startX':i['x']*blockSize,
						'endX':-1,
						'spriteIndex':-1,
						'groupId':str(i['groupId'])
					}
					if i.has('spriteType'):
						temp.spriteIndex=i.spriteType
					tempArea.append(temp)	
				elif i['value']=='fireEnd':
					var temp={
							'type':constants.fire,
							'startX':0,
							'endX':i['x']*blockSize,
							'spriteIndex':-1,
							'groupId':str(i['groupId'])
						}
					tempAreaEnd.append(temp)	
#					setObjEnd(tempArea,i['x']*blockSize,'fireEnd',str(i['groupId']))
				elif i['value']=='bulletStart':
#					if !checkHasObj(tempArea,i['x']*blockSize,'bulletStart'):
					var temp={
							'type':constants.bulletBill,
							'startX':i['x']*blockSize,
							'endX':-1,
							'spriteIndex':-1,
							'spriteType':i['spriteType'],
							'groupId':str(i['groupId'])
						}
					tempArea.append(temp)	
				elif i['value']=='bulletEnd':	
					var temp={
							'type':constants.bulletBill,
							'startX':0,
							'endX':i['x']*blockSize,
							'spriteIndex':-1,
							'spriteType':i['spriteType'],
							'groupId':str(i['groupId'])
						}
					tempAreaEnd.append(temp)	
#					setObjEnd(tempArea,i['x']*blockSize,'bulletEnd',str(i['groupId']))		
				elif i['value']=='mazeStart':
#					if !checkHasObj(tempMaze,i['x']*blockSize,'mazeStart'):
					var temp={
							'type':constants.maze,
							'startX':i['x']*blockSize,
							'endX':-1,
							'spriteIndex':-1,
							'mazeId':str(i['mazeId']),
							'vaild':true,
						}
					tempMaze.append(temp)	
				elif i['value']=='mazeEnd':
					var temp={
							'type':constants.maze,
							'startX':0,
							'endX':i['x']*blockSize,
							'spriteIndex':-1,
							'mazeId':str(i['mazeId']),
							'vaild':true,
						}
					tempMazeEnd.append(temp)	
#					setObjEnd(tempMaze,i['x']*blockSize,'mazeEnd',str(i['mazeId']))
				else:
					var temp=collision.instance()
					temp.position.x=i['x']*blockSize+blockSize/2
					temp.position.y=i['y']*blockSize+blockSize/2
					temp.value=i['value']
					_obj.add_child(temp)
			elif i['type']=='bg':
				var temp=background.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				_tile.add_child(temp)
			elif i['type']=='goomba' || i['type']=='koopa'||\
				i['type']==constants.plant||i['type']=='bowser'||\
				i['type']=='cheapcheap'||i['type']=='bloober'||\
				i['type']=='lakitu'||i['type']=='hammerBro'||\
				i['type']==constants.beetle:
				i['init']=false#用来设置是否初始化
				if enemyPosList.has(str(i['x'])):
					enemyPosList[str(i['x'])].append(i)
				else:
					enemyPosList[str(i['x'])]=[]
					enemyPosList[str(i['x'])].append(i)
					
				enemyList.append(i)
			elif i['type']=='castleFlag':
				var temp=castleFlag.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2	
				_obj.add_child(temp)
			elif i['type']=='spinFireball': #旋转的火球
				if int(i['len'])>0:
					for x in range(int(i['len'])):
						var temp=spinFireball.instance()
						temp.position.x=i['x']*blockSize+blockSize/2
						temp.position.y=i['y']*blockSize+blockSize/2
						temp.aroundPos=Vector2(i['x']*blockSize+blockSize/2,
							i['y']*blockSize+blockSize/2)
						temp.radius=x*18
						_obj.add_child(temp)
			elif i['type']=='axe':
				var temp=axe.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				castleEndX=temp.position.x+blockSize/2
				_obj.add_child(temp)
			elif i['type']=='figures':
				var temp=figures.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.spriteIndex=i['spriteIndex']
				_obj.add_child(temp)
			elif i['type']=='vine':
				var temp=vine.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.spriteIndex=i['spriteIndex']
				_obj.add_child(temp)
			elif i['type']=='jumpingBoard':
				var  temp=jumpingBoard.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize
				_obj.add_child(temp)
			elif i['type']=='podoboo':
				var temp=podoboo.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.spriteIndex=i['spriteIndex']
				_obj.add_child(temp)		
			elif i['type']=='cannon':
				var temp=cannon.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.spriteIndex=i['spriteIndex']
				_obj.add_child(temp)	
			elif i['type']==constants.staticPlatform:
				var temp=staticPlatform.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/4
				temp.spriteIndex=i['spriteIndex']
				temp.lens=int(i['lens'])
				temp.status=i['status']
				_obj.add_child(temp)
			elif i['type']==constants.linkPlatform:
				var temp=linkPlatform.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.spriteIndex=i['spriteIndex']
				temp.distance=int(i['distance'])*32
				temp.leftHeight=int(i['leftHeight'])
				temp.rightHeight=int(i['rightHeight'])
				if i.has('lens'):
					temp.lens=int(i['lens'])
				_obj.add_child(temp)
				
		file.close()
#		print(mapData)
		#检查区域信息
		for i in tempArea:
			for y in tempAreaEnd:
				if i.type==constants.flyingfish && y.type==constants.flyingfish\
				&&i.groupId==y.groupId:
					i['endX']=y['endX']
				elif i.type==constants.fire&& y.type==constants.fire\
				&&i.groupId==y.groupId:
					i['endX']=y['endX']
				elif i.type==constants.bulletBill&& y.type==constants.bulletBill\
				&&i.groupId==y.groupId:
					i['endX']=y['endX']
				
		for i in tempArea:
			if i.endX!=-1:
				areaList.append(i)
			else:
				printerr("数据错误 ",i)
		
		for i in tempMaze:
			for y in tempMazeEnd:
				if i.type==constants.maze&&i.mazeId==y.mazeId:
					i['endX']=y['endX']
		
		for i in tempMaze:
			if i.endX!=-1:
				mazeList[i.mazeId]=i
			else:
				printerr("数据错误 ",i)	
		print(mazeList)
		for i in mazeList:
			var m=mazeList[i]
			mazeObjList[i]=[]
			for y in range(m.startX/blockSize,m.endX/blockSize):
				for z in range(0,winHeight/blockSize+1):
					if mapData.has(str(y,',',z)):
						var obj=mapData[str(y,',',z)]
						var new=obj.duplicate()
						for property in obj.get_property_list():
							if(property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE): 
								new[property.name] = obj[property.name]
						mazeObjList[i].append(new)
		print(mazeObjList)		
	else:
		print('文件不存在')
		pass


#载入子关卡
func loadSubLevelMap(level,subLevel):
	Game.playerData['score']=_title.score
	Game.playerData['coin']=_title.coinNum
	Game.playerData['level']=level
	Game.playerData['subLevel']=subLevel
	Game.playerData['time']=_title.currentTime
	saveMarioStatus()
	SoundsUtil.stopBgm()
#	SoundsUtil.stopSpecialBgm()
	var scene=load("res://scenes/mapNew.tscn")
	var temp=scene.instance()
	queue_free()
	set_process_input(false)
	get_tree().get_root().add_child(temp)
	set_process_input(true)


#根据坐标获取
func getMapBrick(x,y):
	var mapx=floor(x/blockSize)
	var mapy=floor(y/blockSize)
	if hasTile(mapx,mapy):
		return mapData[str(mapx,",",mapy)]
	return null
	

func checkMapBrick(x,y):
	var mapx=floor(x/blockSize)
	var mapy=floor(y/blockSize)
#	print(mapx,mapy)
	return hasTile(mapx,mapy)

func checkMapBrickIndex(x,y):
	return hasTile(x,y)
	
func addObj2Other(obj):
	_obj.add_child(obj)
	pass

func addObj2Item(obj):
	_obj.add_child(obj)
	
func addObj(obj):
	_obj.add_child(obj)
	
func addCoin(_position,_coin=1):
	_title.addCoin(_coin)
	pass

func addScore(_position,_score=100):
	var temp=score.instance()
	temp.setPos(_position)
	temp.setScore(_score)
	_obj.add_child(temp)
	_title.addScore(_score)
	pass

func addLive(_position,id):
	var temp=score.instance()
	temp.setPos(_position)
	temp.setScore("1UP")
	_obj.add_child(temp)
	Game.playerData['lives']+=1

func getCamera():
	return _camera

#添加敌人
func addEnemy(obj):
#	print('addEnemy ',obj.type)
	if obj.type==constants.goomba:
		var temp =goomba.instance()
		temp.position.x=obj['x']*blockSize+blockSize/2
		temp.position.y=obj['y']*blockSize+blockSize/2
		temp.offsetX=int(obj['offsetX'])
		temp.offsetY=int(obj['offsetY'])
		temp.spriteIndex=obj['spriteIndex']
		temp.dir=obj['dir']
		_obj.add_child(temp)
	elif obj.type==constants.plant:
		var temp=plant.instance()
		temp.position.x=obj['x']*blockSize+blockSize/2
		temp.position.y=obj['y']*blockSize+blockSize/2
		temp.offsetX=int(obj['offsetX'])
		temp.offsetY=int(obj['offsetY'])
		temp.spriteIndex=obj['spriteIndex']
		_obj.add_child(temp)
	elif obj.type==constants.koopa:
		var temp =koopa.instance()
		temp.position.x=obj['x']*blockSize+blockSize/2
		temp.position.y=obj['y']*blockSize+blockSize/2
		temp.offsetX=int(obj['offsetX'])
		temp.offsetY=int(obj['offsetY'])
		temp.spriteIndex=obj['spriteIndex']
		temp.dir=obj['dir']
		if obj.has('ySpeed'):
			temp.ySpeed=int(obj['ySpeed'])
		if obj.has('yDir'):
			temp.yDir=obj['yDir']
		_obj.add_child(temp)
	elif obj.type==constants.beetle:
		var temp =beetle.instance()
		temp.position.x=obj['x']*blockSize+blockSize/2
		temp.position.y=obj['y']*blockSize+blockSize/2
		temp.offsetX=int(obj['offsetX'])
		temp.offsetY=int(obj['offsetY'])
		temp.spriteIndex=obj['spriteIndex']
		temp.dir=obj['dir']
		_obj.add_child(temp)
	elif obj.type==constants.bowser:
		var temp=bowser.instance()
		temp.position.x=obj['x']*blockSize+blockSize
		temp.position.y=obj['y']*blockSize+blockSize
		temp.spriteIndex=obj['spriteIndex']
		_obj.add_child(temp)
	elif obj.type==constants.cheapcheap:
		var temp=cheapcheap.instance()
		temp.position.x=obj['x']*blockSize+blockSize/2
		temp.position.y=obj['y']*blockSize+blockSize/2
		temp.offsetX=int(obj['offsetX'])
		temp.offsetY=int(obj['offsetY'])
		temp.status=obj['status']
		temp.spriteIndex=obj['spriteIndex']
		_obj.add_child(temp)
	elif  obj.type==constants.bloober:
		var temp=bloober.instance()
		temp.position.x=obj['x']*blockSize+blockSize/2
		temp.position.y=obj['y']*blockSize+blockSize/2
		temp.offsetX=int(obj['offsetX'])
		temp.offsetY=int(obj['offsetY'])
		temp.spriteIndex=obj['spriteIndex']
		_obj.add_child(temp)	
	elif obj.type==constants.lakitu:  #判断游戏中是不是已经有了
		var has=false
		for i in _obj.get_children():
			if i.type==constants.lakitu && !i._dead:
				has=true
				print('has lakitu')
		if 	!has:	
			var temp=lakitu.instance()
			temp.position.x=obj['x']*blockSize+blockSize/2
			temp.position.y=obj['y']*blockSize+blockSize/2
			temp.offsetX=int(obj['offsetX'])
			temp.offsetY=int(obj['offsetY'])
			temp.spriteIndex=obj['spriteIndex']
			temp.endX=int(obj['end'])*blockSize
			_obj.add_child(temp)
	elif obj.type==constants.hammerBro:
		var temp=hammerBro.instance()
		temp.position.x=obj['x']*blockSize+blockSize/2
		temp.position.y=obj['y']*blockSize+blockSize/2
		temp.offsetX=int(obj['offsetX'])
		temp.offsetY=int(obj['offsetY'])
		temp.spriteIndex=obj['spriteIndex']
		_obj.add_child(temp)

#生成当前画面里面的敌人
func initEnemy():
#	for e in enemyList:
#		if e['init']:
#			continue
#		if e.x*blockSize+blockSize/2>_camera.position.x&& \
#			e.x*blockSize+blockSize/2<_camera.position.x+winWidth:
#				e['init']=true
#				addEnemy(e)
	var startPos=floor((_camera.position.x)/blockSize)
	var endPos=floor((_camera.position.x+winWidth)/blockSize)
	for i in range(startPos,endPos+1):
		if enemyPosList.has(str(i)):
			for y in enemyPosList[str(i)]:
				if y['init']:
					continue
				else:	
					addEnemy(y)
					y['init']=true

func initPlantEnemy():
#	for e in enemyList:
#		if e['init']:
#			continue
#		if e.type=='plant' && e.x*blockSize+blockSize/2>_camera.position.x&& \
#			e.x*blockSize+blockSize/2<_camera.position.x+winWidth:
#				e['init']=true
#				addEnemy(e)
	var startPos=floor((_camera.position.x)/blockSize)
	var endPos=floor((_camera.position.x+winWidth)/blockSize)
	for i in range(startPos,endPos+1):
		if enemyPosList.has(str(i)):
			for y in enemyPosList[str(i)]:
				if y['init']:
					continue
				elif y['type']=='plant':	
					addEnemy(y)
					y['init']=true
	
			
func getMario():
	return marioList

func getBulletCount(id):
	var num=0
	for i in _obj.get_children():
		if i.type==constants.fireball:
			num+=1
	return num

#状态发生变化
func marioStateChange():
	gamePause=true
	_title.stopCountDown()
	for i in _obj.get_children():
		if i.type!=constants.mario:
			i.pause()
	
#状态结束	
func marioStateFinish():
	gamePause=false
	_title.startCountDown()
	for i in _obj.get_children():
		if i.type!=constants.mario:
			i.resume()
	pass

func invincibleFinish():
#	SoundsUtil.stopSpecialBgm()
#	SoundsUtil.playBgm()
	SoundsUtil.playLastBgm()
	pass

#进入城堡
func marioInCastle():
	print('marioInCastle',nextLevel)
	subLevel=''
	_title.recordLastTime()
	_title.fastCountDown()
	for i in marioList:
		Game.playerData['mario']['big']=i.big
		Game.playerData['mario']['fire']=i.fire
		i.destroy=true
#	_timer.start()
	Game.playerData['time']=0
	pass

func countFinish():
	print('countFinish')
	var castleFlag
#	var castlePos
	for i in _obj.get_children():
		if i.type==constants.castleFlag:
			castleFlag=i
#		elif i.type==constants.collision && i.value=='castlePos':
#			castlePos=i.position.x
	if castleFlag!=null:
		print('rising')
		castleFlag.rising()
		yield(Game,"flagRising")
	for y in range(50):
		yield(get_tree(),"idle_frame")
	var num=str(_title.lastTime)
	var digits=num[num.length()-1]
	print(digits)
	if digits in ["1","3","6"]: #放烟花个数
		for i in range(digits.to_int()):
			SoundsUtil.playBoom()
			var temp=firework.instance()
			temp.position.x=_camera.get_camera_screen_center().x
			_obj.add_child(temp)
			yield(temp.ani,"animation_finished")
			_title.addScore(300)  #每朵烟花200
			for y in range(15):
				yield(get_tree(),"idle_frame")
		
	_timer.start()
	pass

#进入水管
func marioIntoPipe(pipeNo):
	print('marioIntoPipe',pipeNo)
	_title.stopCountDown()
	for i in specialEntrance:
		if i.has('pipeNo')&&i['pipeNo']==pipeNo:
#			for y in range(300):
#				yield(get_tree(), "idle_frame")
			nextLevel=i['level']
			subLevel=i['subLevel'] #水管或者树的编号
			if i.has('warpzoneNum')&&i['warpzoneNum']!='':
				isLoadsubLevel=false
			else:
				isLoadsubLevel=true
			_timer.start()
#			loadSubLevelMap(i['level'],i['subLevel'])
			break

#超时
func timeOut():
	marioDead()
	for i in marioList:
		if i.type==constants.mario:
			marioDeathPos={'x':i.position.x}
			i.startDeathJump()
	
func hurryup():
	print("hurryup")
	SoundsUtil.playLowTime()

#mario死亡
func marioDead(xpos=null):
	gameOver=true
	print('marioDead xpos',xpos)
	if xpos!=null:
		marioDeathPos={'x':xpos}
#	_title.stopCountDown()
	SoundsUtil.playDeath()
	SoundsUtil.stopBgm()
#	SoundsUtil.stopSpecialBgm()
	marioStateChange()

func saveMarioStatus():
	for i in marioList:
		Game.playerData['mario']['big']=i.big
		Game.playerData['mario']['fire']=i.fire
	
func marioStartSliding():
	_title.stopCountDown()

#接触到斧头
func marioContactAxe():
	SoundsUtil.stopBgm()
#	SoundsUtil.stopSpecialBgm()
	var hasBowser=false
	for i in _obj.get_children():
		i.pause()
		if i.type==constants.bowser&&i.status!=constants.deadJump:
			hasBowser=true
			
	if hasBowser:		
		for i in castleBridge:
			i.destroy=true
			for y in range(8):
				yield(get_tree(),"idle_frame")
			SoundsUtil.playBridgeBreak()	
	
	
	for i in _obj.get_children():
		if i.type==constants.bowser:
			i.resume()		
			i.setDead()
		elif i.type==constants.axe:
			i.destroy=true	

	if 	hasBowser:
		SoundsUtil.playbowserFall()	
	else:
		bowserDrop()	
	

#boss掉落
func bowserDrop():
	SoundsUtil.playCastleEnd()
	castleEndX=0
	for i in _obj.get_children():
		if i.type==constants.mario:
			i.resume()
			i.status=constants.onlywalk
		else:
			i.resume()	
	scrollEnd=true
	pass

#马里奥见到公主或者蘑菇人
func marioCastleEnd():
	print('marioCastleEnd')
	var temp= label.instance()
	temp.setLabel("thank you mario!")
	temp.position.x=_camera.position.x+blockSize*7
	temp.position.y=blockSize*5
	_obj.add_child(temp)
	for y in range(90):
		yield(get_tree(),"idle_frame")
	var temp1= label.instance()
	temp1.setLabel("but our princess is in")
	temp1.position.x=_camera.position.x+blockSize*6
	temp1.position.y=blockSize*7
	_obj.add_child(temp1)
	
	var temp2= label.instance()
	temp2.setLabel("another castle!")
	temp2.position.x=_camera.position.x+blockSize*8
	temp2.position.y=blockSize*9
	_obj.add_child(temp2)
	#进入下一关
	subLevel=''
	saveMarioStatus()
	_timer.start(3)


#藤蔓已经长好
func vineEnd():
	for i in marioList:
		i.startAutoGrabVine=true


#跳转到下一关
func marioGrapVineTop(level,subLevel):
	print(level,'-',subLevel)
	assert(level!='')
	loadSubLevelMap(level,subLevel)


func addWarpZoneMsg():
	if warpZone.size()>=3:
		var temp= label.instance()
		temp.setLabel("welcome to warp zone!")
		temp.position.x=warpZone[0].x*blockSize-blockSize
		temp.position.y=warpZone[0].y*blockSize-blockSize*4
		_obj.add_child(temp)
	elif warpZone.size()>=2:
		var temp= label.instance()
		temp.setLabel("welcome to warp zone!")
		temp.position.x=warpZone[0].x*blockSize-warpZone.size()*blockSize*3
		temp.position.y=warpZone[0].y*blockSize-blockSize*5
		_obj.add_child(temp)
	elif warpZone.size()>=1:
		var temp= label.instance()
		temp.setLabel("welcome to warp zone!")
		temp.position.x=warpZone[0].x*blockSize-warpZone.size()*blockSize*5
		temp.position.y=warpZone[0].y*blockSize-blockSize*5
		_obj.add_child(temp)
		
	for i in warpZone:
		var temp= label.instance()
		temp.setLabel(i.warpzoneNum)
		temp.position.x=i.x*blockSize-blockSize/3
		temp.position.y=i.y*blockSize-blockSize*2
		_obj.add_child(temp)

#添加一段新的迷宫	
func addNewMaze(obj):
	
	pass

func getObj():
	return _obj
	
func _draw():
	if debug:
		for i in range(mapWidthSize+1):
			if i%20==0:
				draw_line(Vector2(i*blockSize,0),Vector2(i*blockSize,blockSize*heightNun)
			,Color.red,1.2,true)
			else:
				draw_line(Vector2(i*blockSize,0),Vector2(i*blockSize,blockSize*heightNun)
			,Color.gray,0.5,true)
		for i in range(mapWidthSize):
			draw_line(Vector2(0,i*blockSize),Vector2(blockSize*mapWidthSize,i*blockSize),
			Color.gray,0.5,true)
	
	if underwater:
		draw_rect(Rect2(Vector2.ZERO,Vector2(mapWidthSize*32,32*2)),Color('#5C94FC'))
	pass


func _on_Timer_timeout():
	SoundsUtil.stopBgm()
#	SoundsUtil.stopSpecialBgm()
	if isLoadsubLevel:
#		Game.playerData['score']=_title.score
#		Game.playerData['coin']=_title.coinNum
		loadSubLevelMap(nextLevel,subLevel)
	else:
		var temp=menu.instance()
		Game.playerData['level']=nextLevel
		Game.playerData['score']=_title.score
		Game.playerData['coin']=_title.coinNum
		Game.playerData['subLevel']=''
#		saveMarioStatus()
		queue_free()
		set_process_input(false)
		get_tree().get_root().add_child(temp)
		set_process_input(true)
		pass



func _on_gameover_timeout():
	print('gameover')
	Game.playerData['mario']['big']=false
	Game.playerData['mario']['fire']=false
	Game.playerData['lives']-=1
	Game.playerData['score']=_title.score
	Game.playerData['coin']=_title.coinNum
	Game.playerData['subLevel']=''
	Game.playerData['time']=0
	var temp=menu.instance()
	temp.marioDeathPos=marioDeathPos
	temp.status=constants.gameRestart
	queue_free()
	set_process_input(false)
	get_tree().get_root().add_child(temp)
	set_process_input(true)

func _input(event):
	if !isShow:
		if !gameOver &&Input.is_action_just_pressed("ui_accept"):
			if gamePause:
				_title.startCountDown()
				gamePause=false
				SoundsUtil.playPause()
				SoundsUtil.playBgm()
				for i in _obj.get_children():
					i.resume()
			else:
				_title.stopCountDown()	
				gamePause=true
				SoundsUtil.stopBgm()
#				SoundsUtil.stopSpecialBgm()
				SoundsUtil.playPause()
				for i in _obj.get_children():
					i.pause()
				
			

