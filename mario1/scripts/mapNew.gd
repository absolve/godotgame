extends Node2D
#新的地图 新的碰撞检测
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

onready var _obj=$obj
onready var _tile=$tile
onready var _fps=$layer/fps
onready var _camera=$camera
onready var _timer=$Timer
onready var _gameover=$gameover

#var path="res://levels/1-1.json"
var mapDir="res://levels"	#内置地图路径
var currentLevel
var mapWidthSize=0
var mapName  #地图的名字
var time		#时间
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
var nextLevel=""
var enemyList=[]

func _ready():
#	VisualServer.set_default_clear_color(Color('#5C94FC'))
	Game.setMap(self)
	winWidth= ProjectSettings.get_setting("display/window/size/width")
	winHeight=ProjectSettings.get_setting("display/window/size/height")
	Game.connect("marioStateChange",self,'marioStateChange')
	Game.connect("marioStateFinish",self,'marioStateFinish')
	Game.connect("invincibleFinish",self,"invincibleFinish")
	Game.connect("marioInCastle",self,"marioInCastle")
	Game.connect("marioIntoPipe",self,"marioIntoPipe")
	Game.connect("timeOut",self,"timeOut")
	Game.connect("hurryup",self,"hurryup")
	
	loadMapFile("res://levels/1-1-1.json")
#	var dir = Directory.new()
#	if dir.file_exists(mapDir+'/'+Game.playerData['level']+".json"):
#		print("ok")
#		loadMapFile(mapDir+'/'+Game.playerData['level']+".json")
#	else:
#		print("文件不存在")
	
	
	subLevel=Game.playerData['subLevel']
	if subLevel=='':
		initEnemy()	#初始化当前画面的敌人			
		pass
	else:
		if subLevel!='':
			for i in specialEntrance:
				if i['pipeNo']==subLevel:
					if i['pipeType']==constants.pipeOut:
						for y in marioList:
							y.position.x = i['x']*blockSize
							y.position.y= i['y']*blockSize+\
									blockSize+y.getSizeY()/2
							y.setPipeOutStatus(i['y']*blockSize)				
							_camera.position.x=	i['x']*blockSize-int(winWidth/3)
							initEnemy()	#初始化当前画面的敌人
							break		
					break
		pass	
		
#	set_physics_process(false)
	pass

func _physics_process(delta):
	_update(delta)
	_fps.set_text(str("fps:",Engine.get_frames_per_second()))	
	pass

func _update(delta):
	for i in _obj.get_children():
		if i.destroy &&i.type==constants.box:
			mapData[str(i.localx,',',i.localy)]=null
			i.queue_free()
		elif i.destroy:
			i.queue_free()	
		if i.type!=constants.box&&i.type!=constants.pole&&i.type!=constants.collision&&\
			i.type!=constants.bigCoin:
			if i.getRight()<_camera.position.x||i.getLeft()>_camera.position.x+winWidth*1.6:
				i.queue_free()	
			if i.getTop()>winHeight:
				if i.type==constants.mario:
					if i.status!=constants.deadJump:
						marioStateChange()
					_gameover.start()
				i.queue_free()	
			pass
			
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
			#前进
			if mario1.status!=constants.sitBottomOfPole&& mario1.xVel>=0 \
				&& mario1.position.x>_camera.get_camera_screen_center().x+20&&\
					_camera.position.x <mapWidthSize*blockSize-winWidth:
				if _camera.position.x>mapWidthSize*blockSize-winWidth:
					_camera.position.x=mapWidthSize*blockSize-winWidth
				else:
					_camera.position.x+=int(abs(mario1.position.x-_camera.get_camera_screen_center().x-20))
			#后退		
			if mario1.xVel<0 && mario1.position.x<_camera.get_camera_screen_center().x-40&&\
				_camera.position.x>0:
				if _camera.position.x<0:
					_camera.position.x=0
				else:		
					_camera.position.x-=int(abs(mario1.position.x-_camera.get_camera_screen_center().x+40))
			for e in enemyList:
				if e['init']:
					continue
				if e.x*blockSize+blockSize/2>=_camera.position.x+winWidth && \
					e.x*blockSize+blockSize/2<=_camera.position.x+winWidth*1.2:
						addEnemy(e)
						e['init']=true
		
		
				
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
#				if hasTile(a,b)&&y.active:
				if mapData.get(str(a,",",b),null)!=null&&y.active:
					if y.mask.has(mapData[str(a,",",b)].type):
						var result=checkCollision(y,mapData[str(a,",",b)],delta)
						if result[0]:
							hCollision=true
						if result[1]:	
							vCollision=true
	#		if y.type==constants.mushroom:
