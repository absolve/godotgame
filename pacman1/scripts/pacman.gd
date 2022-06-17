extends "res://scripts/object.gd"




func _ready():
	
	pass # Replace with function body.


func _update(dt):
#	print(directions[dir])
	position+=directions[dir]*speed*dt
	var tempDir = getKey()
	if arriveTargetNode():
		node=target
		target=getNewTargetNode(tempDir)
		if target!=node:
			dir = tempDir
		else:
			target=getNewTargetNode(dir)

#		if target==node:
#			dir=Constants.stop
		position=node.position
	else:
		if getOppositeDirection(tempDir):
			reverseDirection()
		pass
#	._update(dt)
	pass


func _draw():
	draw_circle(Vector2.ZERO,15,Color.yellow)
	pass
