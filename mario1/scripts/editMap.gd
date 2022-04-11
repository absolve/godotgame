extends Node2D

"""
地图显示砖块，箱子
参考资料(关于碰撞) https://developer.ibm.com/technologies/javascript/tutorials/wa-build2dphysicsengine/
"""
const blockSize=32  #方块的大小
const minWidthNum=20  #一个屏幕宽20块
const heightNun=15

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

var debug=true
var isPress=false #编辑时是否按下鼠标
var mapWidthSize=20  #地图宽度 
#var enemyList=[] #敌人列表
#var specialEntrance=[] #特殊入口 水管和树的入口
var currentLevel  #文件数据
var path="res://levels/1-1.json"
var mapDir="res://levels"	#内置地图路径
var currentMapWidth=0 #当前地图的宽度
var bg="overworld" #overworld   castle underwater
var time=400 #时间
var allTiles=[]  #所有方块的集合
var bgTiles=[]   #单独背景方块
var marioPos={} #mario地图出生地
var selectItem='' #选择的item 名字
var selectItemType='' #选择的item类型'
var state=constants.empty
var selectedItem={'x':-1,'y':-1}	#编辑选中方块
#var delList=[] #删除列表
var timer=0
#var tick=2*60
var nextStatus=constants.empty
#var lastMarioXPos=0  #用来标记mario进入城堡是x位置
#var castleFlagObj=null #城堡旗帜  只有一个
#var checkPoint=[] #检查点 用于判断马里奥死亡后重新复活的位置
var marioDeathPos={'x':-1,'y':-1} #保存死亡时的位置
var music="" #背景音乐
#var screenbrick=[] #当前屏幕方块
var winWidth  #窗体大小
var winHeight
#var subLevel="" #子关卡 是否从水管或者树里面出来
#var pipeIndex=0 #当前水管入口的索引


var mode="edit"  #game正常游戏  edit编辑  test测试  show展示
onready var _brick=$brick
onready var _bg=$bg
onready var camera=$Camera2D
onready var _itemList=$layer/Control/tab/map/vbox/itemList
onready var _tab=$layer/Control/tab
onready var _itemAttr=$layer/Control/tab/map/vbox/attribute
onready var _toolBtn=$layer/Control/toolBtn
onready var _saveDialog=$layer/FileDialog
onready var _mapWidth=$layer/Control/tab/common/vbox/mapWidth
onready var _time=$layer/Control/tab/common/vbox/time
onready var _background=$layer/Control/tab/common/vbox/background
onready var _music=$layer/Control/tab/common/vbox/music
onready var _spriteSet=$layer/Control/tab/common/vbox/spriteset
onready var _marioList=$mario
onready var _brickList=$brick
onready var _bulletList=$bullet
onready var _itemsList=$item
onready var _otherobjList=$otherObj
onready var _enemyList=$enemy
onready var _loadDiaglog=$layer/loadDialog
onready var _title = $title
onready var _bgList=$background
onready var _poleList=$pole
onready var _fps=$layer/fps
onready var _collisionList=$collision


func _ready():
	_itemList.connect("itemSelect",self,'selectItem')
	Game.setMap(self)
#	Game.connect("stateChange",self,'stateChange')
#	Game.connect("stateFinish",self,'stateFinish')
#	Game.connect("flagEnd",self,"flagEnd")
#	Game.connect("timeOut",self,"timeOut")
#	Game.connect("hurryup",self,"hurryup")
#	Game.connect("invincibleFinish",self,"invincibleFinish")
	winWidth= ProjectSettings.get_setting("display/window/size/width")
	winHeight=ProjectSettings.get_setting("display/window/size/height")
	print("winHeight",winHeight)
	
	if mode=='edit':
		_bg.hide()
		_title.hide()
		pass
	elif mode=='game':
#		_bg.show()
#		_tab.hide()
#		_toolBtn.hide()	
##		loadMapFile("res://levels/test7.json")
#		findMapFile()
#		_title.setTime(time)
#		_title.startCountDown()
#		_title.setScore(Game.playerData['score'])
#		_title.setCoin(Game.playerData['coin'])
#		_title.setLevel(Game.playerData['level'])
#		subLevel=Game.playerData['subLevel']
#
#		if subLevel=='' && marioDeathPos['x']!=-1:
#			print("marioDeathPos['x']",marioDeathPos['x'])
#			checkPoint.sort_custom(self,'sort')
#			var temp=null
#			for i in checkPoint:
#				if marioDeathPos['x']>=i['x']:
#					temp=i
#					continue
#			if temp!=null: #设置复活点
#				for i in _marioList.get_children():
#					i.position.x=temp['x']
#					i.position.y=temp['y']
#					pass
#				#设置摄像机位置
#				print("temp['x']",temp['x'])
#				camera.position.x=temp['x']
#				camera.position.x-=winWidth/2
#				_bg.rect_position.x=camera.position.x
#				initEnemy()	#初始化当前画面的敌人
##				state=constants.startState
#		else:
#			if subLevel!='':
#				for i in range(specialEntrance.size()): #找到这个特殊出口
#					if specialEntrance[i]['pipeNo']==subLevel:
#						pipeIndex=i
#						break
#				if specialEntrance[pipeIndex].pipeType==constants.pipeOut:
#					for i in _marioList.get_children():
#						i.position.x=specialEntrance[pipeIndex]['x']*blockSize
#						i.position.y=specialEntrance[pipeIndex]['y']*blockSize+\
#								blockSize+i.getSizeY()/2
#						i.status=constants.pipeOut
##						print(i.position.y)
##				print(specialEntrance[pipeIndex]['y']*blockSize+blockSize)				
#				camera.position.x=specialEntrance[pipeIndex]['x']*blockSize
#				camera.position.x-=int(winWidth/3)
#				_bg.rect_position.x=camera.position.x
#				initEnemy()	#初始化当前画面的敌人
##				state=constants.startState
#				pass
#			else:	
#				initEnemy()	#初始化当前画面的敌人	
##				state=constants.startState
#		print("checkPoint",checkPoint)	
#		state=constants.startState
#
#		if time<100:
#			SoundsUtil.isLowTime=true
#		SoundsUtil.playBgm()
		pass	
	elif mode=='test':
		pass
	elif mode=='show':	
		_bg.show()
		_tab.hide()
		_toolBtn.hide()	
		_title.hideTime()
		pass
#	print(camera.get_camera_position().y)	
#	print(_marioList.get_children())
#	findMapFile()
#	print(get_viewport().size.x)
#	print(camera.get_camera_screen_center().x)
#	set_physics_process(false)
	pass

func findMapFile():
	var dir = Directory.new()
	if dir.file_exists(mapDir+'/'+Game.playerData['level']+".json"):
		print("ok")
		loadMapFile(mapDir+'/'+Game.playerData['level']+".json")
	else:
		printerr("文件不存在")
	pass

