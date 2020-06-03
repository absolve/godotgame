extends Node2D


var block=preload("res://scenes/block.tscn")

var state = Game.blockState.SLOW

func _ready():
	Game.connect("blockExit",self,"_block_exit")
	init()
	pass 

#新建
func init():
	for i in range(4):
		var temp=block.instance()
		temp.position.x=temp.width/2+(temp.width+2)*i
		temp.state=state
		add_child(temp)
		


func _process(delta):
	
	pass

func stop():
	
	pass


func _block_exit():
	var temp=block.instance()	
#	temp.modulate=Color(0,0,0)
	temp.position.x=temp.width/2+(temp.width+2)*4
	temp.state=state
	print("new ",temp.position.x)
	add_child(temp)	

	pass
	
