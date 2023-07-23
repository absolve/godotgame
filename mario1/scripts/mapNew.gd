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
#var mazeObjList={} #迷宫中场景的方块和箱子的数据 key 迷宫id value 迷宫场景数据
#var mapObjList={} #地图对象以x,y为key value为对象
#var mapBgList={}	#背景的信息以x,y为key value为对象
#var mapBgData={}	#保存的是背景的节点数据
#var mapOtherList={} #一些平台或者其他需要保存的数据以x,y为key value为对象

var mazeInprogress=false #需要分段加载的地图
var oldMazeList=[] #保存需要分批加载的迷宫

var mapObjData={'bg':{},'obj':{}}#地图中对象的node数据
var mapObj={'tile':{},'bg':{},'obj':{}} #用来保存地图中一些对象的json数据



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
	Game.connect('mazegate',self,'mazegate')
	
	if isShow:
		_fps.visible=false
		return
		

	loadMapFile("res://levels/4-4.json")
#	var dir = Directory.new()
#	if dir.file_exists(mapDir+'/'+Game.playerData['level']+".json"):
#		print("ok")
#		loadMapFile(mapDir+'/'+Game.playerData['level']+".json")
#	else:
#		print("文件不存在")
	
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
				
	#改为只更新屏幕内的箱子	
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
			if scrollEnd:
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
			#如果马里奥到了迷宫的尽头判断迷宫是否有效
			#如果是就在屏幕外部添加一段迷宫地图，并把原先地图后移，在把迷宫到屏幕的位置
			#设置成新的位置，如果迷宫失效直接忽略	
			for m in mazeList:
				if mazeList[m].vaild:
					if mazeList[m]['endX']<=i.position.x:
#						print(mazeList[m])		
						var tempMapList=[]
						var tempMapObjList=[]
						var tempMapBgList=[]
						var tempMapBgData=[]
						var tempObj=[]
						var tempObjData=[]
						#从当前屏幕最右侧到迷宫的开始位置
						var mazeLength=floor((_camera.position.x+winWidth
										-mazeList[m]['startX'])/blockSize)  
#						print(_camera.position.x+winWidth)
#						print('result ',_camera.position.x+winWidth-mazeList[m]['startX'])
#						print('startX ',mazeList[m]['startX'])
#						print('mazeLength ',mazeLength)
#						print('mario ',i.position.x)
#						print('mapWidthSize ',mapWidthSize)
#						print('移动位置 ',floor((_camera.position.x+winWidth)/blockSize))
						#移动屏幕外的方块和物体
						for z in range(floor((_camera.position.x+winWidth)/blockSize),mapWidthSize):
							for w in range(0,winHeight/blockSize+1):
								if mapData.has(str(z,',',w)):
									var b=mapData[str(z,',',w)]
									b.position.x+=mazeLength*blockSize
									b.localx+=mazeLength
									tempMapList.append(b)
									mapData.erase(str(z,',',w))
