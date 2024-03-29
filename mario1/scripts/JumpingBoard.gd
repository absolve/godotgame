extends "res://scripts/object.gd"

var spriteIndex=0
var status=constants.empty
var timer=0
var timerDelta=8

onready var ani=$ani

func _ready():
	active=false
#	debug=true
	rect=Rect2(Vector2(-16,-32),Vector2(32,64))
	type=constants.jumpingBoard
	if spriteIndex==0:
		ani.play("0")
	elif spriteIndex==1:
		ani.play("1")	
	else:
		ani.play("0")	
	ani.stop()
	
func getLeft()->float:
	return position.x-rect.size.x/2+1

func getRight()->float:
	return position.x+rect.size.x/2-1

func _update(delta):
	if status==constants.boardStretch:
		timer+=1
		if timer>timerDelta:
			timer=0
			status=constants.empty
			ani.frame=0
		ani.frame=timer/2
	


func stretch():
	status=constants.boardStretch