#			print('-----',hCollision,vCollision)
		
		
		#与物体间的碰撞 选择x轴y轴最近的物体
		for x in _obj.get_children():
			if y!=x&&y.mask.has(x.type)&&!x.destroy&&!y.destroy&&y.active:
#				if y.getLeft()<=x.getRight()-1 &&y.getRight()>=x.getLeft()+1&&\
#					y.getTop()<=x.getBottom()-1&&y.getBottom()>=x.getTop()+1:
					
#				if y.position.x-y.rect.size.x/2<=x.position.x+x.rect.size.x/2 -1&&\
#					y.position.x+y.rect.size.x/2>=x.position.x-x.rect.size.x/2+1&&\
#					y.position.y-y.rect.size.y/2<=x.position.y+x.rect.size.y/2-1&&\
#					y.position.y+y.rect.size.y/2-1>=x.position.y-x.rect.size.y/2+1:
				if x.type==constants.pole && y.position.x-y.rect.size.x/2<=x.position.x+x.rect.size.x/2 -1&&\
					y.position.x+y.rect.size.x/2>=x.position.x-x.rect.size.x/2+1:
					var result=checkCollision(y,x,delta)
					if result[0]:
						hCollision=true
					if result[1]:	
						vCollision=true
				elif y.position.x-y.rect.size.x/2<=x.position.x+x.rect.size.x/2 -1&&\
					y.position.x+y.rect.size.x/2>=x.position.x-x.rect.size.x/2+1&&\
					y.position.y-y.rect.size.y/2<=x.position.y+x.rect.size.y/2-1&&\
					y.position.y+y.rect.size.y/2-1>=x.position.y-x.rect.size.y/2+1:		
					var result=checkCollision(y,x,delta)
					if result[0]:
						hCollision=true
					if result[1]:	
						vCollision=true
			pass
		
#		if y.type==constants.mushroom&&y.status==constants.moving:
#			print('======',hCollision,vCollision)
#			if !vCollision:
#				print('=======')
#			pass
		
		
		if !vCollision&&y.active:
			y.position.y+=y.yVel*delta	
			y.isOnFloor=false
		else:
			y.isOnFloor=true
		
		if !hCollision&&y.active:
			y.position.x+=y.xVel*delta	
					
	pass


func checkCollision(a,b,delta):
	var hCollision=false
	var vCollision=false

	#如果a物体x轴和y轴移动发生于b物体的碰撞 判断是那个方向上的碰撞

	if !is_instance_valid(a)||!is_instance_valid(b):
		return [hCollision,vCollision]
	var aRect= a.getRect()
	var bRect=b.getRect()
	if  aRect.intersects(bRect,true):	#判断左右是否碰撞
		var xVal =a.position.x-b.position.x
		var dx=(b.position.x-a.position.x)/b.getSize()/2
		var dy=(b.getCenterY()-a.getCenterY())/b.getSizeY()/2
#		if b.type==constants.pole:
#			print(a.position.x,' ',b.position.x,' ',b.getSize())
		if abs(dx)>abs(dy): #左右的碰撞	
			if xVal<0&&a.xVel>=0:	
				if hCollision(a,b,delta)==true:
					hCollision=true
			elif xVal>0 &&a.xVel<0:
				if hCollision(a,b,delta)==true:
					hCollision=true
	
	#排除边缘的碰撞	
	if  aRect.intersects(bRect,true)&&a.getLeft()<b.getRight()&&a.getRight()>b.getLeft():	
		var yVal =a.position.y-b.position.y		
		var dx=(b.position.x-a.position.x)/b.getSize()/2
		var dy=(b.position.y-a.position.y)/b.getSizeY()/2
		
		if abs(dy)>abs(dx):
			if dy<0 &&a.yVel<0 :
				if vCollision(a,b,delta)==true:
					vCollision=true	
