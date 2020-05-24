extends Node2D


var scoredot = preload("res://scenes/scoreDot.tscn")


func _ready():
	for i in range(10):
		var temp = scoredot.instance()
		temp.position.x = 71+i*18
		temp.position.y=100
		temp.name=str("scoredot",i)
		temp.setColor(Game.blockColor[5])
		var joint = GrooveJoint2D.new()	
		joint.position.x=70+i*18
		joint.position.y=10
		joint.node_a = NodePath("../top")
		joint.node_b = NodePath(str("../",temp.name))
		joint.length=100
		joint.initial_offset=80
		add_child(temp)
		add_child(joint)
		
	pass 




