extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#onready var dot1 = $dot

var joints=[]
var dots=[]

var dot = preload("res://scenes/dot.tscn")
func _ready():
	randomize()
	$top.add_to_group(Game.group["colorDot"])
	#add3Dot()
	#print(Game.group["colorDot"])
	pass 

#添加三个分数球
func add3Dot():
	for i in range(3):
		var temp = dot.instance()
		temp.position.x=120+i*40+rand_range(-1,1)
		temp.position.y=1
		temp.name=str("dot",i)
		temp.add_to_group(Game.group["colorDot"])
	
		var joint= DampedSpringJoint2D.new()
		joint.length=15
		joint.rest_length=5
		joint.stiffness=16
		joint.damping=1
		joint.position.x=120+i*40
		joint.position.y=10
		joint.node_a=NodePath("../top")
		joint.node_b=NodePath(str("../",temp.name))
		add_child(temp)
		add_child(joint)
		dots.append(temp)
		joints.append(joint)

#清空颜色
func clearColor():
	for i in dots:
		remove_child(i)	
	for i in joints:
		remove_child(i)
	joints.clear()
	dots.clear()
	pass


func _process(delta):
	update()
	pass

func _draw():
	for i in range(len(joints)):
		draw_line(joints[i].position,dots[i].position,Game.lineColor[0],0.5,true)
	
	#draw_line(Vector2.ZERO,dot1.position,Color.blue,1)
	pass

