extends Node2D



var joints=[]
var dots=[]

var dot = preload("res://scenes/dot.tscn")
func _ready():
	randomize()
	$top.add_to_group(Game.group["colorDot"])


#添加三个分数球
func add3Dot(color:Array):
	for i in range(3):
		var temp = dot.instance()
		temp.position.x=120+i*40+rand_range(-1,1)
		temp.position.y=-16
		temp.name=str("dot",i)
		temp.add_to_group(Game.group["colorDot"])
		temp.setColor(color[i])#设置颜色
	
		var joint= DampedSpringJoint2D.new()
		joint.length=15
		joint.rest_length=5
		joint.stiffness=15
		joint.damping=1
		joint.position.x=120+i*40
		joint.position.y=-5
		joint.node_a=NodePath("../top")
		joint.node_b=NodePath(str("../",temp.name))
		add_child(temp)
		add_child(joint)
		dots.append(temp)
		joints.append(joint)


func addAllJoint():
	for i in range(10):
		var joint= DampedSpringJoint2D.new()
		joint.length=10
		joint.rest_length=0
		
		joint.damping=1
		
		joint.node_a=NodePath("../top")
		joint.name=str("joint",i)
		add_child(joint)
		joints.append(joint)
		if i>=5:
			joint.position.x=60+(i-5)%5*50
			joint.position.y=-20
			joint.stiffness=5.5
		else:
			joint.position.x=60+i%5*50
			joint.position.y=-5	
			joint.stiffness=8


#添加一个新的
func addDot(color:String):
	var size = dots.size()
	if size>=10:
		return
	if size>=5:
		var temp = dot.instance()
		temp.position.x=60+size%5*50+rand_range(-1,1)
		temp.position.y=-16
		temp.name=str("dot",size+1)
		temp.add_to_group(Game.group["colorDot"])
		temp.setColor(color)#设置颜色
		temp.collision_layer=64
		temp.collision_mask=64
		temp.linear_velocity.y=500
		add_child(temp)
		joints[size].node_b=NodePath(str("../",temp.name))		
		dots.append(temp)		
	else: 	
		var temp = dot.instance()
		temp.position.y=-16
		temp.name=str("dot",size+1)
		temp.add_to_group(Game.group["colorDot"])
		temp.setColor(color)#设置颜色
		temp.collision_layer=32
		temp.collision_mask=32
		temp.position.x=60+size%5*50
		
		add_child(temp)	
		joints[size].node_b=NodePath(str("../",temp.name))		
		temp.linear_velocity.y=500
		dots.append(temp)


#清空颜色
func clearColor():
	for i in dots:
		remove_child(i)	
	for i in joints:
		remove_child(i)
	joints.clear()
	dots.clear()


func _process(delta):
	update()

func _draw():
	for i in range(len(dots)):
		draw_line(joints[i].position,dots[i].position,Game.lineColor[0],0.5,true)

