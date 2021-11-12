extends "res://scripts/object.gd"

var status=constants.growing
var dir=constants.left
var oldPos=0
const speed=50
var spriteIndex=0 #0 1 是蘑菇
var content=constants.mushroom  #内容
onready var ani=$ani

func _ready():
	type=constants.mushroom
	debug=true
	self.rect=Rect2(Vector2(-16,-16),Vector2(32,32))	
	gravity=constants.marioGravity
	oldPos=position.y
	yVel=-speed
	ani.playing=true
	pass

func _update(delta):
	if status==constants.growing:
		growing(delta)
		pass
	elif status==constants.moving:	
		moving(delta)
	elif status==constants.stop:
		stop(delta)	
	elif status==constants.jumping:
		jumping(delta)
	pass

func growing(delta):
	if oldPos-position.y>=rect.size.y:
	#	yVel=0
		status=constants.moving
		if type==constants.fireflower:
			status=constants.stop
		elif type==constants.star:
			status=constants.jumping	
	else:	
		position.y+=yVel*delta	
	pass
	
func moving(delta):
	yVel+=gravity*delta
	if dir==constants.left:
		xVel=-speed
		pass
	else:
		xVel=speed
		pass
	position.x+=xVel*delta
	position.y+=yVel*delta		
	pass

func stop(delta):
	
	pass

func jumping(delta):
	pass
