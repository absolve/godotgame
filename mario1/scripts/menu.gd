extends Node2D

export var isgameover=false
export var coinnum=0
export var score=0
export var level="1-1"
export var nextLevel="1-1"
export var mario=0
export var num=3
var marioDeathPos={'x':-1,'y':-1}

onready var _title=$title
#onready var _lives=$img/num
onready var _lives=$ani/num
onready var _level=$world/level
#onready var _img=$img
onready var _gameover=$gameover
onready var _world=$world

onready var ani=$ani


var status=constants.nextLevel
var subLevel=""  #用来标记当前关卡的保存点的位置
var timer=0
var nextLevelTime=3*60
var gameEndTime=3.5*60

func _ready():
	_title.hideTime()
	_title.stopCoinAni()
	score=Game.playerData['score']
	level=Game.playerData['level']
	var file = File.new()
	if !file.file_exists("res://levels/"+level+".json"):
		isgameover=true
		print("地图",level,'不存在')
	num=Game.playerData['lives']
	if level.count("-")>=2:
		level=level.rsplit("-",true,1)[0]
	_title.setScore(score)
	_title.setCoin(Game.playerData['coin'])
	_title.setLevel(str(level))
	_level.text=str(level)
	_lives.text=str(num)

	if Game.playerData['mario']['big']:
		if Game.playerData['mario']['fire']:
			ani.play("fire")
		else:
			ani.play("big")	
	else:
		ani.play("small")		

	if num<=0:
		isgameover=true
	if isgameover:
		_world.hide()
#		_img.hide()
		ani.hide()
		_gameover.show()
		status=constants.gameEnd
		gameEnd()
	
func setData()->void:
	
	pass


func startLevel()->void:
	
	pass

func gameEnd():
	SoundsUtil.playGameover()
	yield(SoundsUtil.gameover,"finished")
	var scene=load("res://scenes/welcome.tscn")
	var temp=scene.instance()
	queue_free()
	set_process_input(false)
	get_tree().get_root().add_child(temp)
	set_process_input(true)
	pass

func _physics_process(delta):
	if status==constants.nextLevel:
		timer+=1
		if timer>nextLevelTime:
			var scene=load("res://scenes/mapNew.tscn")
			var temp=scene.instance()
			queue_free()
			set_process_input(false)
			get_tree().get_root().add_child(temp)
			set_process_input(true)
			status=constants.empty
		pass
	elif status==constants.gameEnd:
		pass
	elif status==constants.gameRestart:
		timer+=1
		if timer>nextLevelTime:
			var scene=load("res://scenes/mapNew.tscn")
			var temp=scene.instance()
			temp.marioDeathPos=marioDeathPos
			queue_free()
			set_process_input(false)
			get_tree().get_root().add_child(temp)
			set_process_input(true)
			status=constants.empty