#								if mapObjList.has(str(z,',',w)): #存的是地图方块json数据
#									var b=mapObjList[str(z,',',w)]
#									tempMapObjList.append(b)
#									b.x+=mazeLength
#									mapObjList.erase(str(z,',',w))
								if mapObj.tile.has(str(z,',',w)): #存的是地图方块json数据
									var b=mapObj.tile[str(z,',',w)]
									tempMapObjList.append(b)
									b.x+=mazeLength
									mapObj.tile.erase(str(z,',',w))	
									
								if mapObj.bg.has(str(z,',',w)):
									var b=mapObj.bg[str(z,',',w)]
									tempMapBgList.append(b)
									b.x+=mazeLength
									mapObj.bg.erase(str(z,',',w))
								if mapObjData.bg.has(str(z,',',w)):
									var b=mapObjData.bg[str(z,',',w)]
									b.position.x+=mazeLength*blockSize
									b.localx+=mazeLength
									tempMapBgData.append(b)
									mapObjData.bg.erase(str(z,',',w))
								if mapObj.obj.has(str(z,',',w)):
									var b=mapObj.obj[str(z,',',w)]
									tempObj.append(b)
									b.x+=mazeLength
									mapObj.obj.erase(str(z,',',w))
								if mapObjData.obj.has(str(z,',',w)):
									var b=mapObjData.obj[str(z,',',w)]
									if b.type==constants.spinFireball:
										for x in b.list:
											x.position.x+=mazeLength*blockSize
											x.aroundPos.x+=mazeLength*blockSize
										b.localx+=mazeLength	
									else:	
										b.position.x+=mazeLength*blockSize
										b.localx+=mazeLength
									tempObjData.append(b)
									mapObjData.obj.erase(str(z,',',w))
									
						for t in tempMapList:	#重建方块的字典
							mapData[str(t.localx,",",t.localy)]=t
						for t in tempMapObjList:
							mapObj.tile[str(t.x,",",t.y)]=t	
						for t in tempMapBgList: 
							mapObj.bg[str(t.x,",",t.y)]=t	
						for t in tempMapBgData:
							mapObjData.bg[str(t.localx,",",t.localy)]=t	
						for t in tempObj:
							mapObj.obj[str(t.x,",",t.y)]=t		
						for t in tempObjData:
							mapObjData.obj[str(t.localx,",",t.localy)]=t			
							
						#移动屏幕外敌人的位置	
						for z in range(mapWidthSize,floor((_camera.position.x+winWidth)/blockSize),-1):
							if enemyPosList.has(str(z)):	
								var temp=enemyPosList[str(z)]
								enemyPosList[str(z+mazeLength)]=temp
								for e in temp:
									e.x+=mazeLength
								enemyPosList.erase(str(z))

						#移动屏幕外区域的位置
						for a in areaList:
							if a['startX']>mazeList[m]['endX']:
								a['startX']+=mazeLength*blockSize		
								a['endX']+=mazeLength*blockSize				
								

						mapWidthSize+=mazeLength
						if castleEndX!=0:	#把斧头的位置移动
							castleEndX+=mazeLength*blockSize
						#复制迷宫里面的场景信息 todo 需要分批次添加地图信息 否者地图太大影响加载
						var offsetx=mazeLength
						var mazeEnd=floor((_camera.position.x+winWidth)/blockSize)
						if mazeEnd>minWidthNum: #如果迷宫大小超过了一个屏幕就需要分段加载
							mazeEnd=mazeList[m]['startX']/blockSize+minWidthNum/2
							mazeInprogress=true
							var tempMaze={
								"startX":mazeList[m]['startX']/blockSize,
								"endX":floor((_camera.position.x+winWidth)/blockSize),
								"current":mazeEnd,#当前的剩下需要添加的地图
								"mazeId":mazeList[m].mazeId,
								"offsetx":mazeLength,#地图中每一块添加的偏移
							}
#							print(tempMaze)
							oldMazeList.append(tempMaze)
						#创建迷宫内的场景	
