extends "res://scripts/object.gd"

onready var ani=$ani
var playerId=0
var dir=constants.right
var rotate
var status=constants.fly
const speed=400

func _ready():
	debug=true
	type=constants.fireball
	rect=Rect2(Vector2(-4,-4),Vector2(8,8))
	gravity=constants.enemyGravity
	if dir==constants.left:
		xVel=-400
	else:
		xVel=400
		
	ani.play('fly')	
	pass

func _update(delta):
	if status==constants.fly:
		rotation_degrees+=5
		yVel+=gravity*delta
		position.x+=xVel*delta
		position.y+=yVel*delta	
		pass
	elif status==constants.boom:	
		pass
	pass

func boom():
	status=constants.boom
#	SoundsUtil.playBoom()
	ani.play('boom')
	z_index=2
	yield(ani,"animation_finished")
	queue_free()
