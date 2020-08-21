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
var mode= 0  #0是游戏开始 1是编辑模式
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
#基地位置
var basePos=Vector2(12,24)

var player = preload("res://scenes/tank.tscn")
var base=preload("res://scenes/base.tscn")


onready var _1pLive=$tools/p1live
onready var _1pLiveNum=$tools/p1live/box/num
onready var _2pLive=$tools/p2live
onready var _2pLiveNum=$tools/p2live/box/num
onready var _enemyList=$tools/enemyList
onready var _tank=$tanks




func _ready():
	#获取可执行文件基本路径
	#print(OS.get_executable_path().get_base_dir())
	#loadMap()
	
	Game.mainScene=$bullets
	
	$mapbg.rect_position=offset
	
	#loadMap("res://levels/1.json")
	#Game.connect("baseDestroyed",self,"baseDestroy")
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
			print(i['type'])
			if i['type'] in [0,1,2,3,4]:
				var temp=brick.instance()
				temp.position.x=i['x']*cellSize+temp.size/2
				temp.position.y=i['y']*cellSize+temp.size/2
				temp.position+=offset
				temp.type=i['type']
				$brick.add_child(temp)
			
		for i in currentLevel['data']:
	#		print(i['type'] in [0,1,2,3,4])
			if i['type'] in [0,1,2,3,4]:
				var temp=brick.instance()
				temp.position.x=i['x']*cellSize+temp.size/2
				temp.position.y=i['y']*cellSize+temp.size/2
				temp.position+=offset
				temp.type=i['type']
				$brick.add_child(temp)
	
	delPlayerPosBrick()
	delEnemyPosBrick()	
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
		var temp=Game.flash.instance()
		temp.position = Vector2(8*cellSize+temp.size/2,24*cellSize+temp.size/2)+offset
		temp.parentNode = _tank
		var tank1 =player.instance()
		tank1.position=Vector2(8*cellSize+temp.size/2,24*cellSize+temp.size/2)+offset
		temp.addNode = tank1
		_tank.add_child(temp)
		pass
	elif playNo==2:
		
		pass
	
#基地毁灭	
func baseDestroy():
	print('baseDestroy')
	pass

func _process(delta):
	update()
	

	
func _draw():
	if not debug:
		return
	for i in range(27):
		draw_line(Vector2(i*cellSize,0)+offset,Vector2(i*cellSize,cellSize*26)+offset,Color.gray,0.5,true)
		pass
	for i in range(27):
		draw_line(Vector2(0,i*cellSize)+offset,Vector2(cellSize*26,i*cellSize)+offset,Color.gray,0.5,true)
	
#	for i in player1:
#		draw_rect(Rect2(Vector2(i.x*cellSize,i.y*cellSize)+offset,Vector2(cellSize,cellSize)),Color.gray,0.5,true)
	
	
	