#						for z in range(mazeList[m]['startX']/blockSize,mazeEnd):
#							for w in range(0,winHeight/blockSize+1):
#								if mapObj.tile.has(str(z,',',w)):
#									var obj=mapObj.tile[str(z,',',w)].duplicate(true)
#									if obj['type'] =='brick':
#										var temp=brick.instance()
#										temp.spriteIndex=obj['spriteIndex']
#										temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#										temp.position.y=obj['y']*blockSize+blockSize/2
#										temp.localx=obj['x']+offsetx
#										temp.localy=obj['y']
#										obj['x']+=offsetx
#										_tile.add_child(temp)
#										mapData[str(temp.localx,",",temp.localy)]=temp
#										mapObj.tile[str(temp.localx,",",temp.localy)]=obj
#									elif obj['type']=='box':
#										var temp=box.instance()
#										temp.spriteIndex=obj['spriteIndex']
#										temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#										temp.position.y=obj['y']*blockSize+blockSize/2
#										temp.localx=obj['x']+offsetx
#										temp.localy=obj['y']
#										obj['x']+=offsetx
#										temp.content=obj['content']
#										if typeof(obj['visible'])==TYPE_BOOL:
#											temp._visible=obj['visible']
#										elif typeof(obj['visible'])==TYPE_STRING:
#											if obj['visible']=="false"||obj['visible']=="f":
#												temp._visible=false
#											else:
#												temp._visible=true
#										if obj.has('level'):
#											temp.level=obj['level']
#										if obj.has('subLevel'):
#											temp.subLevel=obj['subLevel']
#										if obj.has('itemIndex'):
#											temp.itemIndex=int(obj['itemIndex'])							
#										_tile.add_child(temp)
#										mapData[str(temp.localx,",",temp.localy)]=temp
#										mapObj.tile[str(temp.localx,",",temp.localy)]=obj
#									elif obj['type']=='pipe':
#										var temp=pipe.instance()
#										temp.spriteIndex=obj['spriteIndex']
#										temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#										temp.position.y=obj['y']*blockSize+blockSize/2
#										temp.rotate=int(obj['rotate'])
#										temp.localx=obj['x']+offsetx
#										temp.localy=obj['y']
#										obj['x']+=offsetx
#										if obj.has('pipeType'):
#											temp.pipeType=obj['pipeType']
#										if obj.has('pipeNo'):
#											temp.pipeNo=obj['pipeNo']
#										if obj.has("dir"):
#											temp.dir=obj['dir']
#										_tile.add_child(temp)
#										if obj.has('pipeType')&&obj['pipeType']!=constants.empty&&obj['pipeType']!='':
#											specialEntrance.append(obj)
#										if obj.has('warpzoneNum')&& obj['warpzoneNum']!='':
#											warpZone.append(obj)
#										mapData[str(temp.localx,",",temp.localy)]=temp
#										mapObj.tile[str(temp.localx,",",temp.localy)]=obj	
#									elif obj['type']=='collision' && obj['value']=='mazeGate':
#										var temp=mazeGate.instance()
#										temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#										temp.position.y=obj['y']*blockSize+blockSize/2
#										temp.localx=obj['x']+offsetx
#										temp.localy=obj['y']
#										temp.gateId=obj['gateId']
#										temp.mazeId=mazeList[m].mazeId
#										obj['x']+=offsetx
#										_tile.add_child(temp)
#										mapData[str(temp.localx,",",temp.localy)]=temp
#										mapObj.tile[str(temp.localx,",",temp.localy)]=obj
#
#								if mapObj.bg.has(str(z,',',w)):
#									var obj=mapObj.bg[str(z,',',w)].duplicate(true)
#									var temp=background.instance()
#									temp.spriteIndex=obj['spriteIndex']
#									temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#									temp.position.y=obj['y']*blockSize+blockSize/2
#									temp.localx=obj['x']+offsetx
#									temp.localy=obj['y']
#									obj['x']+=offsetx
#									_tile.add_child(temp)
#									mapObjData.bg[str(temp.localx,",",temp.localy)]=temp
#									mapObj.bg[str(temp.localx,",",temp.localy)]=obj #背景数据保存起来
#
#								if mapObj.obj.has(str(z,',',w)):
#									var obj=mapObj.obj[str(z,',',w)].duplicate(true)
#									if obj['type']=='platform':
#										var temp=platform.instance()
#										temp.spriteIndex=obj['spriteIndex']
#										temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#										temp.position.y=obj['y']*blockSize+8
#										temp.localx=obj['x']+offsetx
#										temp.localy=obj['y']
#										temp.lens=int(obj['lens'])
#										if obj.has('platformType'):
#											temp.status=obj['platformType']
#										if obj.has('dir'):
#											temp.dir=obj['dir']
#										if obj.has('speed'):
#											temp.speed=int(obj['speed'])					
#										_obj.add_child(temp)
#										obj['x']+=offsetx
#										mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
#										mapObj.obj[str(temp.localx,",",temp.localy)]=obj
#									elif obj['type']=='jumpingBoard':
#										var  temp=jumpingBoard.instance()
#										temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#										temp.position.y=obj['y']*blockSize
#										temp.localx=obj['x']+offsetx
#										temp.localy=obj['y']
#										_obj.add_child(temp)
#										obj['x']+=offsetx
#										mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
#										mapObj.obj[str(temp.localx,",",temp.localy)]=obj
#									elif obj['type']=='podoboo':
#										var temp=podoboo.instance()
#										temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#										temp.position.y=obj['y']*blockSize+blockSize/2
#										temp.localx=obj['x']+offsetx
#										temp.localy=obj['y']
#										temp.spriteIndex=i['spriteIndex']
#										_obj.add_child(temp)	
#										obj['x']+=offsetx
#										mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
#										mapObj.obj[str(temp.localx,",",temp.localy)]=obj	
#									elif obj['type']=='cannon':
#										var temp=cannon.instance()
#										temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#										temp.position.y=obj['y']*blockSize+blockSize/2
#										temp.spriteIndex=obj['spriteIndex']
#										temp.localx=obj['x']+offsetx
#										temp.localy=obj['y']
#										_obj.add_child(temp)	
#										obj['x']+=offsetx
#										mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
#										mapObj.obj[str(temp.localx,",",temp.localy)]=obj
#									elif obj['type']==constants.staticPlatform:
#										var temp=staticPlatform.instance()
#										temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#										temp.position.y=obj['y']*blockSize+blockSize/4
#										temp.spriteIndex=obj['spriteIndex']
#										temp.localx=obj['x']+offsetx
#										temp.localy=obj['y']
#										temp.lens=int(obj['lens'])
#										temp.status=obj['status']
#										_obj.add_child(temp)
#										obj['x']+=offsetx
#										mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
#										mapObj.obj[str(temp.localx,",",temp.localy)]=obj
#									elif obj['type']==constants.linkPlatform:
#										var temp=linkPlatform.instance()
#										temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#										temp.position.y=obj['y']*blockSize+blockSize/2
#										temp.spriteIndex=obj['spriteIndex']
#										temp.distance=int(obj['distance'])*32
#										temp.leftHeight=int(obj['leftHeight'])
#										temp.rightHeight=int(obj['rightHeight'])
#										temp.localx=obj['x']+offsetx
#										temp.localy=obj['y']
#										if obj.has('lens'):
#											temp.lens=int(obj['lens'])
#										_obj.add_child(temp)
#										obj['x']+=offsetx
#										mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
#										mapObj.obj[str(temp.localx,",",temp.localy)]=obj
#									elif obj['type']=='spinFireball': #旋转的火球
#										if int(obj['len'])>0:
#											var s={'localx':obj['x']+offsetx,'localy':obj['y'],
#											'type':'spinFireball','list':[]}
#											for x in range(int(obj['len'])):
#												var temp=spinFireball.instance()
#												temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
#												temp.position.y=obj['y']*blockSize+blockSize/2
#												temp.aroundPos=Vector2(obj['x']*blockSize+blockSize/2+offsetx*blockSize,
#													obj['y']*blockSize+blockSize/2)
#												temp.radius=x*18
#
#												s.list.append(temp)
#												_obj.add_child(temp)
#											obj['x']+=offsetx
#											mapObjData.obj[str(s.localx,",",s.localy)]=s
#											mapObj.obj[str(obj['x'],",",obj['y'])]=obj	
						addMaze(mazeList[m]['startX']/blockSize,mazeEnd,offsetx,mazeList[m].mazeId)				
						
						
						#移动迷宫内敌人的位置
						for w in range(mazeList[m].startX/blockSize,mazeList[m].endX/blockSize):
							if enemyPosList.has(str(w)):
								var temp=enemyPosList[str(w)]
								enemyPosList[str(w+offsetx)]=temp.duplicate(true)
								for e in enemyPosList[str(w+offsetx)]:
									e.x+=offsetx
									e.init=false

						#重新设置其他有效迷宫的位置
						for x in mazeList:
							if  mazeList[x].mazeId!=mazeList[m].mazeId\
							&& mazeList[x].vaild && \
							mazeList[x].endX>mazeList[m].endX:
								mazeList[x].startX+=offsetx*blockSize
								mazeList[x].endX+=offsetx*blockSize
						#修改当前的地图位置
						mazeList[m].startX+=offsetx*blockSize
						mazeList[m].endX+=offsetx*blockSize
						for s in mazeList[m].gate:	#重新设置迷宫门的状态
							mazeList[m].gate[s]=0
							
						
	if mazeInprogress:	#如果迷宫需要分段加载 每次加载一个屏幕大小的迷宫知道完成
		for i in oldMazeList: #每次添加半个屏幕大小
			if _camera.position.x+winWidth>i.current*blockSize+\
				i.offsetx*blockSize-blockSize*minWidthNum/2:
				print('创建迷宫')
				var mazeEnd=i.current+minWidthNum/2
				if mazeEnd>i.endX:	#如果最后一个不超过半个屏幕就是endX位置
					mazeEnd=i.endX
				addMaze(i.current,mazeEnd,i.offsetx,i.mazeId)	
				i.current=mazeEnd
				print(i.current)		
				
		for i in oldMazeList: #删除
			if i.current>=i.endX:
				oldMazeList.erase(i)
		if oldMazeList.size()==0:
			print('迷宫已完成')
			mazeInprogress=false
									
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
				
		#检测附近的砖块根据方向来决定方块的位置
		var xstart=floor((y.position.x-y.rect.size.x)/blockSize)
		var xend=floor((y.position.x+y.rect.size.x)/blockSize)
