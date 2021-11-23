extends "res://scripts/enemy.gd"


onready var ani=$ani

func _ready():
	debug=true
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	gravity=constants.marioGravity
	type=constants.goomba
	if dir==constants.left:
		xVel=-50
	else:
		xVel=50
		
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


func startDeathJump():
	.startDeathJump()
	ani.playing=false
	ani.flip_v=true
	ani.frame=0
	z_index=2
	status=constants.deadJump
	pass

func pause():
	ani.stop()

func resume():
	ani.play()	
