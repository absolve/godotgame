extends Node2D
"""
地图显示砖块，箱子
"""
const blockSize=32
const minWidthNun=18
const heightNun=15

var brick=preload("res://scenes/brick.tscn")
var box=preload("res://scenes/box1.tscn")

var map=[]
var debug=true
var mapSize=18  #宽度
var enemyList=[] #敌人列表
var currentLevel  #文件数据
onready var _brick=$brick

func _ready():
	pass

func loadMapFile(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		currentLevel= parse_json(file.get_as_text())
		print(currentLevel)
		for i in currentLevel['data']:
			if i['type'] =='brick':
				var temp=brick.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+temp.rect.size.x
				temp.position.y=i['y']*blockSize+temp.rect.size.y
				_brick.add_child(temp)
				pass
			elif i['type']=='box':
				var temp=box.instance()
				temp.spriteIndex=i['spriteIndex']
				temp.position.x=i['x']*blockSize+temp.rect.size.x
				temp.position.y=i['y']*blockSize+temp.rect.size.y
				_brick.add_child(temp)
				pass
			elif i['type']=='goomba':	
				
				pass
			elif i['type']=='koopa':
				
				pass
				
		file.close()
	else:
		print('文件不存在')	
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
	
	