#		var xend=floor((y.position.x+y.getSize())/blockSize)

#		var ystart=floor((y.position.y-y.getSizeY())/blockSize)
#		var yend=floor((y.position.y+y.getSizeY())/blockSize)
		var ystart=floor((y.position.y-y.rect.size.y)/blockSize)
		var yend=floor((y.position.y+y.rect.size.y)/blockSize)
	
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
					
#添加迷宫
func addMaze(start,end,offsetx,mazeId):
	for z in range(start,end):
		for w in range(0,winHeight/blockSize+1):
			if mapObj.tile.has(str(z,',',w)):
				var obj=mapObj.tile[str(z,',',w)].duplicate(true)
				if obj['type'] =='brick':
					var temp=brick.instance()
					temp.spriteIndex=obj['spriteIndex']
					temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
					temp.position.y=obj['y']*blockSize+blockSize/2
					temp.localx=obj['x']+offsetx
					temp.localy=obj['y']
					obj['x']+=offsetx
					_tile.add_child(temp)
					mapData[str(temp.localx,",",temp.localy)]=temp
					mapObj.tile[str(temp.localx,",",temp.localy)]=obj
				elif obj['type']=='box':
					var temp=box.instance()
					temp.spriteIndex=obj['spriteIndex']
					temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
					temp.position.y=obj['y']*blockSize+blockSize/2
					temp.localx=obj['x']+offsetx
					temp.localy=obj['y']
					obj['x']+=offsetx
					temp.content=obj['content']
					if typeof(obj['visible'])==TYPE_BOOL:
						temp._visible=obj['visible']
					elif typeof(obj['visible'])==TYPE_STRING:
						if obj['visible']=="false"||obj['visible']=="f":
							temp._visible=false
						else:
							temp._visible=true
					if obj.has('level'):
						temp.level=obj['level']
					if obj.has('subLevel'):
						temp.subLevel=obj['subLevel']
					if obj.has('itemIndex'):
						temp.itemIndex=int(obj['itemIndex'])							
					_tile.add_child(temp)
					mapData[str(temp.localx,",",temp.localy)]=temp
					mapObj.tile[str(temp.localx,",",temp.localy)]=obj
				elif obj['type']=='pipe':
					var temp=pipe.instance()
					temp.spriteIndex=obj['spriteIndex']
					temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
					temp.position.y=obj['y']*blockSize+blockSize/2
					temp.rotate=int(obj['rotate'])
					temp.localx=obj['x']+offsetx
					temp.localy=obj['y']
					obj['x']+=offsetx
					if obj.has('pipeType'):
						temp.pipeType=obj['pipeType']
					if obj.has('pipeNo'):
						temp.pipeNo=obj['pipeNo']
					if obj.has("dir"):
						temp.dir=obj['dir']
					_tile.add_child(temp)
					if obj.has('pipeType')&&obj['pipeType']!=constants.empty&&obj['pipeType']!='':
						specialEntrance.append(obj)
					if obj.has('warpzoneNum')&& obj['warpzoneNum']!='':
						warpZone.append(obj)
					mapData[str(temp.localx,",",temp.localy)]=temp
					mapObj.tile[str(temp.localx,",",temp.localy)]=obj	
				elif obj['type']=='collision' && obj['value']=='mazeGate':
					var temp=mazeGate.instance()
					temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
					temp.position.y=obj['y']*blockSize+blockSize/2
					temp.localx=obj['x']+offsetx
					temp.localy=obj['y']
					temp.gateId=obj['gateId']
					temp.mazeId=mazeId
					obj['x']+=offsetx
					_tile.add_child(temp)
					mapData[str(temp.localx,",",temp.localy)]=temp
					mapObj.tile[str(temp.localx,",",temp.localy)]=obj

			if mapObj.bg.has(str(z,',',w)):
				var obj=mapObj.bg[str(z,',',w)].duplicate(true)
				var temp=background.instance()
				temp.spriteIndex=obj['spriteIndex']
				temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
				temp.position.y=obj['y']*blockSize+blockSize/2
				temp.localx=obj['x']+offsetx
				temp.localy=obj['y']
				obj['x']+=offsetx
				_tile.add_child(temp)
				mapObjData.bg[str(temp.localx,",",temp.localy)]=temp
				mapObj.bg[str(temp.localx,",",temp.localy)]=obj #背景数据保存起来

			if mapObj.obj.has(str(z,',',w)):
				var obj=mapObj.obj[str(z,',',w)].duplicate(true)
				if obj['type']=='platform':
					var temp=platform.instance()
					temp.spriteIndex=obj['spriteIndex']
					temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
					temp.position.y=obj['y']*blockSize+8
					temp.localx=obj['x']+offsetx
					temp.localy=obj['y']
					temp.lens=int(obj['lens'])
					if obj.has('platformType'):
						temp.status=obj['platformType']
					if obj.has('dir'):
						temp.dir=obj['dir']
					if obj.has('speed'):
						temp.speed=int(obj['speed'])					
					_obj.add_child(temp)
					obj['x']+=offsetx
					mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
					mapObj.obj[str(temp.localx,",",temp.localy)]=obj
				elif obj['type']=='jumpingBoard':
					var  temp=jumpingBoard.instance()
					temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
					temp.position.y=obj['y']*blockSize
					temp.localx=obj['x']+offsetx
					temp.localy=obj['y']
					_obj.add_child(temp)
					obj['x']+=offsetx
					mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
					mapObj.obj[str(temp.localx,",",temp.localy)]=obj
				elif obj['type']=='podoboo':
					var temp=podoboo.instance()
					temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
					temp.position.y=obj['y']*blockSize+blockSize/2
					temp.localx=obj['x']+offsetx
					temp.localy=obj['y']
