extends Node2D

export var isgameover=true
export var coinnum=0
export var score=0
export var level="1-1"
export var nextLevel="1-1"
export var mario=0
export var num=3

onready var _title=$title
onready var _lives=$img/num
onready var _level=$Label2/level
onready var _img=$img
onready var _gameover=$gameover

var status=constants.gameEnd
var subLevel=""  #用来标记当前关卡的保存点的位置

func _ready():
	_title.hideTime()
	_title.stopCoinAni()
	_title.setScore(score)
	_level.text=str(level)
	_lives.text=str(num)
	if isgameover:
		_img.hide()
		_gameover.show()

	
func setData()->void:
	
	pass


func startLevel()->void:
	
	pass



func _process(delta):
	
	pass
