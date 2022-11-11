extends "res://scripts/object.gd"

#关底boss 死亡时有7中不同形态

var dir=constants.left
var spriteIndex=0 #0普通颜色 1蓝色 2灰色
var aniIndex=0	#动画索引		
var fire_animation=['fire','fire_blue','fire_grey']
var walk_animation=['walk','walk_blue','walk_grey']
var status=constants.walking
var hp=5
var startX=0  #保存当前开始位置
var targetX=0  #目标位置
var jump=false
var timer=0
var jumpTimerDelay=140
var jumpVel=220
var moveVel=30
var fireTimer=0
var fireTimerDelay=180
var moveDir=constants.left

onready var ani=$ani

func _ready():
	randomize()
	debug=true
	mask=[constants.box,constants.brick,constants.bridge]
	rect=Rect2(Vector2(-32,-32),Vector2(64,64))
	type=constants.bowser
	maxYVel=constants.enemyMaxVel
	gravity=constants.bowserGravity
	startX=position.x
	targetX=startX-32*(randi()%5)
#	print(startX,' ',targetX)

	pass 


func _update(delta):
	if status==constants.walking:
#		animation('walk')

#		if Game.getMario().size()>0:
#			var m= Game.getMario()[0]
#			if m.status!=constants.deadJump:
#				if m.position.x<startX-32*7:
#					moveDir=constants.left
#				else:
#					moveDir=constants.right
		fireTimer+=1
		if fireTimer>fireTimerDelay-50:
			animation('fire')
			if fireTimer>fireTimerDelay:
				fireTimer=0
		else:
			animation('walk')
		
#		if moveDir==constants.left && position.x>startX-32*2:
#			xVel=-moveVel
#		elif moveDir==constants.right && position.x<startX+32*2:
#			xVel=moveVel
#		else:
#			xVel=0	
			
		if position.x>targetX:
			xVel=-moveVel
			if position.x+xVel*delta<=targetX:
				targetX=startX-32*(randi()%5)
		else:
			xVel=moveVel	
			if position.x+xVel*delta>=targetX:
				targetX=startX-32*(randi()%2)
			
	if isOnFloor:
		timer+=1
		if timer>jumpTimerDelay:
			yVel=-jumpVel
			timer=0
	pass

#动画
func animation(type):
	if type=='walk':
		ani.play(walk_animation[spriteIndex])
		pass
	elif type=='fire':
		ani.play(fire_animation[spriteIndex])

		
	if dir==constants.right && !ani.flip_h:
		ani.flip_h=true
	elif dir==constants.left && ani.flip_h:
		ani.flip_h=false		
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
