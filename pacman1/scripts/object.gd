extends Node2D



var target  #目标
var speed=100 #速度
var node  #开始的起点
var directions={Constants.up:Vector2(0,-1),Constants.down:Vector2(0,1),
				Constants.left:Vector2(-1,0),Constants.right:Vector2(1,0),
				Constants.stop:Vector2(0,0)}
var dir=Constants.stop  #方向

func _ready():
	
	pass # Replace with function body.

#设置开始的节点
func setStartNode(node):
	self.node=node
	target=node
	position=node.position
	pass


func _update(dt):
	var tempDir = getKey()
	if arriveTargetNode():
		node=target
		target=getNewTargetNode(tempDir)
		if target!=node:
			dir = tempDir
		else:
			dir=Constants.stop

		position=node.position
	else:
		if getOppositeDirection(tempDir):
			reverseDirection()
		pass
	pass
	
func arriveTargetNode():
	if target:
#		var v1=target.position-node.position
#		var v2=position-node.position
		var nodeTarget=target.position.distance_to(node.position)
		var nodeSelf=position.distance_to(node.position)
#		print(nodeSelf,'----',nodeTarget)
#		print(nodeSelf)
		return nodeSelf>=nodeTarget
	return false
	pass	
	
func getNewTargetNode(dir):
	if dir!=Constants.stop:
		if node and node.neighbors[dir]:
			return node.neighbors[dir]
	return node
	pass
	
func getOppositeDirection(dir):
	if dir!=Constants.stop:
		if (dir ==Constants.left||dir ==Constants.right)\
		&&(self.dir==Constants.left||self.dir==Constants.right):
			if self.dir!=dir:
				return true
		elif (dir ==Constants.up||dir ==Constants.down)\
		&&(self.dir==Constants.up||self.dir==Constants.down):
			if self.dir!=dir:
				return true
	return false
	pass

func reverseDirection():
	if dir==Constants.left:
		dir=Constants.right
	elif dir==	Constants.right:
		dir=Constants.left
	elif dir==Constants.up:
		dir=Constants.down
	elif dir==Constants.down:
		dir=Constants.up
	var temp=node
	node=target
	target=	temp		
	
func getKey():
	if Input.is_action_pressed("ui_left"):
#		print('ui_left')
		return Constants.left
	if Input.is_action_pressed("ui_right"):
#		print('ui_right')
		return Constants.right
	if Input.is_action_pressed("ui_up"):
		return Constants.up
	if 	Input.is_action_pressed("ui_down"):
		return Constants.down
	
	return Constants.stop
	pass
