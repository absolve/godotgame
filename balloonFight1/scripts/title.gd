extends Control


export var level=0
export var p1Score=0
export var p2Score=0
export var topScore=0

onready var _pauseLabel=$HBoxContainer/VBoxContainer2/pauseLabel
onready var _p1Score=$HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/p1Score
onready var _p2Score=$HBoxContainer/VBoxContainer4/VBoxContainer3/p2Score
onready var _topScore=$HBoxContainer/VBoxContainer2/pauseLabel
onready var _p1Live=$HBoxContainer/VBoxContainer/VBoxContainer/p1Live
onready var _p2Live=$HBoxContainer/VBoxContainer4/p2Live

var img=preload("res://sprites/lifeBalloon1.png")

func _ready():
	setLevel()
#	setPlayerLives(1,3)

func setLevel():
	_pauseLabel.text="phase-%02d"%level

func setPlayerLives(id=1,num:int=0):
	if id==1:
		for i in range(num):
			var temp=TextureRect.new()
			temp.texture=img
			_p1Live.add_child(temp)
	elif id==2:
		for i in range(num):
			var temp=TextureRect.new()
			temp.texture=img
			_p2Live.add_child(temp)
	
func setPlayerScore(id:int,score:int):
	if id==1:
		_p1Score.text='%06d'%score
	elif id==2:	
		_p2Score.text='%06d'%score


func setPause(isPause=false):
	if isPause:
		_pauseLabel.visible=true
	else:
		_pauseLabel.visible=false
