extends "res://scripts/object.gd"



var maxHeight
var score=0 #显示分数

onready var _label=$Label

func _ready():
	active=false
	yVel=-70
	maxYVel=constants.marioMaxYVel 
	maxHeight=position.y-90
	_label.text=str(score)
	pass

func setPos(pos:Vector2):
	position=pos

func setScore(_score):
	score=_score

func checkMask(obj):
	return mask.has(obj)

func _update(delta):
	position.y+=yVel*delta
	if position.y<=maxHeight:
		destroy=true
	pass
