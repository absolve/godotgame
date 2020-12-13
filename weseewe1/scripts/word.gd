extends Node2D


var _chars = preload("res://scenes/char.tscn")
var charList=[]

func _ready():
	#init()
	
	pass



func init():
	var chars=['w','e','s','e','e','w','e']
	for i in range(7):
		var temp = _chars.instance()
		temp.position.x = 40+i*40+rand_range(-0.2,0.2)
		temp.position.y=-30
		temp.name=str("char",i)
		temp.setChar(chars[i])
		
		add_child(temp)	
		var joint= DampedSpringJoint2D.new()
		joint.name=str("joint2D",i)
		joint.length=50
		joint.rest_length=4
		joint.stiffness=8
		joint.damping=1
		joint.position.x=40+i*40
		joint.position.y=-30
		#joint.node_a=NodePath("../top")
		joint.node_a=$top.get_path()
		joint.node_b=temp.get_path()
	
		add_child(joint)
		charList.append(temp)
	
	pass
	
func clear():
	for i in get_children():
		if 'char' in i.name or 'joint2D' in i.name:
			remove_child(i)
	charList.clear()


func _process(delta):
	update()
	
func _draw():
	for i in range(len(charList)):
		draw_line(Vector2(40+i*40,0),charList[i].position,Game.lineColor[0],0.5,true)
		
