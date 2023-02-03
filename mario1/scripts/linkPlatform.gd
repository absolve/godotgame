extends "res://scripts/object.gd"


onready var left=$left
onready var right=$right

#var lineColor=Color.aliceblue
var distance=32 #距离
var spriteIndex=0
var rightPlatform
var leftPlatform
var lineColor={"0":"#ffcec6","1":'#bbefee','2':'#ffffff','3':'#bff9ad'}

func _ready():
	active=false
	type=constants.linkPlatform
	
	left.position.x-=distance/2
	right.position.x+=distance/2
	
	
	pass

func _update(delta):
	
	pass



func _draw():
	draw_line(left.position-Vector2(0,6),right.position-Vector2(0,6),Color(lineColor['0']),5)
	
	
	
	pass