#载入文件
func loadMapFile(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		currentLevel= parse_json(file.get_as_text())
		mapWidthSize=int(currentLevel['mapSize'])
		time =int(currentLevel['time'])
		if currentLevel['bg']=="overworld":
			_bg.color=Color(Game.backgroundcolor[0])
		elif currentLevel['bg']=="castle":
			_bg.color=Color(Game.backgroundcolor[1])
		elif currentLevel['bg']=="underwater":	
			_bg.color=Color(Game.backgroundcolor[2])
		
		_mapWidth.setValue(str(mapWidthSize))
		_time.setValue(str(currentLevel['time']))
		_background.setValue(str(currentLevel['bg']))
		_music.setValue(str(currentLevel['music']))
		music=str(currentLevel['music'])
		SoundsUtil.bgm=music
		SoundsUtil.isLowTime=false
		
		var pos = currentLevel['marioPos']
		if !pos.empty():  #添加mario
			if mode=='game' ||  mode=='show':
				var temp=mario.instance()
				temp.position.x=pos['x']*blockSize+blockSize/2
				temp.position.y=pos['y']*blockSize+blockSize/2
				temp.big=Game.playerData['mario']['big']
				temp.fire=Game.playerData['mario']['fire']
				_marioList.add_child(temp)
		
		marioPos=pos
		if mode=='edit':
			allTiles.clear()
			bgTiles.clear()
			
		for i in currentLevel['data']:
			if i['type'] =='brick':
				if mode=='edit':
					allTiles.append(i)
#				else:	
#					var temp=brick.instance()
#					temp.spriteIndex=i['spriteIndex']
#					temp.position.x=i['x']*blockSize+blockSize/2
#					temp.position.y=i['y']*blockSize+blockSize/2
#					var obj={"x":i['x'],"y":i['y']}
#					if checkTile(obj):
#						print(obj,' has one brick')
#					else:
#						_brick.add_child(temp)
				pass
			elif i['type']=='box':
				if mode=='edit':
					allTiles.append(i)
#				else:	
#					var temp=box.instance()
#					temp.spriteIndex=i['spriteIndex']
#					temp.position.x=i['x']*blockSize+blockSize/2
#					temp.position.y=i['y']*blockSize+blockSize/2
#					temp.content=i['content']
##					temp._visible=i['visible']
#
#					if typeof(i['visible'])==TYPE_BOOL:
#						temp._visible=i['visible']
#					elif typeof(i['visible'])==TYPE_STRING:
#						if i['visible']=="false"||i['visible']=="f":
#							temp._visible=false
#						else:	
#							temp._visible=true
##					print(temp._visible)
#					var obj={"x":i['x'],"y":i['y']}
#					if checkTile(obj):
#						print(obj,' has one box')
#					else:
#						_brick.add_child(temp)
			elif i['type']=='goomba' || i['type']=='koopa'||\
					i['type']==constants.plant:	
				if mode=='edit':
					allTiles.append(i)
#				else:
#					i['init']=false
#					enemyList.append(i)
##					addEnemy(i)
#					pass	
			elif i['type']=='pipe':
				if mode=='edit':
					allTiles.append(i)
#				else:	
#					var temp=pipe.instance()
#					temp.spriteIndex=i['spriteIndex']
#					temp.position.x=i['x']*blockSize+blockSize/2
#					temp.position.y=i['y']*blockSize+blockSize/2
#					temp.rotate=int(i['rotate'])
#					if i.has('pipeType'):
#						temp.pipeType=i['pipeType']
#					if i.has('pipeNo'):	
#						temp.pipeNo=i['pipeNo']
#					if i.has("dir"):
#						temp.dir=i['dir']
#					var obj={"x":i['x'],"y":i['y']}
#					if checkTile(obj):
#						print(obj,' has one pipe')
#					else:
#						if i.has('pipeType')&&i['pipeType']!=constants.empty&&i['pipeType']!='':
#							specialEntrance.append(i)
#						_brick.add_child(temp)
			elif i['type']=='bg':	
				if mode=='edit':
					bgTiles.append(i)
#				else:
#					var temp=background.instance()	
#					temp.spriteIndex=i['spriteIndex']
#					temp.position.x=i['x']*blockSize+blockSize/2
#					temp.position.y=i['y']*blockSize+blockSize/2
#					var obj={"x":i['x'],"y":i['y']}
#					if checkBgTile(obj):
#						print(obj,' has one bg')
#					else:	
#						_bgList.add_child(temp)
			elif  i['type']=='flag':  #旗杆
				if mode=='edit':
					allTiles.append(i)
#				else:
#					var temp = pole.instance()
#					temp.position.x=i['x']*blockSize+blockSize/2
#					temp.position.y=i['y']*blockSize+blockSize/2
#					temp.poleLen=int(i['len'])
#					var obj={"x":i['x'],"y":i['y']}
#					if checkTile(obj):
#						print(obj,' has one pole')
#					else:	
#						_poleList.add_child(temp)		
			elif  i['type']=='collision':
				if mode=='edit':
					allTiles.append(i)
#				else:
#					if i['value']=='checkPoint':
#						checkPoint.append({"x":i['x']*blockSize+blockSize/2
#									,"y":i['y']*blockSize+blockSize/2})
#						pass
#					else:	
#						var temp=collision.instance()
#						temp.position.x=i['x']*blockSize+blockSize/2
#						temp.position.y=i['y']*blockSize+blockSize/2
#						temp.type=i['value']
#						var obj={"x":i['x'],"y":i['y']}
#						if checkTile(obj):
#							print(obj,' has one collision')
#						else:
#							_collisionList.add_child(temp)	
			elif i['type']=='castleFlag':	
				if mode=='edit':
					allTiles.append(i)
#				else:
#					if castleFlagObj==null:
#						var temp=castleFlag.instance()
#						temp.position.x=i['x']*blockSize+blockSize/2
#						temp.position.y=i['y']*blockSize+blockSize/2
#						var obj={"x":i['x'],"y":i['y']}
#						if checkTile(obj):
#							print(obj,' has one castleFlag')
#						else:	
#							castleFlagObj=temp
#							_collisionList.add_child(temp)		
			elif i['type']=='coin':
				if mode=='edit':
					allTiles.append(i)
#				else:
#					var temp=bigCoin.instance()
#					temp.position.x=i['x']*blockSize+blockSize/2
#					temp.position.y=i['y']*blockSize+blockSize/2
#					var obj={"x":i['x'],"y":i['y']}		
#					if checkTile(obj):
#						print(obj,' has one coin')
#					else:	
#						_itemsList.add_child(temp)												
		file.close()
	else:
		print('文件不存在')	
		pass
	pass


#保存到文件
func save2File(fileName):
	var data={
		"mapSize":_mapWidth.getValue(),
		"bg":_background.getValue(),
		"music":_music.getValue(),
		'time':_time.getValue(),
		'marioPos':marioPos,
		'data':allTiles+bgTiles,
	}
#	print(data)
	var file = File.new()
	file.open(fileName, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	pass

#初始化当前画面中的敌人
#func initEnemy():
#	print(camera.position.x)
#	for e in range(enemyList.size()):
#		if enemyList[e]['init']:
#			continue
#		if enemyList[e].x*blockSize+blockSize/2>camera.position.x&& \
#			enemyList[e].x*blockSize+blockSize/2<camera.position.x+winWidth:
#				enemyList[e]['init']=true
#				addEnemy(enemyList[e])
#	pass

#添加敌人
#func addEnemy(obj:Dictionary):
#	print("addEnemy",obj)
#	print("camera ",camera.position.x)
#	if obj.type==constants.goomba:
#		var temp =goomba.instance()
#		temp.position.x=obj['x']*blockSize+blockSize/2
#		temp.position.y=obj['y']*blockSize+blockSize/2
##		temp.offsetX=obj['offsetX']
##		temp.offsetY=obj['offsetY']
#		temp.spriteIndex=obj['spriteIndex']
#		temp.dir=obj['dir']
#		_enemyList.add_child(temp)
#		pass
#	elif obj.type==constants.plant:
#		var temp=plant.instance()
#		temp.position.x=obj['x']*blockSize+blockSize/2
#		temp.position.y=obj['y']*blockSize+blockSize/2
#		temp.offsetX=obj['offsetX']
#		temp.offsetY=obj['offsetY']
#		temp.spriteIndex=obj['spriteIndex']
#		_enemyList.add_child(temp)
#	elif obj.type==constants.koopa:
#		var temp =koopa.instance()	
#		temp.position.x=obj['x']*blockSize+blockSize/2
#		temp.position.y=obj['y']*blockSize+blockSize/2
#		temp.spriteIndex=obj['spriteIndex']
#		temp.dir=obj['dir']
#		_enemyList.add_child(temp)
#
#	pass

func checkTile(obj):
	var flag=false		
	for i in allTiles:
		if i["x"]==obj["x"]&&i["y"]==obj["y"]:	
			flag=true
			break
	return 	flag		
		
func checkBgTile(obj):
	var flag=false		
	for i in bgTiles:
		if i["x"]==obj["x"]&&i["y"]==obj["y"]:	
			flag=true
			break
	return 	flag	

#检查点击的位置是否有这个方块 背景和其他物体可以重复
func checkHasItem(pos,selectType):
	print(selectType)
	var x = pos.x
	var y=pos.y
	var indexX = int(x)/(blockSize)
	var indexY=int(y)/(blockSize)
	var flag=false
	if selectType=='bg':
		for i in bgTiles:
			if i["x"]==indexX&&i["y"]==indexY:
				flag=true
				break
		pass
	elif selectType=='del':
		for i in bgTiles+allTiles:
			if i["x"]==indexX&&i["y"]==indexY:
				flag=true
				break			
	else:	
		for i in allTiles:
			if i["x"]==indexX&&i["y"]==indexY:
				flag=true
				break	
#	print(flag)
	return 	flag


#添加方块信息
func addItem(type,key,pos):
	if type=='del':
		return
	if not constants.tilesAttribute.has(key):
		print('item type error ',key)
		return	
	if key=='mario':
		marioPos={'x':pos.x,'y':pos.y}
		return
	var g=constants.tilesAttribute[key].duplicate()
	g.x=pos.x
	g.y=pos.y
	print(type,key,pos)
	if type=='bg':
		bgTiles.append(g)	
	else:	
		allTiles.append(g)			


#删除一个方块
func delItem(pos:Vector2):
	var indexX = int(pos.x)/(blockSize)
	var indexY=int(pos.y)/(blockSize)
	var temp = {"x":indexX,"y":indexY}
	for i in range(allTiles.size()):
		if allTiles[i]["x"]==indexX&&allTiles[i]["y"]==indexY:
			allTiles.remove(i)
			break
	for i in range(bgTiles.size()):
		if bgTiles[i]["x"]==indexX&&bgTiles[i]["y"]==indexY:
			bgTiles.remove(i)
			break

#选择方块
func selectItem(type,itemName):
#	print(index,itemName)
	selectItemType=type
	selectItem=itemName


func getItemPos(pos:Vector2):
	return {
		'x':int(pos.x)/blockSize,
		'y':int(pos.y)/blockSize
	}


#获取属性
func getItemAttr(pos:Vector2):
	var indexX = int(pos.x)/(blockSize)
	var indexY=int(pos.y)/(blockSize)
	for i in allTiles:
		if i["x"]==indexX&&i["y"]==indexY:
#			var attr=constants.tilesAttribute[i.type]
			_itemAttr.clearAttr()
			for y in i.keys():
				_itemAttr.addAttr(y,i[y])
			#保存选中数据
			selectedItem["x"]=indexX	
			selectedItem["y"]=indexY
			break
	pass

#func addObj2Brick(obj):
#	_brickList.add_child(obj)

#func addObj2Item(obj):
#	_itemsList.add_child(obj)

#func addObj2Other(obj):
#	_otherobjList.add_child(obj)


#func addObj2Bullet(obj):
#	_bulletList.add_child(obj)
#	pass

#func getBulletCount(_id):
#	var num=0
#	for i in _bulletList.get_children():
#		if i.type==constants.fireball&&i.status==constants.fly:
#			num+=1
#	return num

#获取砖块
func getBrick(x,y):
	for i in _brick.get_children():
		if i.position.x/blockSize==int(x/blockSize)\
			&&i.position.y/blockSize==int(y/blockSize):
			return i
	pass

#func stateChange():
#	print('stateChange')
#	state=constants.stateChange
#	for i in _itemsList.get_children():
#		i.pause()
#	for i in _enemyList.get_children():
#		i.pause()
#	pass

#func stateFinish():
#	print("stateFinish")	
#	for i in _itemsList.get_children():
#		i.resume()
#	for i in _enemyList.get_children():
#		i.resume()	
#	state=constants.startState	
#	pass	
	
#func flagEnd():
#	for i in _marioList.get_children():
#		i.setwalkingToCastle()
#	pass	

#游戏结束	
#func gameEnd():
#	print("gameEnd")
#	pass	

#重新开始
#func gameRestart():
#	print("gameRestart")
#	Game.playerData['score']=_title.score
#	Game.playerData['coin']=_title.coinNum
#	Game.playerData['lives']-=1
#	Game.playerData['subLevel']=''
#	Game.playerData['mario']['big']=false
#	Game.playerData['mario']['fire']=false
#	var temp=menu.instance()
#	temp.marioDeathPos=marioDeathPos
#	temp.status=constants.gameRestart
#	queue_free()
#	set_process_input(false)
#	get_tree().get_root().add_child(temp)
#	set_process_input(true)
#	pass

#func gameNextLevel():
#	print("gameNextLevel")
#	var temp=menu.instance()
#	temp.isgameover=true
#	Game.playerData['score']=_title.score
#	Game.playerData['coin']=_title.coinNum
#	Game.playerData['subLevel']=''
##	Game.playerData['lives']-=1
#	queue_free()
#	set_process_input(false)
#	get_tree().get_root().add_child(temp)
#	set_process_input(true)
	
#func marioAndEnemy(m,e):
#	if m.hurtInvincible:	
#		pass
#	elif m.invincible:
#		if m.xVel>=0:	
#			e.startDeathJump(constants.right)
#		else:
#			e.startDeathJump(constants.left)	
#		addScore(m)	
#		SoundsUtil.playShoot()
#		pass
#	elif m.big:
#		if e.status==constants.shell||e.status==constants.revive:
#			if m.xVel<0:
#				e.dir=constants.left
#			else:
#				e.dir=constants.right
#			if m.position.x>e.position.x:
#				e.position.x=m.getLeft()-e.getSize()-1
#			else:
#				e.position.x=m.getRight()+e.getSize()+1	
#			e.startSliding()
#			SoundsUtil.playShoot()	
#		else:	
#			m.big2Small()
#			SoundsUtil.playBig2small()
#	else:
#		if  e.status==constants.shell||e.status==constants.revive:
#			if m.xVel<0:
#				e.dir=constants.left
#			else:
#				e.dir=constants.right
#			if 	m.position.x>e.position.x:
#				e.position.x=m.getLeft()-e.getSize()-1
#			else:
#				e.position.x=m.getRight()+e.getSize()+1		
#			e.startSliding()	
#			SoundsUtil.playShoot()
#		else:
#			SoundsUtil.stopBgm()	
#			SoundsUtil.stopSpecialBgm()
#			m.startDeathJump()		
#			SoundsUtil.playDeath()
#	pass

#func marioJumpOnEnemy(m,e):
#	if m.invincible:
#		if m.position.x<e.position.x:	
#			e.startDeathJump(constants.right)
#		else:
#			e.startDeathJump(constants.left)	
#		addScore(m)	
#		SoundsUtil.playStomp()	
#	else:
#		if m.yVel>=0:
#			m.yVel=-240
#			if m.xVel>0:
#				m.xVel+=20
#			elif m.xVel<0:
#				m.xVel-=20	
#			m.position.y=e.position.y-e.getSizeY()/2-m.getSizeY()/2+1#位置调整		
#			e.jumpedOn()
#			addScore(m)
#			SoundsUtil.playStomp()	
#	pass

#mario跟物品
#func marioAndItem(m,i):
#	if i.type==constants.mushroom:
#		i.queue_free()
#		m.small2Big()
#		SoundsUtil.playMushroom()
#		addScore(m,5000)
#	elif i.type==constants.fireflower:
#		i.queue_free()
#		if m.big:
#			m.big2Fire()
#		else:
#			m.small2Big()	
#		addScore(m,5000)
#		SoundsUtil.playMushroom()
#	elif i.type==constants.star:
#		i.queue_free()
#		m.setInvincible()
#		addScore(m,5000)
#		SoundsUtil.stopBgm()
#		SoundsUtil.playSpecialBgm()
#	elif i.type==constants.mushroom1up:	
#		i.queue_free()
#		addLive(m)
#		SoundsUtil.playItem1up()
#	elif i.type==constants.bigCoin:
#		i.queue_free()
#		SoundsUtil.playCoin()
#		_title.addScore(200)
#		addCoin(m)	
#	pass

#mario掉出屏幕
#func marioOutYPos():
##	stateChange()
#	for i in _itemsList.get_children():
#		i.pause()
#	for i in _enemyList.get_children():
#		i.pause()
#	state=constants.empty	
#	SoundsUtil.stopBgm()
#	SoundsUtil.stopSpecialBgm()
#	SoundsUtil.playDeath()
#	yield(SoundsUtil.death,"finished")
#	state=constants.stateChange
#	pass

#添加分数
#func addScore(m,_score=100):
#	var temp=score.instance()
#	temp.setPos(Vector2(m.position.x,m.position.y-45))
#	temp.setScore(_score)
#	_title.addScore(_score)
#	_otherobjList.add_child(temp)
#	pass	

#func addLive(m,_live="1up"):
#	var temp=score.instance()
#	temp.setPos(Vector2(m.position.x,m.position.y-45))
#	temp.setScore(_live)
#	Game.playerData['lives']+=1
#	_otherobjList.add_child(temp)

#func addCoin(m,_coin=1):
#	_title.addCoin(_coin)

#func getMario():
#	return _marioList.get_children()
#	pass
	
#更新旗帜和烟花	
#func updateFlagAndFireworks():
#	if castleFlagObj!=null:
#		castleFlagObj.rising()
#		yield(Game,"flagRising")
#		for y in range(20):
#			yield(get_tree(),"idle_frame")
#	var num=str(_title.lastTime)
#	var digits=num[num.length()-1]
#	print(digits)
##	digits="5"
#	if digits in ["1","3","6"]: #放烟花个数
#		for i in range(digits.to_int()):
#			SoundsUtil.playBoom()
#			var temp=firework.instance()
#			temp.position.x=lastMarioXPos
#			_otherobjList.add_child(temp)
#			yield(temp.ani,"animation_finished")
#			_title.addScore(300)  #每朵烟花200
#			for y in range(15):
#				yield(get_tree(),"idle_frame")
#			pass
#		pass
#	timer=0	
#	tick=150
#	state=constants.gameIdle
#	nextStatus=constants.nextLevel
#	pass

#超时
#func timeOut():
#	for i in _marioList.get_children():
#		if i.status==constants.poleSliding||i.status==constants.sitBottomOfPole\
#			||i.status==constants.walkingToCastle:
#				continue
#		i.startDeathJump()
#	SoundsUtil.stopBgm()
#	SoundsUtil.stopSpecialBgm()
#	SoundsUtil.playDeath()
#	pass

#func hurryup():
#	print("hurryup")
#	SoundsUtil.playLowTime()
#	pass	

#游戏暂停	
#func gamePause():
#
#	pass	

#func playLevelEnd():
#	SoundsUtil.playLevelend()
#	pass

#func invincibleFinish():
#	SoundsUtil.stopSpecialBgm()
#	SoundsUtil.playBgm()

func sort(a,b):
	if a['x']>b['x']:
		return true
	else:
		return false
	pass

#获取当前屏幕中方块和后一个屏幕	
#func getScreenBrick()->Array:
#	var list=[]
##	screenbrick=[]
#	for i in _brickList.get_children():	
#		if i.position.x>camera.position.x-i.getSize() &&\
#		  i.position.x<camera.position.x+winWidth*2:
#			list.append(i)
#	return list

#载入地图到子关卡
#func loadSubLevelMap(level,subLevel):
#	Game.playerData['score']=_title.score
#	Game.playerData['coin']=_title.coinNum
#	Game.playerData['level']=level
#	Game.playerData['subLevel']=subLevel
#	for i in _marioList.get_children(): #保存mario的信息
#		saveMarioInfo(i)
#	SoundsUtil.stopBgm()
#	SoundsUtil.stopSpecialBgm()
##	get_tree().reload_current_scene()
#	var scene=load("res://scenes/map.tscn")
#	var temp=scene.instance()
#	temp.mode="game"
#	queue_free()
#	set_process_input(false)
#	get_tree().get_root().add_child(temp)
#	set_process_input(true)
#	pass

#判断mario在水管上是否按下按键	
#func checkInputInPipe(p):
#	var flag=false
#	if p.dir==constants.down:
#		if Input.is_action_pressed("ui_down"):
#			flag=true		
#	elif p.dir==constants.left:
#		if Input.is_action_just_pressed("ui_left"):
#			flag=true
#	elif p.dir==constants.right:
#		if Input.is_action_just_pressed("ui_right"):
#			flag=true
#	return flag

#mario进入水管
#func marioEnterPipe(m,p):
#	SoundsUtil.playPipe()
#	state=constants.nextSublevel
#	for i in range(specialEntrance.size()):
#		if specialEntrance[i]['pipeNo']==p['pipeNo']:
#			pipeIndex=i
#			break
#	if p.dir==constants.down:
#		m.status=constants.pipeIn
#	elif p.dir==constants.left||p.dir==constants.right:
#		m.status=constants.walkInPipe
#		m.dir=p.dir
#	print("marioEnterPipe")	

#检查水管的位置判断是否可以进入
#func checkPipePos(m,p):
#	if p.dir==constants.left||p.dir==constants.right:
#		return true
#	var x=p.position.x-blockSize/2
#	if m.position.x<x+blockSize/3 && m.position.x>x-blockSize/3:
#		return true
#	else:
#		return false	
#	pass

#保存mario的状态
#func saveMarioInfo(m):
#	print("保存数据")
#	Game.playerData['mario']['big']=m.big
#	Game.playerData['mario']['fire']=m.fire
	
func _update(delta):
	if mode=='edit':
		pass
	elif mode=='game':
#		if state==constants.startState:
#			#清除超过屏幕的敌人
##			var pos=camera.get_camera_position()
#			for i in _enemyList.get_children():
#				if i.position.x+i.getSize()/2<=camera.position.x:
#					i.queue_free()
#				elif i.position.x-i.getSize()/2>camera.position.x+winWidth*1.6:
#					i.queue_free()
#				if i.position.y-i.getSizeY()/2>winHeight:
#					i.queue_free()		
#
#			for i in _bulletList.get_children():
#				if i.position.x+i.getSize()/2<=camera.position.x:
#					i.queue_free()
#				elif i.position.x-i.getSize()/2>camera.position.x+winWidth:
#					i.queue_free()
#				if i.position.y+i.getSizeY()/2>=winHeight:
#					i.queue_free()	
#
#			for i in _marioList.get_children():
#				if i.position.y>winHeight+i.getSizeY()/2:
#					i.dead=true
#					marioOutYPos()
#			_title._update(delta)
#
#			for i in _marioList.get_children():
#				i._update(delta)
#			for i in _brickList.get_children():
#				i._update(delta)
#			for i in _bulletList.get_children():
#				i._update(delta)
#			for i in _itemsList.get_children():
#				i._update(delta)
#			for i in _otherobjList.get_children():
#				i._update(delta)
#			for i in _enemyList.get_children():
#				i._update(delta)
#			for i in _poleList.get_children():
#				i._update(delta)
#			for i in _collisionList.get_children():
#				i._update(delta)
#
#			screenbrick=getScreenBrick() #获取当前屏幕的方块 两个屏幕大小
#
#			for i in _marioList.get_children():  #mario跟方块
#				var onFloor=false
#				if i.status==constants.pipeOut: #从水管里面出来
#					if specialEntrance[pipeIndex].pipeType==constants.pipeOut:
#						if i.getBottom()<specialEntrance[pipeIndex].y*blockSize:
##							state=constants.startState
#							i.status=constants.stand
#					continue		
#				for y in screenbrick: #排除不在当前屏幕里的方块
##					if y.position.x+y.getSize()/2<pos.x ||\
##						y.position.x-y.getSize()/2>pos.x+get_viewport().size.x:
##							continue
##					if i.getRect().encloses(y.getRect()):#完全叠一起
##						continue
#					if i.getRect().intersects(y.getRect(),true):	#包括边缘
#						y.collisionShow=true
#						if i.status==constants.poleSliding:
#							i.setSitBottom()	
#						var dx=(y.position.x-i.position.x)/y.getSize()/2
#						var dy=(y.position.y-i.position.y)/y.getSizeY()/2
#						if abs(abs(dx)-abs(dy))<.1:  #两边重叠
##							print('abs(abs(dx)-abs(dy))<.1')
#							if y.type==constants.box && !y._visible:
#								continue
#							if dx<0:
#								i.position.x=y.getRight()+i.getSize()/2
#							else:
#								i.position.x=y.getLeft()-i.getSize()/2	
#
##							if abs(abs(y.position.y-i.position.y)-(y.getSizeY()/2+i.getSizeY()/2))>=1:
##								if i.status==constants.jump:
##									if dx<0 && i.dir==constants.left:
##										i.xVel=0
##									elif dx>0 && i.dir==constants.right:
##										i.xVel=0		
#							pass
#						elif abs(dx)>abs(dy): #左右的碰撞
#							if y.type==constants.box && !y._visible:
#								continue
#							if y.type==constants.pipe && y.pipeType==constants.pipeIn:
#								if checkInputInPipe(y) && checkPipePos(i,y):
#									marioEnterPipe(i,y)
#									pass	
#							if dx<0:
##								if i.dir==constants.left:
#								i.xVel=0
#								i.position.x=y.getRight()+i.getSize()/2
#							else:
##								if i.dir==constants.right:
#								i.xVel=0
#								i.position.x=y.getLeft()-i.getSize()/2
#						else: #上下的碰撞
#							if dy<0:  #下方	
#								#这个非常的接近边缘就不判断	
#								if 	abs(abs(y.position.x-i.position.x)-(y.getSize()/2+i.getSize()/2))>=1:
#									if y.type==constants.box && i.yVel<0:
#										if y.status==constants.resting:
#											if y.isDestructible() && i.big:
#												y.destroy=true	
#											elif y.isDestructible():
#												SoundsUtil.playBrickHit()	
#											y.startBumped()		
#										i.yVel=100			
#							else: #上方
#								if y.type==constants.box && !y._visible:
#									continue
#								if y.type==constants.pipe && y.pipeType==constants.pipeIn:
#									if checkInputInPipe(y) && checkPipePos(i,y):
#										marioEnterPipe(i,y)
#										pass
#								if i.yVel>=0:  #掉落的情况
#									if i.position.x>=y.position.x && abs(i.getLeft()-y.getRight())>=4:
#										i.yVel=0
#										i.position.y=y.getTop()-i.getSizeY()/2	
#										onFloor=true	
#									elif i.position.x<y.position.x && abs(i.getRight()-y.getLeft())>=4:
#										i.yVel=0
#										i.position.y=y.getTop()-i.getSizeY()/2	
#										onFloor=true	
#								elif i.yVel<0:
#									pass
#								else:
#									i.yVel=0
#									i.position.y=y.getTop()-i.getSizeY()/2	
#									onFloor=true		
#					else:
#						y.collisionShow=false
#				i.isOnFloor=onFloor	
#
#
#			for i in _itemsList.get_children():  #物品的判断
#				for y in screenbrick:
#					if i.status==constants.growing: #排除在增长的状态
#						continue
#					if i.getRect().intersects(y.getRect(),true):
#						var dx=(y.position.x-i.position.x)/y.getSize()/2
#						var dy=(y.position.y-i.position.y)/y.getSize()/2
#						if abs(abs(dx)-abs(dy))<.1:  #两边重叠
#							if dy<0:
#								i.yVel=8
#							else:
#								if i.yVel>0:
#									i.yVel=0
#								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
#						elif abs(dx)>abs(dy): #左右的碰撞
#							i.xVel=0
#							if dx<0:
#								i.position.x=y.position.x+y.getSize()/2+i.getSize()/2
#								i.turnRight()
#							else:
#								i.position.x=y.position.x-y.getSize()/2-i.getSize()/2
#								i.turnLeft()
#						else: #上下的碰撞
#							if dy<0:  #下方
##								i.yVel=8
#								pass
#							else:
#								if i.yVel>0:  #掉落的情况
#									i.yVel=0
#								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
#								if y.type==constants.box && y.status==constants.bumped:
#									if i.type==constants.mushroom:	
#										if i.position.x<=y.position.x && i.xVel>0:
#											i.xVel=-abs(i.xVel)
#											i.yVel=-80
#										elif i.position.x>y.position.x && i.xVel<0:
#											i.xVel=abs(i.xVel)
#											i.yVel=-80
#									elif i.type==constants.bigCoin:
#										SoundsUtil.playCoin()
#										addCoin(i)
#										y.queue_free()
#										pass
#								if i.status==constants.jumping:
#									i.yVel=-i.jumpSpeed
#
#				pass
#
#
#			for i in _enemyList.get_children():  #敌人跟方块
#				if i.status==constants.dead||i.status==constants.deadJump:
#					continue
#				var onFloor=false	
#				for y in screenbrick:
#					if i.type==constants.plant:
#						continue
#					if i.getRect().intersects(y.getRect(),true):
#						var dx=(y.position.x-i.position.x)/y.getSize()/2
#						var dy=(y.position.y-i.position.y)/y.getSizeY()/2
#						if abs(abs(dx)-abs(dy))<.1:  #两边重叠	
#							if dy<0:  #下方
#								if i.position.x>=y.position.x && abs(i.getLeft()-y.getRight())>=4:	
#									i.yVel=0
#									i.position.y=y.getTop()-i.getSizeY()/2	
#								elif i.position.x<y.position.x && abs(i.getRight()-y.getLeft())>=4:
#									i.yVel=0
#									i.position.y=y.getTop()-i.getSizeY()/2	
#							else:
#								if i.yVel>=0:  #掉落的情况
#									i.yVel=0
#									onFloor=true
#								if y.type==constants.box&& y.status==constants.bumped:
#									i.startDeathJump()
#									addScore(i)
#								else:		
#									i.position.y=y.position.y-y.getSizeY()/2-i.getSizeY()/2
#							pass
#						elif abs(dx)>abs(dy): #左右的碰撞
#							if dx<0:
#								i.turnRight()
#								i.position.x=y.getRight()+i.getSize()/2
#							else:
#								i.turnLeft()
#								i.position.x=y.getLeft()-i.getSize()/2
#						else: #上下的碰撞
#							if dy<0:  #下方
#								if i.position.x>=y.position.x && abs(i.getLeft()-y.getRight())>=4:	
#									i.yVel=0
#									i.position.y=y.getTop()-i.getSizeY()/2	
#								elif i.position.x<y.position.x && abs(i.getRight()-y.getLeft())>=4:
#									i.yVel=0
#									i.position.y=y.getTop()-i.getSizeY()/2	
#							else:
#								if i.yVel>=0:  #掉落的情况
#									i.yVel=0
#									onFloor=true
#								if y.type==constants.box&& y.status==constants.bumped:
#									i.startDeathJump()
#									addScore(i)
#								else:		
#									i.position.y=y.position.y-y.getSizeY()/2-i.getSizeY()/2
#				i.isOnFloor=onFloor	
#
#			for i in _marioList.get_children(): #mario跟敌人
#				for y in _enemyList.get_children():
#					if y.status==constants.dead||y.status==constants.deadJump:
#						continue
#					if i.getRect().intersects(y.getRect()):
#						var dx=(y.position.x-i.position.x)/y.getSize()/2
#						var dy=(y.position.y-i.position.y)/y.getSizeY()/2
#						if abs(abs(dx)-abs(dy))<.1:  #两边重叠
#							marioAndEnemy(i,y)	
#						elif abs(dx)>abs(dy): #左右的碰撞
#							marioAndEnemy(i,y)		
#						else: #上下的碰撞
#							if dy<0:  #下方
#								marioAndEnemy(i,y)	
#							else:
#								marioJumpOnEnemy(i,y)
#
#			for i in _enemyList.get_children():  #敌人之间的碰撞
#				for y in _enemyList.get_children():
#					if i==y:
#						continue
#					if i.getRect().intersects(y.getRect()):
#						var dx=(y.position.x-i.position.x)/y.getSize()/2
#						var dy=(y.position.y-i.position.y)/y.getSizeY()/2
#						if abs(abs(dx)-abs(dy))<.1:  #两边重叠
#							pass
#						elif abs(dx)>abs(dy): #左右的碰撞					
#							if i.status!=constants.dead&&i.status!=constants.deadJump\
#								&&y.status!=constants.dead&&y.status!=constants.deadJump:
#								if i.status==constants.sliding || y.status==constants.sliding:
#									if y.status!=constants.sliding:
#										if i.xVel>0:
#											y.startDeathJump(constants.right)
#										else:
#											y.startDeathJump(constants.left)
#										addScore(y)	
#										SoundsUtil.playShoot()	
#									elif y.status==constants.sliding:
#										if i.xVel>0:
#											i.startDeathJump(constants.left)
#										else:
#											i.startDeathJump(constants.right)				
#										addScore(i)	
#										SoundsUtil.playShoot()		
#									else:
#										if i.xVel>0:
#											i.startDeathJump(constants.left)
#										else:
#											i.startDeathJump(constants.right)	
#										if y.xVel>0:
#											y.startDeathJump(constants.left)
#										else:
#											y.startDeathJump(constants.right)	
#										addScore(i)		
#										addScore(y)	
#										SoundsUtil.playShoot()		
#									pass
#								else:
#									if dx<0:
#										i.position.x=y.getRight()+i.getSize()/2
#										if i.xVel<0:
#											i.turnDir()	
#										if y.xVel>0:
#											y.turnDir()		
#									else:
#										i.position.x=y.getLeft()-i.getSize()/2
#										if i.xVel>0:
#											i.turnDir()
#										if y.xVel<0:
#											y.turnDir()			
#						else:
#							if i.status!=constants.dead&&i.status!=constants.deadJump\
#								&&y.status!=constants.dead&&y.status!=constants.deadJump:
#								if i.status==constants.sliding:
#									if y.status!=constants.sliding:
#										if i.xVel>0:
#											y.startDeathJump(constants.right)
#										else:
#											y.startDeathJump(constants.left)
#										addScore(y)
#										SoundsUtil.playShoot()		
#
#			for i in _bulletList.get_children():	#子弹跟方块
#				for y in screenbrick:
#					if i.status==constants.boom: #排除在增长的状态
#						continue
#					if i.getRect().encloses(y.getRect()):#完全叠一起
#						continue
#					if i.getRect().intersects(y.getRect(),true):
#						var dx=(y.position.x-i.position.x)/y.getSize()/2
#						var dy=(y.position.y-i.position.y)/y.getSize()/2
#						if abs(abs(dx)-abs(dy))<.1:  #两边重叠
#							if dx<0:
#								if dy>=0:
#									i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
#									if i.status==constants.fly:
#										i.yVel=-i.speed	
#								else:
#									if i.type==constants.fireball &&i.status==constants.fly:
#										i.boom()
#										SoundsUtil.playBoom()		
#							else:
#								if dy>=0:
#									i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
#									if i.status==constants.fly:
#										i.yVel=-i.speed	
#								else:
#									if i.type==constants.fireball&&i.status==constants.fly:
#										i.boom()
#										SoundsUtil.playBoom()			
#								pass
#						elif abs(dx)>abs(dy): #左右的碰撞
#							i.xVel=0
#							if dx<0:
#								if i.type==constants.fireball:
#									i.boom()
#							else:
#								if i.type==constants.fireball:
#									i.boom()
#							SoundsUtil.playBoom()			
#						else: #上下的碰撞
#							if dy<0:  #下方
#								if i.status==constants.fly:
#									i.yVel=i.speed
#							else:
#								i.position.y=y.position.y-y.getSize()/2-i.getSizeY()/2
#								if i.status==constants.fly:
#									i.yVel=-i.speed
#
#
#			for i in _bulletList.get_children():  #子弹跟敌人
#				for y in _enemyList.get_children():
#					if i.type==constants.fireball && i.status==constants.boom: #排除在增长的状态
#						continue
#					if y.status==constants.dead||y.status==constants.deadJump:
#						continue
#					if i.getRect().intersects(y.getRect()):
#						i.boom()
#						if i.xVel>0:
#							y.startDeathJump(constants.right)
#						else:
#							y.startDeathJump(constants.left)	
#						addScore(y)
#						SoundsUtil.playShoot()
#
#
#			for i in _marioList.get_children():  #mario跟物品
#				for y in _itemsList.get_children():
#					if i.getRect().intersects(y.getRect()):
#						marioAndItem(i,y)
#
#			for i in _marioList.get_children(): #mario跟旗杆
#				for y in _poleList.get_children():
#					if y.position.x+y.getSize()/2<camera.position.x ||\
#						y.position.x-y.getSize()/2>camera.position.x+winWidth:
#							continue
#					if i.status==constants.poleSliding||\
#						i.status==constants.walkingToCastle||i.status==constants.sitBottomOfPole:
#						continue
#					if i.getRect().intersects(y.getRect(),true):
#						if i.position.x<y.position.x:
#							i.position.x=y.getLeft()-i.getSize()/2
#							i.startSliding(y.getSize())
#							y.startFall()
#							SoundsUtil.stopBgm()
#							SoundsUtil.stopSpecialBgm()
#							SoundsUtil.playLevelend()
#							if abs(i.position.y-y.position.y)<=50:
#								y.showScore(5000)
#								_title.addScore(5000)
#							elif abs(i.position.y-y.position.y)<=100:
#								y.showScore(2000)
#								_title.addScore(2000)	
#							elif abs(i.position.y-y.position.y)<=150:	
#								y.showScore(1000)
#								_title.addScore(1000)
#							elif abs(i.position.y-y.position.y)<=200:
#								y.showScore(500)
#								_title.addScore(500)	
#							else:
#								y.showScore(200)
#								_title.addScore(200)		
#							_title.stopCountDown()
#						pass		
#					pass
#
#			for i in _marioList.get_children(): #mario跟碰撞体
#				for y in _collisionList.get_children():
#					if y.position.x+y.getSize()/2<camera.position.x ||\
#						y.position.x-y.getSize()/2>camera.position.x+winWidth:
#							continue
#					if i.getRect().intersects(y.getRect(),true):
#						if y.type==constants.castlePos: #正好到了城堡的门口
#							saveMarioInfo(i) #保存一下数据
#							i.queue_free()
#							state=constants.inCastle
#							lastMarioXPos=y.position.x #保存当时的x位置
#							_title.recordLastTime()
#							_title.fastCountDown()
#
#
#			#照相机跟随mario
#			if _marioList.get_child_count()>0:
#				var mario1=_marioList.get_child(0)
#
#				if mario1.position.x-mario1.getSize()/2<camera.position.x:
#					mario1.position.x=camera.position.x+mario1.getSize()/2	
#					if mario1.dir==constants.left:
#						mario1.xVel=0
#				elif mario1.position.x+	mario1.getSize()/2>mapWidthSize*blockSize:
#					mario1.position.x=mapWidthSize*blockSize-mario1.getSize()/2
#					if mario1.dir==constants.right:
#						mario1.xVel=0
#				#前进
#				if mario1.xVel>=0 && mario1.position.x>camera.get_camera_screen_center().x+20&&\
#						camera.position.x <mapWidthSize*blockSize-winWidth:
#					if camera.position.x>mapWidthSize*blockSize-winWidth:
#						camera.position.x=mapWidthSize*blockSize-winWidth
#						_bg.rect_position.x=camera
#					else:
#						camera.position.x+=int(abs(mario1.position.x-camera.get_camera_screen_center().x-20))
#						_bg.rect_position.x=int(camera.position.x)
##					print(camera.position.x)
#
#				#后退		
#				if mario1.xVel<0 && mario1.position.x<camera.get_camera_screen_center().x-40&&\
#					camera.position.x>0:
#					if camera.position.x<0:
#						camera.position.x=0
#						_bg.rect_position.x=0
#					else:		
#						camera.position.x-=int(abs(mario1.position.x-camera.get_camera_screen_center().x+40))
#						_bg.rect_position.x=int(camera.position.x)	
#
#				#根据摄像的移动判断前面位置是否需要添加敌人
#				for e in enemyList:
#					if e['init']:
#						continue
#					if e.x*blockSize+blockSize/2>=camera.position.x+winWidth && \
#						e.x*blockSize+blockSize/2<=camera.position.x+winWidth*1.2:
#							addEnemy(e)
#							e['init']=true
#
#
#			pass
#		elif state==constants.stateChange:
##			var pos=camera.get_camera_position()
#			for i in _marioList.get_children():
#				i._update(delta)
#				if i.dead:
#					if i.position.y>winHeight+i.getSizeY()/2:
##						SoundsUtil.stopBgm()
#						marioDeathPos['x']=i.position.x
#						marioDeathPos['x']
#						i.queue_free()
#						state=constants.gameIdle
#						nextStatus=constants.gameEnd
#						timer=0
##						gameRestart()
#		elif state==constants.inCastle:
#			if _title.currentTime>0:
#				_title._update(delta)
#			else: #升旗 烟花
#				state=constants.nextLevel
#				updateFlagAndFireworks()
#				pass	
#			pass	
#		elif state==constants.gameEnd:
#			pass
#		elif state==constants.nextLevel:
#			for i in _collisionList.get_children():
#				i._update(delta)
#			pass
#		elif state==constants.gameIdle:		
#			timer+=1
#			if timer>tick:
#				if nextStatus==constants.gameEnd:
#					gameRestart()
#				elif nextStatus==constants.nextLevel:	
#					gameNextLevel()
#				elif nextStatus==constants.startState:
#					state=constants.startState
#					playLevelEnd()
#				elif nextStatus==constants.nextSublevel:
#					state=constants.empty
#					loadSubLevelMap(specialEntrance[pipeIndex]['level'],
#					specialEntrance[pipeIndex]['subLevel'])	
#			pass
#		elif state==constants.pause:	
#			pass
#		elif state==constants.nextSublevel:	#mario进入子关卡	
#			for i in _marioList.get_children():
#				i._update(delta)
#				if specialEntrance[pipeIndex].dir==constants.down &&\
#					 i.getTop()>specialEntrance[pipeIndex].y*blockSize+15:
#					tick=40
#					state=constants.gameIdle
#					nextStatus=constants.nextSublevel
#				elif specialEntrance[pipeIndex].dir==constants.left &&\
#					i.getLeft()<specialEntrance[pipeIndex].x*blockSize-15:
#						tick=40
#						state=constants.gameIdle
#						nextStatus=constants.nextSublevel
#				elif specialEntrance[pipeIndex].dir==constants.right &&	\
#					i.getLeft()>specialEntrance[pipeIndex].x*blockSize+15:
#						tick=40
#						state=constants.gameIdle
#						nextStatus=constants.nextSublevel
#			pass
#		elif state==constants.loadSublevel: #从水管或者树里面出现
#			for i in _marioList.get_children():
#				i._update(delta)
#				if specialEntrance[pipeIndex].pipeType==constants.pipeOut:
#					if i.getBottom()<specialEntrance[pipeIndex].y*blockSize:
#						state=constants.startState
#						i.status=constants.stand
			pass	
	elif mode=='show':
		pass
	pass


func _process(delta):
	if debug && mode=="edit": 
		update()
	_fps.set_text(str("fps:",Engine.get_frames_per_second()))	
	_update(delta)
	pass

func _input(event):
	if mode=='edit':
		if _saveDialog.visible||_loadDiaglog.visible:
			return
		if event is InputEventKey:
			if event.is_pressed():
				if (event as InputEventKey).scancode==KEY_LEFT:	
					if camera.position.x>-minWidthNum/2*blockSize:  #前后一半屏幕
						camera.position.x-=10
					pass
				elif (event as InputEventKey).scancode==KEY_RIGHT:	
					if camera.position.x<mapWidthSize*blockSize-minWidthNum/2*blockSize:
						camera.position.x+=10
					pass	
		elif event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and  event.pressed:
				if _tab.is_visible_in_tree()&& _tab.get_rect().has_point(camera.get_local_mouse_position()):
					return
				if _toolBtn.is_visible_in_tree()&&_toolBtn.get_rect().has_point(camera.get_local_mouse_position()):
					return
				isPress=true
				if checkHasItem(get_global_mouse_position(),selectItemType):
					if selectItemType=='del':
						delItem(get_global_mouse_position())
					else:  #显示属性
						getItemAttr(get_global_mouse_position())
						pass
					pass
				else:	
					var pos=getItemPos(get_global_mouse_position())	
					addItem(selectItemType,selectItem,pos)
				pass
			elif !event.pressed:	
				isPress=false
				pass	
			pass
		elif event is InputEventMouseMotion:	#移动
			if isPress:
				if checkHasItem(get_global_mouse_position(),selectItemType):
					if selectItemType=='del':
						delItem(get_global_mouse_position())
					else:  #显示属性
						getItemAttr(get_global_mouse_position())
				else:	
					var pos=getItemPos(get_global_mouse_position())	
					addItem(selectItemType,selectItem,pos)
		pass
	pass

func _draw():
	if mode=="edit":
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
		for i in bgTiles+allTiles:
			if i.type=='goomba':
				if constants.mapTiles.has(i.type):
					draw_texture(constants.mapTiles[i.type]['0'],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))
				pass
			elif i.type=='koopa':
				if constants.mapTiles.has(i.type):
					draw_texture(constants.mapTiles[i.type]['0'],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))
			elif i.type=='box':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
			elif i.type=='brick':	
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
			elif i.type=='coin':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type]['0'],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
			elif i.type=='pipe':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
					if i.has('pipeType') && (i.pipeType==constants.pipeIn||i.pipeType==constants.pipeOut):
						draw_texture(constants.mapTiles['pipeIn']["0"],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.4))
			elif i.type=='bg':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))
			elif i.type=='flag': #旗杆
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))
					for l in range(i.len):
						draw_texture(constants.mapTiles['stick'][str(i.spriteIndex)],
						Vector2(i.x*blockSize,i.y*blockSize+(l+1)*blockSize),Color(1,1,1,0.5))
					pass
				pass
			elif i.type=="collision"||i.type=="castleFlag":
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
			elif i.type==constants.plant:
				if constants.mapTiles.has(i.type):
					draw_texture(constants.mapTiles[i.type]['0'],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))
		if !marioPos.empty():
			draw_texture(constants.mapTiles['mario']['0'],Vector2(marioPos.x*blockSize,marioPos.y*blockSize),Color(1,1,1,0.5))
	pass


