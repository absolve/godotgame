extends "res://scripts/enemy.gd"

onready var ani=$ani
onready var fireSound=$fire
var preStatus
var xSpeed=190

func _ready():
	type=constants.bulletBill
	rect=Rect2(Vector2(-16,-15),Vector2(32,30))
	var fire1=fireSound.stream as AudioStreamOGGVorbis
	fire1.set_loop(false)
	fireSound.play()
	animation('fly')
	status=constants.bulletBillFly
	maxYVel=constants.enemyMaxVel
	pass

func _update(delta):
	if status==constants.bulletBillFly:
		if dir==constants.left:
			xVel=-xSpeed
		else:
			xVel=xSpeed
	elif status==constants.deadJump:
		deathJump(delta)
		pass
	pass

func startDeathJump(_dir=constants.left):
#	ani.playing=false
#	ani.flip_v=true
#	ani.frame=0

	gravity=constants.deathJumpGravity
	status=constants.deadJump
	_dead=true
	active=false
	xVel=0
	z_index=5

func jumpedOn():
	startDeathJump()
	pass

func pause():
	preStatus=status
	status=constants.stop
	active=false
	ani.stop()

func resume():
	status=preStatus
	ani.play()
	if !_dead:
		active=true


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
