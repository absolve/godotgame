extends Node2D


#地图为26x26的方块大小 最小的一块就是墙壁和石头小块

var currentLevel
var builtInMapNum  #内置地图数
var builtInMapFileList  #内置地图数量

export var offset=Vector2.ZERO

var brick=preload("res://scenes/brick.tscn")
var cellSize=16	#每个格子的大小是16px
var mapDir="res://levels"
export var debug=true
var mode= 0  #0是游戏开始 1是编辑模式
export var playerNum=1	# 默认1个人

var player1 = [Vector2(8,25),Vector2(9,25),Vector2(8,24),Vector2(9,24)]
var player2 =[Vector2(16,25),Vector2(17,25),Vector2(16,24),Vector2(17,24)]

var enemyPos=[Vector2(0,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),
	Vector2(24,0),Vector2(25,0),Vector2(24,1),Vector2(24,2),
	Vector2(12,0),Vector2(13,0),Vector2(12,1),Vector2(13,1)]

#基地旁的方块
var basePos=[Vector2(10,25),Vector2(10,24),Vector2(10,23),
			Vector2(11,23),Vector2(12,23),Vector2(13,23),
			Vector2(13,25),Vector2(13,24),Vector2(13,23)]

func _ready():
	#获取可执行文件基本路径
	print(OS.get_executable_path().get_base_dir())
	loadMap()
	#print(getBuiltInMapNum())
	
	getExtensionMapNum()
	print(getBrick(0,0))
	print(getBrick(1,1))

	#$FileDialog.show()
	pass

#载入地图
func loadMap():
	var file = File.new()
	if file.file_exists("res://levels/1.json"):
		file.open("res://levels/1.json", File.READ)
		currentLevel = parse_json(file.get_as_text())
		print("文件",currentLevel)
		file.close()
		#return currentLevel
		print(currentLevel['name'])
		
		for i in currentLevel['base']:
			print(i['type'])
			if i['type'] in [0,1,2,3,4]:
				var temp=brick.instance()
				temp.position.x=i['x']*cellSize+temp.size/2
				temp.position.y=i['y']*cellSize+temp.size/2
				temp.position+=offset
				temp.type=i['type']
				$brick.add_child(temp)
			
		for i in currentLevel['data']:
			print(i['type'] in [0,1,2,3,4])
			if i['type'] in [0,1,2,3,4]:
				var temp=brick.instance()
				temp.position.x=i['x']*cellSize+temp.size/2
				temp.position.y=i['y']*cellSize+temp.size/2
				temp.position+=offset
				temp.type=i['type']
				$brick.add_child(temp)
	
	#delPlayerPosBrick()
			
	pass

#获取基地旁边的砖块
func getBaseBrick():
	
	pass

#删除敌人出生点方块
func delEnemyPosBrick():
	for i in enemyPos:
		var brick=getBrick(i.x,i.y)
		if brick:
			brick.queue_free()
	
	pass
	
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
	
	

#获取固定位置的方块  x [0-25] y[0-25]
func getBrick(x:int,y:int):
	var rect = Rect2(Vector2(x*cellSize,y*cellSize),Vector2(cellSize,cellSize))
	
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


#获取内置的地图文件数量
func getBuiltInMapNum(fileList:Array):
	var num=0
	var dir = Directory.new()
	if dir.open(mapDir) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				num+=1
				fileList.append(file_name)
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return num


#获取扩展的地图	
func getExtensionMapNum():
	var num=0
	var baseDir=OS.get_executable_path().get_base_dir()
	var mapPath=baseDir+"/levels"
	var dir = Directory.new()
	if dir.dir_exists(mapPath):
		print("1212")
		if dir.open(mapPath) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if !dir.current_is_dir():
					num+=1
					print("Found file: " + file_name)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")
	else:
		print("Directory not exist")
	return num



func _process(delta):
	update()
	pass
	
	
func _draw():
	if not debug:
		return
	for i in range(27):
		draw_line(Vector2(i*cellSize,0),Vector2(i*cellSize,cellSize*26),Color.gray,0.5,true)
		pass
	for i in range(27):
		draw_line(Vector2(0,i*cellSize),Vector2(cellSize*26,i*cellSize),Color.gray,0.5,true)
	
	
	
	pass
	
