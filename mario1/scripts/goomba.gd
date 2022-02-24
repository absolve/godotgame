extends "res://scripts/enemy.gd"


onready var ani=$ani
var preStatus
const speed=55

func _ready():
#	debug=true
	._ready()
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
#	gravity=constants.enemyGravity
	type=constants.goomba
#	status=constants.stop
	if dir==constants.left:
		xVel=-speed
	else:
		xVel=speed
		
	if spriteIndex==0:
		ani.play("walk")
	elif spriteIndex==1:
		ani.play("walk_blue")	
	elif spriteIndex==2:	
		ani.play("walk_grey")	
	pass

func _update(delta):
	if status==constants.walking:
		walking(delta)
	elif status==constants.dead:
		dead(delta)
	elif status==constants.deadJump:
		deathJump(delta)
	elif status==constants.stop:
		pass
	pass

	
func jumpedOn():
	if spriteIndex==0:
		ani.play("dead")
	elif spriteIndex==1:
		ani.play("dead_blue")	
	elif spriteIndex==2:	
		ani.play("dead_grey")	
	status=constants.dead	
	pass


func startDeathJump(_dir=constants.left):
	dir=_dir
	.startDeathJump()
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
#	z_index=3
#	status=constants.deadJump
	pass

func pause():
	preStatus=status
	status=constants.stop
	ani.stop()

func resume():
	ani.play()	
	status=preStatus
