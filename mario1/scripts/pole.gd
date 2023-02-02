extends "res://scripts/object.gd"

onready var flag=$flag
onready var lens=$len
onready var score=$score  #用来显示拉旗的分数
onready var top1=$top1
var poleLen=10
var poleImg=preload("res://sprites/flag1.png")
var poleImg1=preload("res://sprites/flag2.png")
var poleImg2=preload("res://sprites/flag3.png")
var status=constants.empty
var speed=160
var spriteIndex=0

func _ready():
#	debug=true
	addPoleLen()
	type=constants.pole
	rect=Rect2(Vector2(-5,0),Vector2(10,poleLen*32))	
	
	if spriteIndex==0:
		top1.play("0")
	elif spriteIndex==1:	
		top1.play("1")
	elif spriteIndex==2:
		top1.play("2")	
	pass



func getCenterY():
	return position.y+rect.size.y/2
	
func getTop():
	return position.y

func getBottom():
	return position.y+poleLen*32

#添加旗杆长度
func addPoleLen():
	for i in range(poleLen):
		var temp=Sprite.new()
		if spriteIndex==0:
			temp.texture=poleImg
		elif spriteIndex==1:
			temp.texture=poleImg1
		elif spriteIndex==2:	
			temp.texture=poleImg2	
		temp.position=Vector2(0,33+i*32)
		lens.add_child(temp)
	pass

func startFall():
	status=constants.flagLanding

func showScore(s):
	score.visible=true
	score._label.text=str(s)
	score.position.y=poleLen*32-20
	score._label.visible=true
	pass


func _update(delta):
	if status==constants.flagLanding:
		flag.position.y+=speed*delta
		score.position.y-=speed*delta
		if flag.position.y>=poleLen*32:
			status=constants.empty
			Game.emit_signal("flagEnd")


