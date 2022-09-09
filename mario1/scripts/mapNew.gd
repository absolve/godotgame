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

var path="res://levels/1-1.json"
var currentLevel
var mapWidthSize=0
var time
var music
var marioPos={} #mario地图出生地
var mode="game"  #game正常游戏  edit编辑  test测试  show展示
var mapData={}  #地图以x,y为key value为对象
var marioList=[]

func _ready():
	Game.setMap(self)
	loadMapFile("res://levels/test7.json")
	pass

func _process(delta):
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
	for i in _obj.get_children():
		i._update(delta)
		
	for y in _obj.get_children():
		var hCollision=false
		var vCollision=false
		if y.active:
			y.yVel+=y.gravity*delta		#增加y速度
			if y.yVel>y.maxYVel:
				y.yVel=y.maxYVel
			
		#检测附近的砖块根据方向来决定方块的位置
		var xstart=floor((y.position.x-y.getSize())/blockSize)
		var xend=floor((y.position.x+y.getSize())/blockSize)


		var ystart=floor((y.position.y-y.getSizeY())/blockSize)
		var yend=floor((y.position.y+y.getSizeY())/blockSize)
	
#		if y.yVel<0:
#			yend=ystart
#			ystart=ystart-1
		
#		print(xstart,'-',xend)
#		print(ystart,'-',yend)
		for a in range(xstart,xend+1):
			for b in range(ystart,yend+1):
				if hasTile(a,b)&&y.active:
					var result=checkCollision(y,mapData[str(a,",",b)],delta)
					if result[0]:
						hCollision=true
					if result[1]:	
						vCollision=true
		
		if !vCollision&&y.active:
#			if y.yVel>0&&y.yVel<100:
#				y.yVel+=150
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
#	if a.getRect().intersects(b.getRect(),true):
#		var dx=(b.position.x-a.position.x)/b.getSize()/2
#		var dy=(b.position.y-a.position.y)/b.getSizeY()/2
#		if abs(abs(dx)-abs(dy))<.1: 
#			if abs(a.yVel-a.gravity*delta)<abs(a.xVel):
#				if vCollision(a,b,delta)==true:
#					vCollision=true
#			else:
#				if hCollision(a,b,delta)==true:
#					hCollision=true
#		elif abs(dx)>abs(dy): #左右的碰撞	
#			if hCollision(a,b,delta)==true:
#				hCollision=true
#			pass
#		else:#上下的碰撞
#			if vCollision(a,b,delta)==true:
#				vCollision=true
#			pass
	if !is_instance_valid(a)||!is_instance_valid(b):
		return [hCollision,vCollision]
	
	if  a.getRect().intersects(b.getRect()):	#判断左右是否碰撞
		var xVal =a.position.x-b.position.x
		var absXVal=abs(xVal)
		var dx=(b.position.x-a.position.x)/b.getSize()/2
		var dy=(b.position.y-a.position.y)/b.getSizeY()/2
		if abs(dx)>abs(dy): #左右的碰撞	
			if xVal<0&&a.xVel>0:	
				if hCollision(a,b,delta)==true:
					hCollision=true
			elif xVal>0 &&a.xVel<0:
				if hCollision(a,b,delta)==true:
					hCollision=true
			
	if  a.getRect().intersects(b.getRect(),true)&&\
				!a.getRect().encloses(b.getRect()):	#判断上下是否碰撞
		var yVal =a.position.y-b.position.y		
		var dx=(b.position.x-a.position.x)/b.getSize()/2
		var dy=(b.position.y-a.position.y)/b.getSizeY()/2
		if abs(dy)>abs(dx)&&\
			abs(abs(b.position.x-a.position.x)-(a.getSize()/2+b.getSize()/2))>5:
			if abs(abs(dx)-abs(dy))<.1:
				print('111')
			
#			if vCollision(a,b,delta)==true:
#				vCollision=true		
			if yVal<0 && a.yVel>0:
				if vCollision(a,b,delta)==true:
					vCollision=true		
			elif yVal>0 && a.yVel<0:
				if vCollision(a,b,delta)==true:
					vCollision=true	
			pass
				
	pass
				
#	if Rect2(Vector2(a.position.x+a.xVel*delta,a.position.y)\
#		,Vector2(a.getSize(),a.getSizeY())).intersects(b.getRect()):
#		if hCollision(a,b,delta):
#			hCollision=true
#		pass
#	if Rect2(Vector2(a.position.x,a.position.y+a.yVel*delta)\
#		,Vector2(a.getSize(),a.getSizeY())).intersects(b.getRect()):
#		if vCollision(a,b,delta):
#			vCollision=true
#		pass
#	else: #这种碰撞是对角边缘碰撞和重叠碰撞
#		if abs(a.yVel-a.gravity*delta)<abs(a.xVel):
#			if vCollision(a,b,delta):
#				vCollision=true
#		else:
#			if hCollision(a,b,delta):
#				hCollision=true
#		pass
	
	return [hCollision,vCollision]
	pass

#左右判断
func hCollision(a,b,delta):
	if a.xVel>=0:
		if a.has_method('rightCollide'):
			if a.rightCollide(b)==true: #需要处理位置
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
	if a.yVel>0: #向下	
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
		
		
		music=str(currentLevel['music'])
		SoundsUtil.bgm=music
		SoundsUtil.isLowTime=false
		
		var pos = currentLevel['marioPos']
		if !pos.empty():  #添加mario
			if mode=='game' ||  mode=='show':
				var temp=mario.instance()
				temp.position.x=pos['x']*blockSize+blockSize/2
				temp.position.y=pos['y']*blockSize+blockSize/2
#				temp.big=Game.playerData['mario']['big']
				temp.big=true
				temp.fire=Game.playerData['mario']['fire']
				_obj.add_child(temp)
				marioList.append(_obj)
				
		marioPos=pos
		
		for i in currentLevel['data']:
			if i['type'] =='brick':
				var temp=brick.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				temp.localx=i['x']
				temp.localy=i['y']
				var obj={"x":i['x'],"y":i['y']}
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
				var obj={"x":i['x'],"y":i['y']}
				_obj.add_child(temp)
				mapData[str(i['x'],",",i['y'])]=temp
		file.close()
		print(mapData)
	else:
		print('文件不存在')	
		pass
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
	
func addObj2Other(obj):
	_obj.add_child(obj)
	pass	

func addObj2Item(obj):
	_obj.add_child(obj)
	
func addObj(obj):
	_obj.add_child(obj)
	
func addCoin(m,_coin=1):
	pass

func addScore(_position,_score=100):
	var temp=score.instance()
	temp.rect_position=position
	temp.score=200
	_obj.add_child(temp)
	pass

func getMario():
	return marioList
		
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
