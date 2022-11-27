extends "res://scripts/object.gd"

onready var ani=$ani
var playerId=0
var dir=constants.right
var rotate
var status=constants.fly
const speed=480
const ySpeed=400

func _ready():
	mask=[constants.brick,constants.box,constants.pipe,
	constants.goomba,constants.koopa,constants.plant,constants.bridge,constants.bowser]
#	debug=true
	type=constants.fireball
	rect=Rect2(Vector2(-5,-5),Vector2(10,10))
	gravity=constants.fireballGravity
	maxYVel=constants.fireballMaxYVel
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
		
	ani.play('fly')	
	pass

func _update(delta):
	if status==constants.fly:
		rotation_degrees+=10
#		yVel+=gravity*delta
#		position.x+=xVel*delta
#		position.y+=yVel*delta	
		pass
	elif status==constants.boom:	
		pass
	pass

func boom():
	if active:
#		print('boom')
		active=false
		xVel=0
		yVel=0
		gravity=0
		status=constants.boom
#		SoundsUtil.playBoom()
		ani.play('boom')
		z_index=5
		yield(ani,"animation_finished")
		destroy=true


func rightCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		boom()
		SoundsUtil.playBoom()
	elif obj.type==constants.goomba || obj.type==constants.koopa:
		if !obj._dead&&status!=constants.boom:
			obj.startDeathJump(constants.right)
			Game.addScore(position)
			boom()
			SoundsUtil.playShoot()
		pass	
	elif obj.type==constants.bowser:
		if status!=constants.boom:
			boom()	
			SoundsUtil.playBoom()
			obj.hit()
	pass
	
func leftCollide(obj):	
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		boom()	
		SoundsUtil.playBoom()
	elif obj.type==constants.goomba || obj.type==constants.koopa:
		if !obj._dead&&status!=constants.boom:
			obj.startDeathJump()
			Game.addScore(position)
			boom()
			SoundsUtil.playShoot()
	elif obj.type==constants.bowser:
		if status!=constants.boom:
			boom()	
			SoundsUtil.playBoom()
			obj.hit()
	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe\
		||obj.type==constants.bridge:
		yVel=-ySpeed
		return true
	elif obj.type==constants.goomba || obj.type==constants.koopa:
		if !obj._dead&&status!=constants.boom:
			obj.startDeathJump()
			Game.addScore(position)
			boom()
			SoundsUtil.playShoot()
	elif obj.type==constants.bowser:
		if status!=constants.boom:
			boom()	
			SoundsUtil.playBoom()
			obj.hit()

func ceilcollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		yVel=1
	elif obj.type==constants.goomba || obj.type==constants.koopa:
		if !obj._dead&&status!=constants.boom:
			obj.startDeathJump()
			Game.addScore(position)
			boom()
			SoundsUtil.playShoot()
	elif obj.type==constants.bowser:
		if status!=constants.boom:
			boom()	
			SoundsUtil.playBoom()	
			obj.hit()	
