extends Node


var _author="LittlePuzzle  eric zingeler"


#游戏状态
enum state {STATE_IDLE, STATE_START, STATE_OVER}
#方块状态
enum blockState{FAST,SLOW,STOP}
#玩家
enum playerState{IDLE,STAND,JUMP,DEAD}


signal blockExit 

var sound=true	#声音开关

var blockColor=['#a5aeb3','#22bdd1','#2a6aff','#ffc827','#00b264',
				'#5f6380','#ff702a','#fdfbc8','#ff4352','#ffa195']
var lineColor = ["#5f6380"]


var group={colorDot="colorDot",scoreDot="scoreDot"}
	
	
func _ready():
	pass # Replace with function body.


