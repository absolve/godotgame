extends "res://scripts/object.gd"

#关底boss 死亡时有7中不同形态

var dir=constants.left
var spriteIndex=0 #0普通颜色 1蓝色 2灰色
var aniIndex=0	#动画索引		
var fire_animation=['fire','fire_blue','fire_grey']
var walk_animation=['walk','walk_blue','walk_grey']
var status=constants.walking
var hp=5

onready var ani=$ani

func _ready():
	debug=true
	mask=[constants.box,constants.brick,constants.bridge]
	rect=Rect2(Vector2(-32,-32),Vector2(64,64))
	type=constants.bowser
	maxYVel=constants.enemyMaxVel
	gravity=constants.enemyGravity
	pass 


func _update(delta):
	if status==constants.walking:
		animation('walk')
		pass
	
	pass

#动画
func animation(type):
	if type=='walk':
		ani.play(walk_animation[spriteIndex])
		pass
	elif type=='fire':
		ani.play(fire_animation[spriteIndex])
		
		pass	
	pass

func rightCollide(obj):
	
	pass
	
func leftCollide(obj):
	
	pass
	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box|| obj.type==constants.bridge:	
		return true
	pass
			
func ceilcollide(obj):
	pass