func _on_hide_pressed():
	_toolBtn.show()
	_tab.hide()
	pass # Replace with function body.


func _on_save_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()
	_saveDialog.current_dir=baseDir
#	_saveDialog.current_file="1-1.json"
	_saveDialog.popup_centered()
	pass # Replace with function body.


func _on_toolBtn_pressed():
	_toolBtn.hide()
	_tab.show()
	pass # Replace with function body.


func _on_Button_pressed():
#	for i in _marioList.get_children():
#		i.startDeathJump()
	var baseDir=OS.get_executable_path().get_base_dir()
#	print(baseDir)
	_loadDiaglog.current_dir=baseDir
	_loadDiaglog.popup_centered()	
	pass # Replace with function body.


func _on_FileDialog_confirmed():
	if _saveDialog.current_path:
		save2File(_saveDialog.current_path)
	else:
		print("没有当前文件")
	pass # Replace with function body.

#保存地图信息
func _on_apply_pressed():
	pass # Replace with function body.


func _on_loadDialog_confirmed():
	var dir=_loadDiaglog.current_dir
	var file=_loadDiaglog.current_file
#	print(dir,' ',file)
#	print(_loadDiaglog.current_path)
	if file:
		loadMapFile(dir+"/"+file)
	pass # Replace with function body.

#编辑属性
func _on_edit_pressed():
	for i in allTiles:
		if i["x"]==selectedItem["x"]&&i["y"]==selectedItem["y"]:
			for z in _itemAttr.list.get_children():
				if z.key in ['x','y','spriteIndex']:
					i[z.key]=int(z.getValue())
				else:
					i[z.key]=z.getValue()
			break
	pass # Replace with function body.


func _on_loadDialog_file_selected(_path):
#	print(path)
	if _path:
		loadMapFile(_path)
	pass # Replace with function body.
