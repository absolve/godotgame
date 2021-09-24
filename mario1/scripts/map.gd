extends Node2D
"""
地图显示砖块，箱子
"""
const blockSize=32
const minWidthNun=19
const heightNun=15

var brick=preload("res://scenes/brick.tscn")
var box=preload("res://scenes/box1.tscn")
var pipe=preload("res://scenes/pipe.tscn")

var map=[]
var debug=true
var mapSize=19  #宽度 一个屏幕19块
var enemyList=[] #敌人列表
var currentLevel  #文件数据
var path="res://levels/1-1.json"
var bg="overworld" #overworld   castle underwater
var currentMapWidth=0 #当前地图的宽度
var allTiles=[]
onready var _brick=$brick
onready var _bg=$bg
onready var camera=$Camera2D
onready var _itemList=$Control/ItemList


func _ready():
	print(camera.get_camera_position())
	print(camera.get_camera_screen_center())
#	loadMapFile(path)
	
	nodeItem()
	pass

func nodeItem():
	_itemList.add_item("12",null,true)
	_itemList.add_item("12",null,true)
	_itemList.add_item("12",null,true)
	_itemList.add_item("12",null,true)
	_itemList.add_item("12",null,true)
	pass


func _update(delta):
	
	pass

func loadMapFile(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		currentLevel= parse_json(file.get_as_text())
#		print(currentLevel)
		currentMapWidth=currentLevel['mapSize']*blockSize
		print(currentMapWidth)
		if currentLevel['bg']=="overworld":
			_bg.color=Color(Game.backgroundcolor[0])
		elif currentLevel['bg']=="castle":
			_bg.color=Color(Game.backgroundcolor[1])
		elif currentLevel['bg']=="underwater":	
			_bg.color=Color(Game.backgroundcolor[2])
			
		for i in currentLevel['data']:
			if i['type'] =='brick':
				var temp=brick.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				var obj={"x":i['x'],"y":i['y']}
#				print(obj)
				if checkTile(obj):
					print(obj,' has one brick')
				else:
					_brick.add_child(temp)
#				_brick.add_child(temp)
				pass
			elif i['type']=='box':
				var temp=box.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				var obj={"x":i['x'],"y":i['y']}
				if checkTile(obj):
					print(obj,' has one box')
				else:
					_brick.add_child(temp)
#				_brick.add_child(temp)
				pass
			elif i['type']=='goomba':	
				
				pass
			elif i['type']=='koopa':
				
				pass
			elif i['type']=='pipe':
				var temp=pipe.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+blockSize/2
				temp.position.y=i['y']*blockSize+blockSize/2
				var obj={"x":i['x'],"y":i['y']}
				if checkTile(obj):
					print(obj,' has one pipe')
				else:
					_brick.add_child(temp)
				_brick.add_child(temp)
		file.close()
	else:
		print('文件不存在')	
		pass
	pass

func save2File():
	
	pass

func checkTile(obj):
	if allTiles.bsearch_custom(obj,self,"checkXY")!=0:
		return true
	else:
		allTiles.append(obj)
		return false	
		
func checkXY(a,b):
	return a["x"]==b["x"]&&a["y"]==b["y"]


func _input(event):
	if debug:
		if event is InputEventKey:
			if event.is_pressed():
				if (event as InputEventKey).scancode==KEY_LEFT:	
					if camera.position.x>0:
						camera.position.x-=10
					pass
				elif (event as InputEventKey).scancode==KEY_RIGHT:	
					if currentMapWidth-camera.position.x>minWidthNun*blockSize:
						camera.position.x+=10
					pass	
		pass
	pass

func _draw():
	if debug:
		for i in range(mapSize):
			draw_line(Vector2(i*blockSize,0),Vector2(i*blockSize,blockSize*heightNun)
			,Color.gray,0.5,true)
		for i in range(mapSize):
			draw_line(Vector2(0,i*blockSize),Vector2(blockSize*heightNun,i*blockSize),
			Color.gray,0.5,true)	
	pass
	
	
