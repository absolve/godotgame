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
var mode= 0  #0是正常游戏 1是编辑模式
export var playerNum=1	# 默认1个人

var player1 = [Vector2(8,25),Vector2(9,25),Vector2(8,24),Vector2(9,24)]
#var player1 = [Vector2(0,25),Vector2(1,25),Vector2(0,24),Vector2(1,24)]
var player2 =[Vector2(16,25),Vector2(17,25),Vector2(16,24),Vector2(17,24)]

var enemyPos=[Vector2(0,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),
	Vector2(24,0),Vector2(25,0),Vector2(24,1),Vector2(24,2),
	Vector2(12,0),Vector2(13,0),Vector2(12,1),Vector2(13,1)]

#基地旁的方块
var baseBrickPos=[Vector2(10,25),Vector2(10,24),Vector2(10,23),
			Vector2(11,23),Vector2(12,23),Vector2(13,23),
			Vector2(13,25),Vector2(13,24),Vector2(13,23)]
#基地
var basePlacePos=[Vector2(12,25),Vector2(13,25),
Vector2(12,24),Vector2(13,24)]
			
#基地位置
var basePos=Vector2(12,24)
var mapRect  #地图大小
var brickList=[] #方块的数组
var currentItem=0 #选中的方块
var lock=false 	#锁定地图不在修改

var player = preload("res://scenes/tank.tscn")
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


func _ready():
	#获取可执行文件基本路径
	#print(OS.get_executable_path().get_base_dir())
	#loadMap()
	
	
	$mapbg.rect_position=offset
	mapRect =Rect2(offset,Vector2(cellSize*26,cellSize*26))
	#loadMap("res://levels/2.json")
	#mode=1
	if mode==1:
		_level.hide()
		_1pLive.hide()
		_2pLive.hide()
		_enemyList.hide()
		_bricks.show()
	elif mode==0:
		_level.show()
		_1pLive.show()
		_2pLive.show()
		_enemyList.show()
		_bricks.hide()
	
	
#添加随机的敌人
func addEnemy():
	pass

#设置玩家状态
func setPlayerState():
	pass

#设置敌人的状态
func setEnemyState():
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
		
		for i in currentLevel['base']:
			if i['type'] in [0,1,2,3,4]:
				if mode==0:
					var temp=brick.instance()
					temp.position.x=i['x']*cellSize+temp.size/2
					temp.position.y=i['y']*cellSize+temp.size/2
					temp.position+=offset
					temp.type=i['type']
					$brick.add_child(temp)
				elif mode==1:
					brickList.append(i)
			
		for i in currentLevel['data']:
			if i['type'] in [0,1,2,3,4]:
				if mode==0:
					var temp=brick.instance()
					temp.position.x=i['x']*cellSize+temp.size/2
					temp.position.y=i['y']*cellSize+temp.size/2
					temp.position+=offset
					temp.type=i['type']
					$brick.add_child(temp)
				elif mode==1:
					brickList.append(i)
	if mode==0:
		delPlayerPosBrick()
		delEnemyPosBrick()	
		delBasePlaceBrick()
		createBase()



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
	$brick.add_child(temp)
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
		_1pLive.visible=true
		_1pLiveNum.text=lives
	elif playNo==2:
		_2pLive.visible=true
		_2pLiveNum.text=lives


func addNewPlayer(playNo:int):
	if playNo==1:
#		var temp=Game.flash.instance()
#		temp.position = Vector2(8*cellSize+temp.size/2,24*cellSize+temp.size/2)+offset
#		temp.parentNode = _tank
#
#		var tank1 =player.instance()
#		tank1.position=Vector2(8*cellSize+temp.size/2,24*cellSize+temp.size/2)+offset
#		temp.addNode = tank1
#		_tank.add_child(temp)
		var tank1=tankNew.instance()
		tank1.position=Vector2(9*cellSize,25*cellSize)+offset
		_tank.add_child(tank1)
		pass
	elif playNo==2:
		
		pass
	
#检查点击的地方是否有item
func checkItem(pos):
	var flag=false
	pos-=offset
	var x = pos.x
	var y=pos.y
	var indexX = int(x)/(cellSize)
	var indexY=int(y)/(cellSize)
	print(indexX,' ',indexY)
	for i in brickList:
		if i['x']==indexX and i['y']==indexY:
			flag=true 
			break
	print(flag)	
	return flag
	
	

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
	#update()
	pass


var isPress=false
		
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
#	for i in range(27):
#		draw_line(Vector2(i*cellSize,0)+offset,Vector2(i*cellSize,cellSize*26)+offset,Color.gray,0.5,true)
#		pass
#	for i in range(27):
#		draw_line(Vector2(0,i*cellSize)+offset,Vector2(cellSize*26,i*cellSize)+offset,Color.gray,0.5,true)
	
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
	


func _on_Button2_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()
	_loadDiaglog.current_dir=baseDir
	_loadDiaglog.popup_centered()
	pass # Replace with function body.


func _on_loadDialog_confirmed():
	var path=_loadDiaglog.current_file
	if path:
		loadMap(path)
	pass # Replace with function body.


func _on_Button3_pressed():
	clearAllItem()
	pass # Replace with function body.


func _on_Button4_pressed():
	
	pass # Replace with function body.
