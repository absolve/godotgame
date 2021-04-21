extends Node2D


#地图为26x26的方块大小 最小的一块就是墙壁和石头小块

var currentLevel
var builtInMapNum  #内置地图数
var builtInMapFileList  #内置地图数量

export var offset=Vector2(32,16)

var brick=preload("res://scenes/brick.tscn")
var cellSize=16	#每个格子的大小是16px
#var mapDir="res://levels"
export var debug=true
var mode= 0 #0是正常游戏 1是编辑模式
export var playerNum=1	# 默认1个人

var player1 = [Vector2(8,25),Vector2(9,25),Vector2(8,24),Vector2(9,24)]
#var player1 = [Vector2(0,25),Vector2(1,25),Vector2(0,24),Vector2(1,24)]
var player2 =[Vector2(16,25),Vector2(17,25),Vector2(16,24),Vector2(17,24)]

var enemyPos=[Vector2(0,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),
	Vector2(24,0),Vector2(25,0),Vector2(24,1),Vector2(24,2),
	Vector2(12,0),Vector2(13,0),Vector2(12,1),Vector2(13,1)]

var enemyBirthPos=[Vector2(0,0),Vector2(12,0),Vector2(24,0)]

#基地旁的方块
var baseBrickPos=[Vector2(11,25),Vector2(11,24),Vector2(11,23),
			Vector2(12,23),Vector2(13,23),Vector2(14,23),
			Vector2(14,25),Vector2(14,24)]
#基地
var basePlacePos=[Vector2(12,25),Vector2(13,25),
Vector2(12,24),Vector2(13,24)]

			
#基地位置
var basePos=Vector2(12,24)
var mapRect  #地图大小
var brickList=[] #方块的数组
var currentItem=0 #选中的方块
var lock=false 	#锁定地图不在修改
var isPress=false #是否按下按键

var bonus=preload("res://scenes/bonus.tscn")
var base=preload("res://scenes/base.tscn")
var tankNew= preload("res://scenes/tankNew.tscn")

onready var _level=$tools/level
onready var _levelNum=$tools/level/number
onready var _1pLive=$tools/p1live
onready var _1pLiveNum=$tools/p1live/box/num
onready var _2pLive=$tools/p2live
onready var _2pLiveNum=$tools/p2live/box/num
onready var _enemyList=$tools/enemyList
onready var _tank=$tanks
onready var _fileDiaglog=$tools/FileDialog
onready var _loadDiaglog=$tools/loadDialog
onready var _bricks = $tools/bricks
onready var _tanks=$tanks
onready var _mapbg=$mapbg
onready var _bonus=$bonus


func _ready():
	#获取可执行文件基本路径
	#print(OS.get_executable_path().get_base_dir())
#	mode=1
	randomize()
	_mapbg.rect_position=offset
	mapRect =Rect2(offset,Vector2(cellSize*26,cellSize*26))
	print(mapRect)
	#loadMap("res://levels/2.json")
	#mode=1
	if mode==1:#编辑模式
		_level.hide()
		_1pLive.hide()
		_2pLive.hide()
		_enemyList.hide()
		_bricks.show()
		createBase()
		addBaseBrickInEdit()
	elif mode==0:
		_level.show()
		_1pLive.show()
		if Game.mode==2:
			_2pLive.show()
		_enemyList.show()
		_bricks.hide()
		
func setMode(mode):
	if mode==1:#编辑模式
		_level.hide()
		_1pLive.hide()
		_2pLive.hide()
		_enemyList.hide()
		_bricks.show()
		createBase()
		addBaseBrickInEdit()
	elif mode==0:
		_level.show()
		_1pLive.show()
		if Game.mode==2:
			_2pLive.show()
		_enemyList.show()
		_bricks.hide()		

#设置地图关卡
func setLevelName(level):
	_levelNum.text=str(level)
	
#添加随机的敌人
func addEnemy(basePos:Vector2,isFreeze=false):
	var enemy=Game.enemy.instance()
	var index =randi()%3
#	var pos=Vector2(cellSize+enemy.getSize()/2,cellSize+enemy.getSize()/2)
#	var pos = Vector2(cellSize*enemyBirthPos[0].x+enemy.getSize()/2,
#					cellSize*enemyBirthPos[0].y+enemy.getSize()/2)
	var pos = Vector2(cellSize*enemyBirthPos[randi()%3].x+enemy.getSize()/2,
					cellSize*enemyBirthPos[randi()%3].y+enemy.getSize()/2)
	
	pos+=offset
	enemy.isFreeze=isFreeze
	enemy.type=randi()%4
