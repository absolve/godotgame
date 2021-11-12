extends Node
#保存所有的常量

#方块状态
var resting="resting"  #静止
var bumped="bumped"	#突起
var opened="opened"	#已打开

#蘑菇 星星状态
var growing="growing" #出现
var moving="moving" #移动
var stop="stop"
var jumping="jumping"

#敌人的状态
var walking="walking"
var dead="dead"
var deadJump="deadJump"
var sliding="sliding"

#mario的状态
var idle="idle"
var stand="stand"
var walk="walk"
var jump ="jump"
var fall="fall"
var small2big="small2big"
var big2fire="big2fire"
var big2small="big2small"
var crouch="crouch"

#类型
var empty="empty"
var mario="mario"
var goomba="goomba"
var koopa="koopa"
var mushroom="mushroom"
var star="star"
var fireflower="fireflower"
var coin="coin"
var mushroom1up="mushroom1up"
var fireball="fireball"
var coins6="coins6"
var box="box"
var brick='brick'
var brickPiece="brickPiece"
var pipe="pipe"
var bg='background'

var right="right"
var left="left"

#mario 数据
var mario_speed=180
var mario_max_speed=300		#跑的时候最大速度

var runAccel=8 #奔跑加速度
var friction=9	#摩檫力
var animation_speed=120	#动画速度
var gravity=1100	#重力
var gravityJump=600	#跳跃的时候重力

var dropSpeed=400 #下落最大速度
var jumpSpeed=400	#跳跃高度

const slideFriction=9 #滑行的加速度
const acceleration=8	#移动加速度
const runAcceleration=10 #跑的加速度
const marioWalkMaxSpeed=180 #走的时候最大速度
const marioRunMaxSpeed=350 #跑的时候最大速度
const marioAniSpeed=150
const marioGravity=1300 #重力
const marioJumpGravity=600
const marioJumpSpeed=430
const boxGravity=1400 #箱子重力

#图块类型
const tilesType=['del',"mario","goomba","koopa","brick","pipe"
			,"coin","bg","box"]

#图块 所有的图块
const tiles=['del',"mario","goomba","koopa","brick","pipe"
			,"coin","bg","box","box_blue",'box_grey','box_default']
			
const allTitle=[{'name':'del','type':'del'},
{'name':"mario",'type':'mario'},{'name':"koopa",'type':'koopa'},
{'name':"brick",'type':'brick'},{'name':"pipe",'type':'pipe'},
{'name':"coin",'type':'coin'},{'name':"bg",'type':'bg'},{
	'name':"box",'type':'box'},{'name':"box_blue",'type':'box'},
	{'name':"box_grey",'type':'box'},{'name':"box_default",'type':'box'}]
			