#					temp.spriteIndex=i['spriteIndex']
					_obj.add_child(temp)	
					obj['x']+=offsetx
					mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
					mapObj.obj[str(temp.localx,",",temp.localy)]=obj	
				elif obj['type']=='cannon':
					var temp=cannon.instance()
					temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
					temp.position.y=obj['y']*blockSize+blockSize/2
					temp.spriteIndex=obj['spriteIndex']
					temp.localx=obj['x']+offsetx
					temp.localy=obj['y']
					_obj.add_child(temp)	
					obj['x']+=offsetx
					mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
					mapObj.obj[str(temp.localx,",",temp.localy)]=obj
				elif obj['type']==constants.staticPlatform:
					var temp=staticPlatform.instance()
					temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
					temp.position.y=obj['y']*blockSize+blockSize/4
					temp.spriteIndex=obj['spriteIndex']
					temp.localx=obj['x']+offsetx
					temp.localy=obj['y']
					temp.lens=int(obj['lens'])
					temp.status=obj['status']
					_obj.add_child(temp)
					obj['x']+=offsetx
					mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
					mapObj.obj[str(temp.localx,",",temp.localy)]=obj
				elif obj['type']==constants.linkPlatform:
					var temp=linkPlatform.instance()
					temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
					temp.position.y=obj['y']*blockSize+blockSize/2
					temp.spriteIndex=obj['spriteIndex']
					temp.distance=int(obj['distance'])*32
					temp.leftHeight=int(obj['leftHeight'])
					temp.rightHeight=int(obj['rightHeight'])
					temp.localx=obj['x']+offsetx
					temp.localy=obj['y']
					if obj.has('lens'):
						temp.lens=int(obj['lens'])
					_obj.add_child(temp)
					obj['x']+=offsetx
					mapObjData.obj[str(temp.localx,",",temp.localy)]=temp
					mapObj.obj[str(temp.localx,",",temp.localy)]=obj
				elif obj['type']=='spinFireball': #旋转的火球
					if int(obj['len'])>0:
						var s={'localx':obj['x']+offsetx,'localy':obj['y'],
						'type':'spinFireball','list':[]}
						for x in range(int(obj['len'])):
							var temp=spinFireball.instance()
							temp.position.x=obj['x']*blockSize+blockSize/2+offsetx*blockSize
							temp.position.y=obj['y']*blockSize+blockSize/2
							temp.aroundPos=Vector2(obj['x']*blockSize+blockSize/2+offsetx*blockSize,
								obj['y']*blockSize+blockSize/2)
							temp.radius=x*18

							s.list.append(temp)
							_obj.add_child(temp)
						obj['x']+=offsetx
						mapObjData.obj[str(s.localx,",",s.localy)]=s
						mapObj.obj[str(obj['x'],",",obj['y'])]=obj
	pass


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
			
