extends Node


var _author="LittlePuzzle  eric zingeler"

var mainScene="res://scenes/welcome.tscn"

#游戏状态
enum state {STATE_IDLE, STATE_START, STATE_OVER,STATE_HELP,
			STATE_NEWSCORE,STATE_PAUSE,STATE_RESUME,STATE_PASS,STATE_SCORE}
#方块状态
enum blockState{FAST,SLOW,STOP,SLOWMOVE,SHAKE}
#玩家
enum playerState{IDLE,STAND,JUMP,DEAD}

var nextState=state.STATE_IDLE

signal blockExit(pos)

var sound=true	#声音开关

var blockColor=['#a5aeb3','#22bdd1','#2a6aff','#ffc827','#00b264',
				'#5f6380','#ff702a','#fdfbc8','#ff4352','#ffa195']
var lineColor = ["#5f6380"]
var group={colorDot="colorDot",scoreDot="scoreDot"}
	
var words=['hello world','debug!!!','say no']	
	
const FILE_NAME = "user://game-data.json"

#保存的数据
var data = {
	"best_round": 0,
	"last_round": 0,
	"rounds_played": 0,
	"avg_per_round":0,
	"colors_earned":0,
	"sound":true
}

	
func _ready():
	pass # Replace with function body.


#更改场景
func changeScene(stagePath):
	Splash.find_node("ani").play("moveIn")
	set_process_input(false)
	get_tree().change_scene(stagePath)
	set_process_input(true)
	Splash.find_node("ani").play("moveOut")

#保存数据
func save(data):
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(data))
	file.close()

#载入文件
func load(dataFile):
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			dataFile = data
		else:
			printerr("Corrupted data!")
	else:
		save(data)  #保存数据
		printerr("No saved data!")
