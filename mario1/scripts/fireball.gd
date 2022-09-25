extends "res://scripts/object.gd"

onready var ani=$ani
var playerId=0
var dir=constants.right
var rotate
var status=constants.fly
const speed=400

func _ready():
	mask=[constants.brick,constants.box,constants.pipe,
	constants.goomba,constants.koopa,constants.plant]
	debug=true
	type=constants.fireball
	rect=Rect2(Vector2(-5,-5),Vector2(10,10))
	gravity=constants.enemyGravity
	maxYVel=constants.fireballMaxYVel
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
		
	ani.play('fly')	
	pass

func _update(delta):
	if status==constants.fly:
		rotation_degrees+=5
#		yVel+=gravity*delta
#		position.x+=xVel*delta
#		position.y+=yVel*delta	
		pass
	elif status==constants.boom:	
		pass
	pass

func boom():
	if active:
		print('boom')
		active=false
		xVel=0
		yVel=0
		gravity=0
		status=constants.boom
		SoundsUtil.playBoom()
		ani.play('boom')
		z_index=5
		yield(ani,"animation_finished")
		destroy=true
#	queue_free()

func rightCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||constants.pipe:
		boom()
	elif obj.type==constants.goomba || obj.type==constants.koopa:
		
		pass	
	pass
	
func leftCollide(obj):	
	if obj.type==constants.brick || obj.type==constants.box||constants.pipe:
		boom()	
	elif obj.type==constants.goomba || obj.type==constants.koopa:
		
		pass
	pass
	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||constants.pipe:
		yVel=-speed
		return true
	pass

func ceilcollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||constants.pipe:
		yVel=1
	pass		
