extends "res://scripts/object.gd"

onready var ani=$ani

var spriteIndex=0
var fireballImg=preload("res://sprites/fireball2.png")
var _rotation=0
var angularSpeed:float = 1  #角速度
var radius:float=140 #半径
var angle:float=0
var aroundPos  #围绕的点
var status=constants.rotate

func _ready():
	debug=true
	active=false
	rect=Rect2(Vector2(-8,-8),Vector2(16,16))
	type=constants.spinFireball
	aroundPos=position
#	rotation_degrees=40
	pass # Replace with function body.

func _update(delta):
	if status==constants.rotate:
		_rotation+=10
		if _rotation>360:
			_rotation=0
		ani.rotation_degrees=_rotation
		
		angle+=angularSpeed*delta
		if angle>360:
			angle-=360
		position=Vector2(radius*sin(angle),radius*cos(angle))+aroundPos
	pass

func pause():
	status=constants.stop


func resume():
	status=constants.rotate