#		print(marioStatus)
		var pos = currentLevel['marioPos']
		if !pos.empty():  #添加mario
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
#				mapObjList[str(i['x'],",",i['y'])]=i
				mapObj.tile[str(i['x'],",",i['y'])]=i
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
#				mapObjList[str(i['x'],",",i['y'])]=i
				mapObj.tile[str(i['x'],",",i['y'])]=i
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
#				mapObjList[str(i['x'],",",i['y'])]=i
				mapObj.tile[str(i['x'],",",i['y'])]=i
			elif i['type']=="platform":
				var temp=platform.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+8
				temp.localx=i['x']
				temp.localy=i['y']
				temp.lens=int(i['lens'])
				if i.has('platformType'):
					temp.status=i['platformType']
				if i.has('dir'):
					temp.dir=i['dir']
				if i.has('speed'):
					temp.speed=int(i['speed'])
						
				_obj.add_child(temp)
				mapObjData.obj[str(i['x'],",",i['y'])]=temp
				mapObj.obj[str(i['x'],",",i['y'])]=i
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
				temp.localx=i['x']
				temp.localy=i['y']
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
#				mapObjList[str(i['x'],",",i['y'])]=i	
				mapObj.tile[str(i['x'],",",i['y'])]=i
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
				elif i['value']=='mazeGate': #迷宫门
					var temp=mazeGate.instance()
					temp.position.x=i['x']*blockSize+blockSize/2
					temp.position.y=i['y']*blockSize+blockSize/2
					temp.localx=i['x']
					temp.localy=i['y']
					temp.gateId=i['gateId']
					_tile.add_child(temp)
					mapData[str(i['x'],",",i['y'])]=temp