#图块属性
const tilesAttribute={
	"del":{
		"type": "del",
		"x": 0,
		"y": 0
	},
	"mario": {
		"type": "mario",
		"x": 0,
		"y": 0
	},
	"goomba": {
		"type": "goomba",
		"x": 0,
		"y": 0,
		'dir': 'left'
	},
	"koopa": {
		"type": "koopa",
		"x": 0,
		"y": 0,
		'dir': 'left'
	},

	"coin": {
		"type": "coin",
		"spriteIndex": 0,
		"x": 0,
		"y": 0
	},
	
	"box": {
		"type": "box",
		"spriteIndex": 0,
		"x": 0,
		"y": 0,
		"content": "mushroom",
		"visible": true
	},
	"box_blue": {
		"type": "box",
		"spriteIndex": 1,
		"x": 0,
		"y": 0,
		"content": "mushroom",
		"visible": true
	},
	"box_grey": {
		"type": "box",
		"spriteIndex": 2,
		"x": 0,
		"y": 0,
		"content": "mushroom",
		"visible": true
	},
	"box_default": {
		"type": "box",
		"spriteIndex": 3,
		"x": 0,
		"y": 0,
		"content": "mushroom",
		"visible": true
	},
	"brick": {
		"type": "brick",
		"spriteIndex": 0,
		"x": 0,
		"y": 0
	},
	"brick2": {
		"type": "brick",
		"spriteIndex": 1,
		"x": 0,
		"y": 0
	},
	"brick3": {
		"type": "brick",
		"spriteIndex": 2,
		"x": 0,
		"y": 0
	},
	"brick4": {
		"type": "brick",
		"spriteIndex": 3,
		"x": 0,
		"y": 0
	},
	"brick5": {
		"type": "brick",
		"spriteIndex": 4,
		"x": 0,
		"y": 0
	},
	"brick6": {
		"type": "brick",
		"spriteIndex": 5,
		"x": 0,
		"y": 0
	},
	"brick7": {
		"type": "brick",
		"spriteIndex": 6,
		"x": 0,
		"y": 0
	},
	"brick8": {
		"type": "brick",
		"spriteIndex": 7,
		"x": 0,
		"y": 0
	},
	"brick9": {
		"type": "brick",
		"spriteIndex": 8,
		"x": 0,
		"y": 0
	},
	"brick10": {
		"type": "brick",
		"spriteIndex": 9,
		"x": 0,
		"y": 0
	},
	"brick11": {
		"type": "brick",
		"spriteIndex": 10,
		"x": 0,
		"y": 0
	},
	"brick12": {
		"type": "brick",
		"spriteIndex": 11,
		"x": 0,
		"y": 0
	},
	"pipe": {
	"type": "pipe",
	"spriteIndex": 0,
	"x": 0,
	"y": 0,
	"rotate":0
	},
	"pipe1": {
	"type": "pipe",
	"spriteIndex": 1,
	"x": 0,
	"y": 0,
	"rotate":0
	},
	"pipe2": {
	"type": "pipe",
	"spriteIndex": 2,
	"x": 0,
	"y": 0,
	"rotate":0
	},
	"pipe3": {
	"type": "pipe",
	"spriteIndex": 3,
	"x": 0,
	"y": 0,
	"rotate":0
	},
	"pipe4": {
	"type": "pipe",
	"spriteIndex": 4,
	"x": 0,
	"y": 0,
	"rotate":0
	},
	"pipe5": {
	"type": "pipe",
	"spriteIndex": 5,
	"x": 0,
	"y": 0,
	"rotate":0
	},
	"pipe6": {
	"type": "pipe",
	"spriteIndex": 6,
	"x": 0,
	"y": 0,
	"rotate":0
	},
	"pipe7": {
	"type": "pipe",
	"spriteIndex": 7,
	"x": 0,
	"y": 0,
	"rotate":0
	},
	"pipe8": {
	"type": "pipe",
	"spriteIndex": 8,
	"x": 0,
	"y": 0,
	"rotate":0
	},
	"pipe9": {
	"type": "pipe",
	"spriteIndex": 9,
	"x": 0,
	"y": 0,
	"rotate":0
	},
	"bg": {
		"type": "bg",
		"spriteIndex": 0,
		"x": 0,
		"y": 0
	},
	"bg1": {
		"type": "bg",
		"spriteIndex": 1,
		"x": 0,
		"y": 0
	},
	"bg2": {
		"type": "bg",
		"spriteIndex": 2,
		"x": 0,
		"y": 0
	},
	"bg3": {
		"type": "bg",
		"spriteIndex": 3,
		"x": 0,
		"y": 0
	},
	"bg4": {
		"type": "bg",
		"spriteIndex": 4,
		"x": 0,
		"y": 0
	},
	"bg5": {
		"type": "bg",
		"spriteIndex": 5,
		"x": 0,
		"y": 0
	},
	"bg6": {
		"type": "bg",
		"spriteIndex": 6,
		"x": 0,
		"y": 0
	},
	"bg7": {
		"type": "bg",
		"spriteIndex": 7,
		"x": 0,
		"y": 0
	},
	"bg8": {
		"type": "bg",
		"spriteIndex": 8,
		"x": 0,
		"y": 0
	},
	"bg9": {
		"type": "bg",
		"spriteIndex": 9,
		"x": 0,
		"y": 0
	},
	"bg10": {
		"type": "bg",
		"spriteIndex": 10,
		"x": 0,
		"y": 0
	},
	"bg11": {
		"type": "bg",
		"spriteIndex": 11,
		"x": 0,
		"y": 0
	},
	"bg12": {
		"type": "bg",
		"spriteIndex": 12,
		"x": 0,
		"y": 0
	},
	"bg13": {
		"type": "bg",
		"spriteIndex": 13,
		"x": 0,
		"y": 0
	},
	"bg14": {
		"type": "bg",
		"spriteIndex": 14,
		"x": 0,
		"y": 0
	},
	"bg15": {
		"type": "bg",
		"spriteIndex": 15,
		"x": 0,
		"y": 0
	},
	"bg16": {
		"type": "bg",
		"spriteIndex": 16,
		"x": 0,
		"y": 0
	},
	"bg17": {
		"type": "bg",
		"spriteIndex": 17,
		"x": 0,
		"y": 0
	},
	"bg18": {
		"type": "bg",
		"spriteIndex": 18,
		"x": 0,
		"y": 0
	},
	"bg19": {
		"type": "bg",
		"spriteIndex": 19,
		"x": 0,
		"y": 0
	},
	"bg20": {
		"type": "bg",
		"spriteIndex": 20,
		"x": 0,
		"y": 0
	},
}
				
var mapTiles={
}

func _ready():
	for i in constants.tilesType:
		mapTiles[i]={}
	loadIcon()	
	pass


#载入方块的图片
func loadIcon():
	var dic=Directory.new()
	dic.open("res://icon")
	dic.list_dir_begin()
	while true:
		var file = dic.get_next()
		if file == "":
			break
#		print(file.get_extension())
#		print(dic.get_current_dir()+"/"+file)
#		print(file.get_file())
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
			pass	
	dic.list_dir_end()
	pass