#	enemy.type=0
	enemy.setPos(pos)
	enemy.targetPos=basePos
	_tank.add_child(enemy)
	delEnemyNum()
	pass

func addEnemyPos(basePos:Vector2,index):
	var enemy=Game.enemy.instance()
	#var index =randi()%3
	#var pos=Vector2(cellSize+enemy.getSize()/2,cellSize+enemy.getSize()/2)
	var pos = Vector2(cellSize*enemyBirthPos[index].x+enemy.getSize()/2,
					cellSize*enemyBirthPos[index].y+enemy.getSize()/2)
	
	pos+=offset
	enemy.setPos(pos)
	enemy.targetPos=basePos
	_tank.add_child(enemy)
	delEnemyNum()
	pass

#删除敌人数量
func delEnemyNum():
	var node=_enemyList.get_child(_enemyList.get_child_count()-1)
	_enemyList.remove_child(node)
	pass

#设置玩家状态
func setPlayerFreeze():
	for i in _tank.get_children():
		if i.get_class()=="player":
			i.setFreeze()
	pass

#冻住敌人
func setEnemyFreeze(flag=true):
	for i in _tanks.get_children():
		if i.get_class()=="enemy":
			i.setFreeze(flag)
		
#清除敌人tank
func clearEnemyTank()->Dictionary:
	var list={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
	for i in _tanks.get_children():
		if i.get_class()=="enemy" and i.state!=Game.tank_state.IDLE:
			if i.type==0:
				list['typeA']+=1
			elif i.type==1:
				list['typeB']+=1
			elif i.type==2:
				list['typeC']+=1
			elif i.type==3:	
				list['typeD']+=1
			i.setState(Game.tank_state.DEAD)	
			i.addExplode(true)	
	return list
	
	
func getPlayerById(id):
	var tank
	for i in _tank.get_children():
		if i.get_class()=="player" and i.getPlayId()==id:
			tank=i
	return tank	
	
#添加物品
func addBonus():
	if _bonus.get_child_count()>0:
		for i in _bonus.get_children():
			_bonus.remove_child(i)
	var temp = bonus.instance()
	#不能在基地附近
	var pos = Vector2(randi()%25+1,randi()%25+1)
	while pos in basePlacePos:  #防止在基地旁边
		pos = Vector2(randi()%25+1,randi()%25+1)
	temp.setPos(pos*cellSize+offset)
	temp.setType(randi()%9)
	_bonus.add_child(temp)
	pass

#载入地图
func loadMap(filename:String):
	var file = File.new()
	if file.file_exists(filename):
		file.open(filename, File.READ)
		currentLevel = parse_json(file.get_as_text())
#		print("文件",currentLevel)
		file.close()
		#return currentLevel
		print(currentLevel['name'])	
		for i in currentLevel['data']:
			if i['type'] in [0,1,2,3,4]:
				if mode==0:
					var temp=brick.instance()
					temp.position.x=i['x']*cellSize+temp.size/2
					temp.position.y=i['y']*cellSize+temp.size/2
					temp.position+=offset
					temp.type=i['type']
					$brick.add_child(temp)
				elif mode==1:	#编辑模式
					brickList.append(i)
	else:
		print('文件不存在')				
	if mode==0:
		delPlayerPosBrick()
		delEnemyPosBrick()	
		#delBasePlaceBrick()
		createBase()

#添加基地周边石头
func addBaseStone():
	for i in baseBrickPos:
		var temp=brick.instance()
		temp.position.x=i['x']*cellSize+temp.size/2
		temp.position.y=i['y']*cellSize+temp.size/2
		temp.position+=offset
		temp.type=1
		$brick.add_child(temp)
	pass

#添加基地旁边的砖块在编辑模式下
func addBaseBrickInEdit():
	for i in baseBrickPos:
		brickList.append({'x':i.x,'y':i.y,"type":0})

#删除基地旁边的方框
func delBaseBrickPos():
	for i in baseBrickPos:
		var brick=getBrick(i.x,i.y)
		if brick:
			brick.queue_free()

#设置基地旁边的砖块类型
func changeBasePlaceBrickType(type):
	for i in baseBrickPos:
		var b=getBrick(i.x,i.y)
		if b:
			b.changeType(type)
		else:
#			print('changeBasePlaceBrickType')
			var temp=brick.instance()
			temp.position.x=i['x']*cellSize+temp.size/2
			temp.position.y=i['y']*cellSize+temp.size/2
			temp.position+=offset
			temp.type=type
			$brick.add_child(temp)	
	pass
	
#清空地图
func clearMap():
	for i in $brick.get_children():
		$brick.remove_child(i)
	for i in $bonus.get_children():
		$bonus.remove_child(i)	
	for i in $tanks.get_children():
		$tanks.remove_child(i)
	for i in $bullets.get_children():
		$bullets.remove_child(i)		
	for i in $base.get_children():
		$base.remove_child(i)


#删除敌人出生点方块
func delEnemyPosBrick():
	for i in enemyPos:
		var brick=getBrick(i.x,i.y)
		if brick:
			brick.queue_free()
	
	
#删除玩家周边的方块
func delPlayerPosBrick():
	for i in player1:
		var brick=getBrick(i.x,i.y)
		if brick:
			brick.queue_free()
	if playerNum>1:
		for i in player2:
			var brick=getBrick(i.x,i.y)
			if brick:
				brick.queue_free()
				
#删除基地位置方块
func delBasePlaceBrick():
	for i in basePlacePos:
		var brick=getBrick(i.x,i.y)
		if brick:
			brick.queue_free()
			

#创建基地	
func createBase():
	var temp=base.instance()
	temp.position=Vector2(basePos.x*cellSize+temp.size/2,basePos.y*cellSize+temp.size/2)
	temp.position+=offset
	$base.add_child(temp)
	pass


#获取固定位置的方块  x [0-25] y[0-25]
func getBrick(x:int,y:int):
	var rect = Rect2(Vector2(x*cellSize,y*cellSize)+offset,Vector2(cellSize,cellSize))
	var child=$brick.get_children()
	var brick=null
	for i in child:
		if rect.has_point(i.position):
			brick= i
			break
	return brick

	
#设置方块类型
func setBrickType(list:Array,type:int):
	for i in list:
		var brick = getBrick(i.x,i.y)
		if brick:
			if brick.has_method("setType"):
				brick.setType(type)
	pass

#设置玩家生命数
func setPlayerLive(playNo:int,lives:int):
	if playNo==1:
#		_1pLive.visible=true
		_1pLiveNum.text=str(lives)
	elif playNo==2:
#		_2pLive.visible=true
		_2pLiveNum.text=str(lives)

#获取玩家的等级
func getPlayerStatus():
	var data={'p1':{'level':1,'life':1,'hasShip':false}
			,'p2':{'level':1,'life':1,'hasShip':false}}
	for i in _tank.get_children():
		if i.get_class()=="player":
			if i.playId==1:
				data['p1']['level']=i.level
				data['p1']['life']=i.life
				data['p1']['hasShip']=i.hasShip
			elif i.playId==2:
				data['p2']['level']=i.level
				data['p2']['life']=i.life
				data['p2']['hasShip']=i.hasShip
	return 	data
	
			
#添加玩家
func addNewPlayer(playNo:int,isFreeze=false,state:Dictionary={'level':1,'life':1,
										'hasShip':false}):
	var tank1=tankNew.instance()
	if playNo==1:		
		tank1.playId=1
		tank1.position=Vector2(9*cellSize,25*cellSize)+offset	
		setPlayerLive(1,Game.playerLive[0])	
	elif playNo==2:
		tank1.playId=2
		tank1.position=Vector2(17*cellSize,25*cellSize)+offset
		setPlayerLive(1,Game.playerLive[0])	
	tank1.level=state['level']
	tank1.life=state['life']
	tank1.hasShip=state['hasShip']
	tank1.setFreeze(isFreeze)
	_tank.add_child(tank1)
	
#检查点击的地方是否有item
func checkItem(pos):
	var flag=false
	pos-=offset
	var x = pos.x
	var y=pos.y
	var indexX = int(x)/(cellSize)
	var indexY=int(y)/(cellSize)
	var temp = Vector2(indexX,indexY)
	print(indexX,' ',indexY)
	if temp in basePlacePos:
		return true
	for i in brickList:
		if i['x']==indexX and i['y']==indexY:
			flag=true 
			break
	#print(flag)	
	return flag

#添加方块	
func addItem(pos):
	pos-=offset
	var x = pos.x
	var y=pos.y
	var indexX = int(x)/(cellSize)
	var indexY=int(y)/(cellSize)
	
	brickList.append({'x':indexX,'y':indexY,"type":currentItem})
	pass

func clearItem(pos):
	pos-=offset
	var x = pos.x
	var y=pos.y
	var indexX = int(x)/(cellSize)
	var indexY=int(y)/(cellSize)
	print(indexX,' ',indexY)
	var tempList = []
	for i in brickList:
		if i['x']==indexX and i['y']==indexY:
			tempList.append(i)
			break
	for i in tempList:
		brickList.erase(i)
	
#清空所有数据
func clearAllItem():
	brickList.clear()
	pass

#保存数据到文件
func save2File(fileName):
	print('save2File')
	var data={"name":'',"data":[],"base":[],"author":"absolve",
	"description":""}
	data['data']=brickList
	var file = File.new()
	file.open(fileName, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	

func _process(delta):
	if mode==1:
		update()
	pass

		
func _input(event):
	if _fileDiaglog.visible or _loadDiaglog.visible or lock or mode!=1:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and  event.pressed:
			isPress=true
			if currentItem!=-1:	
				if !mapRect.has_point(get_global_mouse_position()):
					return
				if! checkItem(get_global_mouse_position()):
					addItem(get_global_mouse_position())	
			elif currentItem==-1:
				clearItem(get_global_mouse_position())		
		elif !event.pressed:
			isPress=false
	elif event is InputEventMouseMotion:	#移动
		if isPress:
			if currentItem!=-1:	
				if !mapRect.has_point(get_global_mouse_position()):
					return
				if! checkItem(get_global_mouse_position()):
					addItem(get_global_mouse_position())	
			elif currentItem==-1:
				clearItem(get_global_mouse_position())
		pass
	
func _draw():
#	if not debug:
#		return
	if debug and mode==1:
		for i in range(27):
			draw_line(Vector2(i*cellSize,0)+offset,Vector2(i*cellSize,cellSize*26)+offset,Color.gray,0.5,true)
			pass
		for i in range(27):
			draw_line(Vector2(0,i*cellSize)+offset,Vector2(cellSize*26,i*cellSize)+offset,Color.gray,0.5,true)
	
	if mode==1:
		for i in brickList:
			#draw_rect(Rect2(Vector2(i['x']*cellSize,i['y']*cellSize)+offset,Vector2(cellSize,cellSize)),Color.gray)		
			if i['type']==0:
				draw_texture(Game.brick,Vector2(i['x']*cellSize,i['y']*cellSize)+offset)
			elif i['type']==1:
				draw_texture(Game.stone,Vector2(i['x']*cellSize,i['y']*cellSize)+offset)
			elif i['type']==2:
				draw_texture(Game.water,Vector2(i['x']*cellSize,i['y']*cellSize)+offset)
			elif i['type']==3:
				draw_texture(Game.bush,Vector2(i['x']*cellSize,i['y']*cellSize)+offset)
			elif i['type']==4:
				draw_texture(Game.ice,Vector2(i['x']*cellSize,i['y']*cellSize)+offset)

func _on_TextureButton_pressed():
	currentItem=0
	pass # Replace with function body.


func _on_TextureButton2_pressed():
	currentItem=1
	pass # Replace with function body.


func _on_TextureButton3_pressed():
	currentItem=2
	pass # Replace with function body.


func _on_TextureButton4_pressed():
	currentItem=-1
	pass # Replace with function body.

func _on_TextureButton5_pressed():
	currentItem=3
	pass # Replace with function body.

func _on_TextureButton6_pressed():
	currentItem=4
	pass # Replace with function body.


func _on_Button_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()
	_fileDiaglog.current_dir=baseDir
	_fileDiaglog.current_file="1992.json"
	_fileDiaglog.popup_centered()
	pass # Replace with function body.


func _on_FileDialog_confirmed():
	var path=_fileDiaglog.current_dir	
	print(_fileDiaglog.current_path)
	print(path)
	if _fileDiaglog.current_file:
		save2File(_fileDiaglog.current_path)
		#_fileDiaglog.deselect_items()


func _on_Button2_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()
	_loadDiaglog.current_dir=baseDir
	_loadDiaglog.popup_centered()
	pass # Replace with function body.


func _on_loadDialog_confirmed():
	var dir=_loadDiaglog.current_dir
	var file=_loadDiaglog.current_file
	print(dir,file)
	if file:
		loadMap(dir+"/"+file)
	pass # Replace with function body.


func _on_Button3_pressed():
	clearAllItem()
	pass # Replace with function body.


func _on_Button4_pressed():
	lock=!lock
	pass # Replace with function body.

#返回
func _on_Button5_pressed():
	queue_free()
	Game.changeScene(Game._welcomeScene)
	pass # Replace with function body.