#				if dx>=0 && abs(a.getRight()-b.getLeft())>abs(a.getBottom()-b.getTop()):
#					if vCollision(a,b,delta)==true:
#						vCollision=true	
#				elif dx<0 && abs(a.getLeft()-b.getRight())>abs(a.getBottom()-b.getTop()):
#					if vCollision(a,b,delta)==true:
#						vCollision=true				
			elif  dy>0	&&  a.yVel>=0:  #判断地面上是否有物体
				#如果只是走过一个间隙 判断重叠部分是x多还是y多
				if dx>=0 && abs(a.getRight()-b.getLeft())>abs(a.getBottom()-b.getTop()):
					if vCollision(a,b,delta)==true:
						vCollision=true	
					pass
				elif dx<0 && abs(a.getLeft()-b.getRight())>abs(a.getBottom()-b.getTop()):
					if vCollision(a,b,delta)==true:
						vCollision=true	
				else:
					if dx>0&&a.xVel>0:	
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

#		else:
#			if b.xVel<0:
#				b.xVel=0
#			b.position.x=a.getRight()+b.getSize()/2
		
		if a.has_method('rightCollide'):
			if a.rightCollide(b)==true: #需要处理位置	
#				print(a.type,b.type)
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
#		else:
#			if b.xVel>0:
#				b.xVel=0
#			b.position.x=a.getLeft()-b.getSize()/2
		
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
#		else:
#			if b.yVel<0:
#					b.yVel=0
#			b.position.y=a.getBottom()+b.getSizeY()/2
				
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
#		else:
#			if b.yVel>0:
#					b.yVel=0
#			b.position.y=a.getTop()-b.getSizeY()/2	
				
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

