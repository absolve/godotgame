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


#图块对应的属性
var tiles=['del',"mario","goomba","koopa","box","brick","pipe","coin","bg"]
var tilesAttribute={"mario":{"x":0,"y":0},"goomba":{"x":0,"y":0},
					"koopa":{"x":0,"y":0},"box":{
												"type":"box",
												"spriteIndex":0,
												"x":0,
												"y":0,
												"content":"mushroom",
												"visible":true
											},
											"pipe":{"type":"pipe",
												"spriteIndex":0,
												"x":0,
												"y":0},
				"brick":{
					"type":"brick",
												"spriteIndex":0,
												"x":0,
												"y":0
				},
				"coin":{
					"type":"coin",
					"spriteIndex":0,
					"x":0,
					"y":0
				},"bg":{
					"type":"bg",
					"spriteIndex":0,
					"x":0,
					"y":0
				}}
func _ready():
	pass 


