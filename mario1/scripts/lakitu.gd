extends "res://scripts/enemy.gd"

onready var ani=$ani
var preStatus
var xSpeed=20 #基本速度

func _ready():
	rect=Rect2(Vector2(-16,-16),Vector2(32,32))
	type=constants.lakitu
	maxYVel=constants.enemyMaxVel #y轴最大速度
	debug=true
	ani.position.y-=18
	status=constants.lakituIdle
	pass



func _update(delta):
	if status==constants.lakituIdle:
		if Game.getMario().size()>0:
			var m= Game.getMario()[0]
			if m.status!=constants.deadJump:
				var distance=m.position.x-position.x
				if distance<0:
					if abs(distance)>constants.lakituDistance:
						if dir==constants.right:
							xVel=-max(xSpeed,round(abs(distance))*2)
							dir=constants.left
						elif dir==constants.left:
							xVel=-xSpeed
							dir=constants.right
					else:
						if dir==constants.right:
							xVel=xSpeed
						elif dir==constants.left:
							xVel=-xSpeed
				elif distance>0:
					if abs(distance)>constants.lakituDistance:
						if dir==constants.right:
							xVel=xSpeed
							dir=constants.left
						elif dir==constants.left:	
							xVel=max(xSpeed,round(abs(distance))*2)
							dir=constants.right
					else:
						if dir==constants.right:
							xVel=xSpeed
						elif dir==constants.left:
							xVel=-xSpeed
					pass	
			if position.x+xVel*delta<0:
				dir=constants.right
		
		pass
	
	pass
	
func animation(type):
	if type=='idle':
		if spriteIndex==0:
			ani.play("idle_0")
		elif spriteIndex==1:
			ani.play("idle_1")	
		elif spriteIndex==2:	
			ani.play("idle_2")	
	elif type=='throw':
		if spriteIndex==0:
			ani.play("throw_0")
		elif spriteIndex==1:
			ani.play("throw_1")	
		elif spriteIndex==2:	
			ani.play("throw_2")	
		
				
	pass	
	