#载入文件
func loadMapFile(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		currentLevel= parse_json(file.get_as_text())
		mapWidthSize=int(currentLevel['mapSize'])
		time =int(currentLevel['time'])
#		if currentLevel['bg']=="overworld":
#			_bg.color=Color(Game.backgroundcolor[0])
#		elif currentLevel['bg']=="castle":
#			_bg.color=Color(Game.backgroundcolor[1])
#		elif currentLevel['bg']=="underwater":	
#			_bg.color=Color(Game.backgroundcolor[2])
#		setMapArray(15,mapWidthSize)
		if currentLevel.has('mapName'):
			mapName=str(currentLevel['mapName'])
		
		if currentLevel.has('nextLevel'):
			nextLevel=str(currentLevel['nextLevel'])
			
		music=str(currentLevel['music'])
		SoundsUtil.bgm=music
		SoundsUtil.isLowTime=false
		
		var pos = currentLevel['marioPos']
		if !pos.empty():  #添加mario
#			if mode=='game' ||  mode=='show':
			var temp=mario.instance()
			temp.position.x=pos['x']*blockSize+blockSize/2
			temp.position.y=pos['y']*blockSize+blockSize/2
#				temp.big=Game.playerData['mario']['big']
#			temp.big=true
#				temp.fire=Game.playerData['mario']['fire']
#			temp.fire=true
			_obj.add_child(temp)
			marioList.append(temp)
				
		marioPos=pos
		
		for i in currentLevel['data']:
			if i['type'] =='brick':
				var temp=brick.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.localx=i['x']
				temp.localy=i['y']
#				var obj={"x":i['x'],"y":i['y']}
				_tile.add_child(temp)
				mapData[str(i['x'],",",i['y'])]=temp
				pass
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
#				var obj={"x":i['x'],"y":i['y']}
				_obj.add_child(temp)
				mapData[str(i['x'],",",i['y'])]=temp
			elif i['type']=="platform":
				var temp=platform.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2	
				temp.lens=int(i['lens'])
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
			elif  i['type']=='flag':  #旗杆
				var temp = pole.instance()
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.poleLen=int(i['len'])
				_obj.add_child(temp)
			elif  i['type']=='collision':
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
					i['type']==constants.plant:
					i['init']=false
					enemyList.append(i)	
						
		file.close()
#		print(mapData)
	else:
		print('文件不存在')	
		pass
	pass

#载入子关卡
func loadSubLevelMap(level,subLevel):
	Game.playerData['level']=level
	Game.playerData['subLevel']=subLevel
	SoundsUtil.stopBgm()
	SoundsUtil.stopSpecialBgm()
	var scene=load("res://scenes/mapNew.tscn")
	var temp=scene.instance()
	queue_free()
	set_process_input(false)
	get_tree().get_root().add_child(temp)
	set_process_input(true)
	pass

#根据坐标获取
func getMapBrick(x,y):
	var mapx=floor(x/blockSize)
	var mapy=floor(y/blockSize)
	if hasTile(mapx,mapy):
		return mapData[str(mapx,",",mapy)]
	return null
	pass

func checkMapBrick(x,y):
	var mapx=floor(x/blockSize)
	var mapy=floor(y/blockSize)
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
	
	pass

func addScore(_position,_score=100):
	var temp=score.instance()
	temp.setPos(_position)
	temp.setScore(_score)
	_obj.add_child(temp)
	pass

func addLive(_position,id):
	var temp=score.instance()
	temp.setPos(_position)
	temp.setScore("1UP")
	_obj.add_child(temp)

#添加	
func addEnemy(obj):
	print('addEnemy',obj.type)
	if obj.type==constants.goomba:
		var temp =goomba.instance()
		temp.position.x=obj['x']*blockSize+blockSize/2
		temp.position.y=obj['y']*blockSize+blockSize/2
#		temp.offsetX=obj['offsetX']
#		temp.offsetY=obj['offsetY']
		temp.spriteIndex=obj['spriteIndex']
		temp.dir=obj['dir']
		_obj.add_child(temp)
		pass	
	elif obj.type==constants.plant:
		var temp=plant.instance()
		temp.position.x=obj['x']*blockSize+blockSize/2
		temp.position.y=obj['y']*blockSize+blockSize/2
		temp.offsetX=obj['offsetX']
		temp.offsetY=obj['offsetY']
		temp.spriteIndex=obj['spriteIndex']
		_obj.add_child(temp)
		pass
	elif obj.type==constants.koopa:
		var temp =koopa.instance()	
		temp.position.x=obj['x']*blockSize+blockSize/2
		temp.position.y=obj['y']*blockSize+blockSize/2
		temp.spriteIndex=obj['spriteIndex']
		temp.dir=obj['dir']
		_obj.add_child(temp)
		pass

func initEnemy():
	for e in enemyList:
		if e['init']:
			continue
		if e.x*blockSize+blockSize/2>_camera.position.x&& \
			e.x*blockSize+blockSize/2<_camera.position.x+winWidth:
				e['init']=true
				addEnemy(e)	
	pass
			
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
	for i in _obj.get_children():
		if i.type!=constants.mario:
			i.active=false
			i.pause()

#状态结束	
func marioStateFinish():
	for i in _obj.get_children():
		if i.type!=constants.mario:
			i.active=true
			i.resume()
	pass	

func invincibleFinish():
	SoundsUtil.stopSpecialBgm()
	SoundsUtil.playBgm()
	pass

#进入城堡
func marioInCastle():
	print('marioInCastle',nextLevel)
	subLevel=''
	_timer.start()
	pass

#进入水管
func marioIntoPipe(pipeNo):
	print('marioIntoPipe',pipeNo)
	for i in specialEntrance:
		if i.has('pipeNo')&&i['pipeNo']==pipeNo:
#			for y in range(300):
#				yield(get_tree(), "idle_frame")
			nextLevel=i['level']
			subLevel=i['subLevel'] #水管或者树的编号
			isLoadsubLevel=true
			_timer.start()
#			loadSubLevelMap(i['level'],i['subLevel'])
			break

#超时
func timeOut():
	
	pass
	
func hurryup():	
	print("hurryup")
	SoundsUtil.playLowTime()

func getObj():
	return _obj
	
func _draw():
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
	pass


func _on_Timer_timeout():
	if isLoadsubLevel:
		loadSubLevelMap(nextLevel,subLevel)
	else:
		var temp=menu.instance()
#		Game.playerData['score']=_title.score
#		Game.playerData['coin']=_title.coinNum
#		Game.playerData['subLevel']=''
		queue_free()
		set_process_input(false)
		get_tree().get_root().add_child(temp)
		set_process_input(true)
		pass	
	pass # Replace with function body.


func _on_gameover_timeout():
	print('gameover')
	pass # Replace with function body.
