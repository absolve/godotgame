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
	constants.goomba,constants.koopa,constants.plant,
	constants.bridge,constants.bowser,constants.lakitu,constants.hammerBro,
	constants.bloober,constants.cheapcheap]
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

func hitEnemy(obj):
	if obj.type==constants.goomba || obj.type==constants.koopa||obj.type==constants.spiny\
		||obj.type==constants.bloober||obj.type==constants.cheapcheap\
		||obj.type==constants.lakitu||obj.type==constants.hammerBro||obj.type==constants.plant:
		if !obj._dead&&status!=constants.boom:
			if position.x>obj.position.x:
				obj.startDeathJump()
			else:	
				obj.startDeathJump(constants.right)
			if constants.fireBallScore.has(obj.type):
				Game.addScore(position,constants.fireBallScore[obj.type])
			else:	
				Game.addScore(position)
#			boom()
			SoundsUtil.playShoot()
	elif obj.type==constants.bowser:
		if status!=constants.boom:
			boom()	
#			SoundsUtil.playBoom()
			obj.hit()
			
#			Game.addScore(position,5000)
#	elif obj.type==constants.plant:
#		if !obj._dead&&status!=constants.boom:
#			obj.hit()
#			boom()	
##			SoundsUtil.playBoom()
#			Game.addScore(position,200)
#	elif obj.type==constants.bloober||obj.type==constants.cheapcheap\
#		||obj.type==constants.lakitu||obj.type==constants.hammerBro:
#		if !obj._dead&&status!=constants.boom:
#			if position.x>obj.position.x:
#				obj.startDeathJump()
#			else:	
#				obj.startDeathJump(constants.right)
#			Game.addScore(position)
#			boom()
#		pass
	elif obj.type==constants.beetle||obj.type==constants.bulletBill:
		if status!=constants.boom:
			boom()

func rightCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		boom()
		SoundsUtil.playBoom()
	elif obj.type==constants.goomba || obj.type==constants.koopa||obj.type==constants.bowser\
		||obj.type==constants.plant||obj.type==constants.bloober||obj.type==constants.cheapcheap\
		||obj.type==constants.lakitu||obj.type==constants.hammerBro:
		hitEnemy(obj)	
#	elif obj.type==constants.goomba || obj.type==constants.koopa:
#		if !obj._dead&&status!=constants.boom:
#			obj.startDeathJump(constants.right)
#			Game.addScore(position)
#			boom()
#			SoundsUtil.playShoot()
#		pass	
#	elif obj.type==constants.bowser:
#		if status!=constants.boom:
#			boom()	
##			SoundsUtil.playBoom()
#			obj.hit()
#			Game.addScore(position,5000)
#	elif obj.type==constants.plant:
#		if !obj._dead&&status!=constants.boom:
#			obj.hit()
#			boom()	
##			SoundsUtil.playBoom()
#			Game.addScore(position,200)
		
	pass
	
func leftCollide(obj):	
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		boom()	
		SoundsUtil.playBoom()
	elif obj.type==constants.goomba || obj.type==constants.koopa||obj.type==constants.bowser\
		||obj.type==constants.plant||obj.type==constants.bloober||obj.type==constants.cheapcheap\
		||obj.type==constants.lakitu||obj.type==constants.hammerBro:
		hitEnemy(obj)	
	
func floorCollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe\
		||obj.type==constants.bridge:
		yVel=-ySpeed
		return true
	elif obj.type==constants.goomba || obj.type==constants.koopa||obj.type==constants.bowser\
		||obj.type==constants.plant||obj.type==constants.bloober||obj.type==constants.cheapcheap\
		||obj.type==constants.lakitu||obj.type==constants.hammerBro:
		hitEnemy(obj)


func ceilcollide(obj):
	if obj.type==constants.brick || obj.type==constants.box||obj.type==constants.pipe:
		yVel=1
	elif obj.type==constants.goomba || obj.type==constants.koopa||obj.type==constants.bowser\
		||obj.type==constants.plant||obj.type==constants.bloober||obj.type==constants.cheapcheap\
		||obj.type==constants.lakitu||obj.type==constants.hammerBro:
		hitEnemy(obj)	
