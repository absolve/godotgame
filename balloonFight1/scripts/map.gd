extends Node2D

var cellSize=16	#每个格子的大小是16px
var height
var width
var debug=false
var currentLevel
var mapDir="res://levels"	#内置地图路径


onready var _obj=$obj
onready var _camera=$Camera2D
onready var _tile=$tile
onready var _other=$obther
onready var _title=$title
var player=preload("res://scenes/player.tscn")
var enemy=preload("res://scenes/enemy.tscn")
var bubble=preload("res://scenes/bubble.tscn")
var cloud=preload("res://scenes/cloud.tscn")
var tile=preload("res://scenes/tile.tscn")
var splash=preload("res://scenes/splash.tscn")
var spinBall=preload("res://scenes/spinBall.tscn")
var star=preload("res://scenes/star.tscn")

func _ready():
	randomize()
	var viewRect=get_viewport_rect()
	width=viewRect.size.x
	height=viewRect.size.y
	print(width,height)
#	Game.gameData.level='level_1'
	Game.gameData.level='1'
	Game.gameData.width=width
	Game.gameData.height=height
	var dir = Directory.new()
	if dir.file_exists(mapDir+'/'+Game.gameData.level+".json"):
		print("ok")
		loadMapFile(mapDir+'/'+Game.gameData.level+".json")
	else:
		print("文件不存在")
	
	for i in range(10):
		var temp=star.instance()
		temp.position.x=randi()%490+10
		temp.position.y=randi()%350+30
		_other.add_child(temp)
	_title.setPlayerLives(1,1)
		
#载入文件
func loadMapFile(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		currentLevel= parse_json(file.get_as_text())
		for i in currentLevel['data']:
			if i['type']=='player':
				var temp=player.instance()
#				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*cellSize+cellSize/2
				temp.position.y=i['y']*cellSize+cellSize/2
				_obj.add_child(temp)
			elif i['type']=='enemy':
				var temp=enemy.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*cellSize+cellSize/2
				temp.position.y=i['y']*cellSize+cellSize/2-8
				_obj.add_child(temp)
			elif i['type']=='tile':
				var temp=tile.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*cellSize+cellSize/2
				temp.position.y=i['y']*cellSize+cellSize/2
				_tile.add_child(temp)
			elif i['type']=='spinBall':
				var temp=spinBall.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*cellSize+cellSize/2
				temp.position.y=i['y']*cellSize+cellSize/2
				_tile.add_child(temp)
				
	
func _physics_process(delta):
	
#	for i in _obj.get_children():
#		if i.type==Constants.player:
#			if i.position.x+i.size.x/2<0:
#				i.position.x=width+i.size.x/2
#			if i.position.x-i.size.x/2>width:
#				i.position.x=-i.size.x/2
	pass


func _draw():
	if debug:
		for i in range(width/cellSize):
			draw_line(Vector2(i*cellSize,0),Vector2(i*cellSize,width),Color.gray,0.5,true)
		for i in range(height/cellSize):
			draw_line(Vector2(0,i*cellSize),Vector2(width,i*cellSize),Color.gray,0.5,true)
	
