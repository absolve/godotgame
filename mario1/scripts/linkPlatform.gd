extends "res://scripts/object.gd"


onready var left=$left
onready var right=$right

#var lineColor=Color.aliceblue
var status=constants.linkPlatformIdle
var distance=32 #距离
var spriteIndex=0
var rightPlatform
var leftPlatform
var lineColor={"0":"#ffcec6","1":'#bbefee','2':'#ffffff','3':'#bff9ad'}
var leftHeight=3	#左边高度
var rightHeight=3   #右边高度
var lens=3  #平台长度
var leftCount=0
var rightCount=0
var leftPlatformYPos
var rightPlatformYPos


var staticPlatform=preload("res://scenes/staticPlatform.tscn")

func _ready():
	active=false
	type=constants.linkPlatform
	
	left.position.x-=distance/2
	right.position.x+=distance/2
	
	leftPlatform= staticPlatform.instance()
	leftPlatform.position.x=-distance/2+position.x-16
	leftPlatform.position.y=leftHeight*32+position.y
#	print(position.y)
#	print(leftPlatform.position.y)
	leftPlatform.lens=lens
	leftPlatform.linkPlatform=self
	Game.addObj(leftPlatform)
	leftPlatformYPos=leftPlatform.position.y
	
	rightPlatform=staticPlatform.instance()
	rightPlatform.position.x=distance/2+position.x+16
	rightPlatform.position.y=rightHeight*32+position.y
	rightPlatform.lens=lens
	rightPlatform.linkPlatform=self
	rightPlatform.side=constants.right
	Game.addObj(rightPlatform)
	rightPlatformYPos=rightPlatform.position.y
	pass

func _update(delta):
	if status==constants.linkPlatformIdle:
		update()
		if leftCount>rightCount:
			if leftPlatform!=null&&is_instance_valid(leftPlatform)\
				&&leftPlatform.status==constants.platformIdle:
				leftPlatform.yVel+=constants.staticPlatformAcc*delta
			if rightPlatform!=null && is_instance_valid(rightPlatform)\
				&&rightPlatform.status==constants.platformIdle:		
				rightPlatform.yVel+=-constants.staticPlatformAcc*delta
		elif leftCount<rightCount:
			if leftPlatform!=null&&is_instance_valid(leftPlatform)\
				&&leftPlatform.status==constants.platformIdle:
				leftPlatform.yVel+=-constants.staticPlatformAcc*delta
			if rightPlatform!=null && is_instance_valid(rightPlatform)\
				&&rightPlatform.status==constants.platformIdle:	
				rightPlatform.yVel+=constants.staticPlatformAcc*delta
		else:
			if leftPlatform!=null&&is_instance_valid(leftPlatform)\
				&&leftPlatform.status==constants.platformIdle:
				if leftPlatform.yVel>0:
					leftPlatform.yVel-=constants.staticPlatformAcc*delta
					if leftPlatform.yVel<=0:
						leftPlatform.yVel=0
				elif leftPlatform.yVel<0:
					leftPlatform.yVel+=constants.staticPlatformAcc*delta
					if leftPlatform.yVel>=0:
						leftPlatform.yVel=0
						
			if rightPlatform!=null && is_instance_valid(rightPlatform)\
				&&rightPlatform.status==constants.platformIdle:
				if rightPlatform.yVel>0:
					rightPlatform.yVel-=constants.staticPlatformAcc*delta
					if rightPlatform.yVel<=0:
						rightPlatform.yVel=0
				elif rightPlatform.yVel<0:
					rightPlatform.yVel+=constants.staticPlatformAcc*delta
					if rightPlatform.yVel>=0:
						rightPlatform.yVel=0
		
					
		if rightPlatform!=null && is_instance_valid(rightPlatform)\
			&&rightPlatform.status==constants.platformIdle:
			rightPlatformYPos=rightPlatform.position.y-position.y
			if rightPlatform.position.y<position.y+16:
				rightPlatform.status=constants.platformFall
				rightPlatform.yVel=abs(rightPlatform.yVel)
			
		if leftPlatform!=null&&is_instance_valid(leftPlatform)\
			&&leftPlatform.status==constants.platformIdle:
			leftPlatformYPos=leftPlatform.position.y-position.y
			if leftPlatform.position.y<position.y+16:
				leftPlatform.status=constants.platformFall
				leftPlatform.yVel=abs(leftPlatform.yVel)


func leftCallback(i):
	leftCount=i
	
func rightCallback(i):
	rightCount=i

func _draw():
	draw_line(left.position-Vector2(0,6),right.position-Vector2(0,6),Color(lineColor['0']),5)
	
	draw_line(left.position-Vector2(16,0),Vector2(left.position.x,leftPlatformYPos)-Vector2(16,-8),Color(lineColor['0']),5)	
	draw_line(right.position+Vector2(16,0),Vector2(right.position.x,rightPlatformYPos)+Vector2(16,-8),Color(lineColor['0']),5)
