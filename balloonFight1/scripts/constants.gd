extends Node


const left='left'
const right='right'
const player='player'
const enemy='enemy'

#状态
const enemyOnFloor='enemyOnFloor'
const enemyFall='enemyFall'
const enemyDead='enemyDead'
const enemyPumpUp='enemyPumpUp' #打气
const enemyFly='enemyFly'
const enemyIdle='enemyIdle'
const enemySearch='enemySearch'

const tilesType=['del','player','water','tile','spinBall'] 
var mapTiles={} #每个图块对应的图片

func _ready():
	for i in Constants.tilesType:
		mapTiles[i]={}
	loadIcon()

const tilesAttribute={
	"del":{
		"type": "del",
		"spriteIndex": 0,
		"x": 0,
		"y": 0
	},
	'player':{
		"type": "player",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		'id':1,
		
	},
	'water':{
		"type": "water",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
	},
	'water1':{
		"type": "water",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
	},
	'water2':{
		"type": "water",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
	},
	'water3':{
		"type": "water",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
	},
	'tile':{
		"type": "tile",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile1':{
		"type": "tile",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile2':{
		"type": "tile",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile3':{
		"type": "tile",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile4':{
		"type": "tile",
		"spriteIndex": 4,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile5':{
		"type": "tile",
		"spriteIndex": 5,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile6':{
		"type": "tile",
		"spriteIndex": 6,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile7':{
		"type": "tile",
		"spriteIndex": 7,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile8':{
		"type": "tile",
		"spriteIndex": 8,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile9':{
		"type": "tile",
		"spriteIndex": 9,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile10':{
		"type": "tile",
		"spriteIndex": 10,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'tile11':{
		"type": "tile",
		"spriteIndex": 11,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'spinBall':{
		"type": "spinBall",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'spinBall1':{
		"type": "spinBall",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'spinBall2':{
		"type": "spinBall",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		'rotate':0
	},
	'spinBall3':{
		"type": "spinBall",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
		'rotate':0
	},
}

#属性值的	类型
const tilesAttributeType={
	'spriteIndex':"int",
	"x":"int",
	"y":"int",
	'layer':"int",
	"offsetX":"int",
	"offsetY":"int",
}

#载入方块图片
func loadIcon():
	var dic=Directory.new()
	dic.open("res://icon")
	dic.list_dir_begin()
	while true:
		var file = dic.get_next()
		if file == "":
			break
		if file.get_extension()=='png':
			var fileName=file.get_basename().split("#")
			var type = fileName[0]
			if fileName.size()>1:
				var index=fileName[1]
				if mapTiles.has(type): #载入文件
					mapTiles[type][index]=load(dic.get_current_dir()+"/"+file)
			else: #只有名字
				if mapTiles.has(type):
					mapTiles[type]["0"]=load(dic.get_current_dir()+"/"+file)	
	print(mapTiles)
	dic.list_dir_end()
