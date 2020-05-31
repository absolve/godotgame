extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var mode=1
var colordot=preload("res://scenes/colorDot.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	if mode==1:
		for i in range(3):
			var temp=colordot.instance()
			temp.position.x=52+i*90
			temp.position.y=150
			temp.name = str("dot",i)
			var joint = GrooveJoint2D.new()	
			joint.position.x=50+i*90
			joint.position.y=10
			joint.node_a = NodePath("../top")
			joint.node_b = NodePath(str("../",temp.name))
			joint.length=100
			joint.initial_offset=80
			
			add_child(temp)
			add_child(joint)
		
	else:
		pass
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