#					mapObjList[str(i['x'],",",i['y'])]=i
					mapObj.tile[str(i['x'],",",i['y'])]=i
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
				temp.localx=i['x']
				temp.localy=i['y']
				_tile.add_child(temp)
				mapObjData.bg[str(i['x'],",",i['y'])]=temp
				mapObj.bg[str(i['x'],",",i['y'])]=i
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
					
#				enemyList.append(i)
			elif i['type']=='castleFlag':
				var temp=castleFlag.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2	
				_obj.add_child(temp)
			elif i['type']=='spinFireball': #旋转的火球
				if int(i['len'])>0:
					var s={'localx':i['x'],'localy':i['y'],
					'type':'spinFireball','list':[]}
					for x in range(int(i['len'])):
						var temp=spinFireball.instance()
						temp.position.x=i['x']*blockSize+blockSize/2
						temp.position.y=i['y']*blockSize+blockSize/2
						temp.aroundPos=Vector2(i['x']*blockSize+blockSize/2,
							i['y']*blockSize+blockSize/2)
						temp.radius=x*18
						s.list.append(temp)
						_obj.add_child(temp)
					mapObjData.obj[str(i['x'],",",i['y'])]=s
					mapObj.obj[str(i['x'],",",i['y'])]=i	
			elif i['type']=='axe':
				var temp=axe.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.localx=i['x']
				temp.localy=i['y']
				castleEndX=temp.position.x+blockSize/2
				_obj.add_child(temp)
				mapObjData.obj[str(i['x'],",",i['y'])]=temp
				mapObj.obj[str(i['x'],",",i['y'])]=i
			elif i['type']=='figures':#人物
				var temp=figures.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.spriteIndex=i['spriteIndex']
				temp.localx=i['x']
				temp.localy=i['y']
				_obj.add_child(temp)
				mapObjData.obj[str(i['x'],",",i['y'])]=temp
				mapObj.obj[str(i['x'],",",i['y'])]=i
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
				mapObjData.obj[str(i['x'],",",i['y'])]=temp
				mapObj.obj[str(i['x'],",",i['y'])]=i
			elif i['type']=='podoboo':
				var temp=podoboo.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.spriteIndex=i['spriteIndex']
				temp.localx=i['x']
				temp.localy=i['y']
				_obj.add_child(temp)	
				mapObjData.obj[str(i['x'],",",i['y'])]=temp
				mapObj.obj[str(i['x'],",",i['y'])]=i	
			elif i['type']=='cannon':
				var temp=cannon.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.spriteIndex=i['spriteIndex']
				temp.localx=i['x']
				temp.localy=i['y']
				_obj.add_child(temp)	
				mapObjData.obj[str(i['x'],",",i['y'])]=temp
				mapObj.obj[str(i['x'],",",i['y'])]=i
			elif i['type']==constants.staticPlatform:
				var temp=staticPlatform.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/4
				temp.spriteIndex=i['spriteIndex']
				temp.lens=int(i['lens'])
				temp.status=i['status']
				temp.localx=i['x']
				temp.localy=i['y']
				_obj.add_child(temp)
				mapObjData.obj[str(i['x'],",",i['y'])]=temp
				mapObj.obj[str(i['x'],",",i['y'])]=i
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
				mapObjData.obj[str(i['x'],",",i['y'])]=temp
				mapObj.obj[str(i['x'],",",i['y'])]=i
				
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
		
		for i in mazeList:  #设置每个迷宫里面的门
			var m=mazeList[i]
			m['gate']={} #根据门id设置 value 0开启 1关闭
			for y in range(m.startX/blockSize,m.endX/blockSize):
				for z in range(0,winHeight/blockSize+1):
					if mapData.has(str(y,',',z)):
						var obj=mapData[str(y,',',z)]
						if obj.type==constants.mazeGate:
							obj.mazeId=m.mazeId
							if !m['gate'].has(obj.gateId):
								m['gate'][obj.gateId]=0
#		print(mazeList)							
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
		if obj.has('useHammer') && obj['useHammer']=='t':
			temp.useHammer=true
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

#设置迷宫门
func mazegate(mazeId,gateId):
#	print(mazeId,gateId)
	if mazeList.has(mazeId):
		if mazeList[mazeId].gate.has(gateId):
			mazeList[mazeId].gate[gateId]=1
#			print(mazeList[mazeId].gate.size())
			var num=0
			for i in  mazeList[mazeId].gate:
				if mazeList[mazeId].gate[i]==1:
					num+=1
			if num==mazeList[mazeId].gate.size():
				mazeList[mazeId].vaild=false
				print('迷宫',mazeId,'失效')
			
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
				SoundsUtil.playPause()
				for i in _obj.get_children():
					i.pause()
