extends "res://scripts/enemy.gd"

#const slidingSpeed=400
#onready var ani=$ani
#var reviveStartTime=0
#var reviveTime=600 #变成壳然后变回乌龟的时间
#var combo=0  #分数连击
#
#
#func _ready():
#	mask=[constants.fireball,constants.box,constants.brick
#		,constants.platform,constants.pipe,constants.koopa,constants.goomba]
#	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
#	maxYVel=constants.enemyMaxVel #y轴最大速度
#	gravity=constants.enemyGravity
#	type=constants.beetle
#	if dir==constants.left:
#		xVel=-speed
#	else:
#		xVel=speed
#	animation("walk")		
#	pass
#
#func _update(delta):
#	if status==constants.walking:
#		walking(delta)
#	elif status==constants.sliding:
#		shellSliding(delta)
#	elif status==constants.dead:
#		dead(delta)
#	elif status==constants.deadJump:
#		deathJump(delta)
#	elif status==constants.shell:
#		reviveStartTime+=1
#		if reviveTime-reviveStartTime<200:
#			status=constants.revive
#			animation("revive")	
#		pass
#	elif status==constants.stop:
#		pass
#	elif status==constants.revive:
#		reviveStartTime+=1
#		if reviveTime-reviveStartTime<0:
#			status=constants.walking
#			reviveStartTime=0
#			animation("walk")	
#			ani.position.y=-18
#		pass
#	pass
#
#func shellSliding(delta):
#	if dir==constants.left:
#		xVel=-slidingSpeed
#	else:
#		xVel=slidingSpeed	
#	pass
#
#func jumpedOn():
#	if status==constants.walking:
#		animation("shell")
#		if dir==constants.left:
#			dir=constants.right
#		else:
#			dir=constants.left	
#		xVel=0	
#		reviveStartTime=0
#		status=constants.shell
#		ani.position.y=0
#	elif status==constants.shell|| status==constants.revive:
#		startSliding()
#	elif status==constants.sliding:
#		status=constants.shell
#		xVel=0
#		reviveStartTime=0
#		combo=0
#
#func startDeathJump(_dir=constants.left):
#	dir=_dir
#	ani.position.y=0
#	animation("shell")
#	.startDeathJump()
#	ani.playing=false
#	ani.flip_v=true
#	ani.frame=0
#	_dead=true
#	active=false
#
#func startSliding(_dir=constants.left):
#	animation("shell")
#	status=constants.sliding	
#	dir=_dir
#
#func pause():
#	ani.stop()
#
#func resume():
#	if status!=constants.dead&&status!=constants.deadJump:
#		ani.play()	
#
#
#func animation(type):
#	if type=="walk":
#		if spriteIndex==0:
#			ani.play("walk")
#		elif spriteIndex==1:
#			ani.play("walk_blue")	
#		elif spriteIndex==2:	
#			ani.play("walk_grey")	
#		elif spriteIndex==3:
#			ani.play("walk_red")	
#	elif type=="shell":	
#		if spriteIndex==0:
#			ani.play("shell")
#		elif spriteIndex==1:
#			ani.play("shell_blue")	
#		elif spriteIndex==2:	
#			ani.play("shell_grey")	
#		elif spriteIndex==3:
#			ani.play("shell_red")	
#	elif type=="revive":
#		if spriteIndex==0:
#			ani.play("revive")
#		elif spriteIndex==1:
#			ani.play("revive_blue")	
#		elif spriteIndex==2:	
#			ani.play("revive_grey")	
#		elif spriteIndex==3:
#			ani.play("revive_red")		
