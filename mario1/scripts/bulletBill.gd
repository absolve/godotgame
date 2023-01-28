extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus
var xSpeed=100

func _ready():
	type=constants.bulletBill
	animation('fly')
	pass

func _update(delta):
	if status==constants.bulletBillFly:
		if dir==constants.left:
			xVel=-xSpeed
		else:
			xVel=xSpeed
		pass
	pass

func animation(type):
	if type=='fly':
		if spriteIndex==0:
			ani.play("0")
		elif spriteIndex==1:
			ani.play("1")
		elif spriteIndex==2:
			ani.play("2")	
		elif spriteIndex==3:
			ani.play("3")	
			
	if dir==constants.left:
		ani.flip_h=false
	else:
		ani.flip_h=true	
