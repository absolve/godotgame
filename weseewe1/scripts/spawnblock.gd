extends Node2D


var block=preload("res://scenes/block.tscn")

var state = Game.blockState.SLOW

func _ready():
	Game.connect("blockExit",self,"_block_exit")
	
	pass # Replace with function body.

#新建
func init():
	for i in range(5):
		var temp=block.instance()
		temp.position.x=(temp.width+1)*i+temp.width/2
		temp.state=state
		add_child(temp)
		


func _process(delta):
	
	pass

func stop():
	
	pass


func _block_exit():
	print(121212)
	var temp=block.instance()	
#	temp.modulate=Color(0,0,0)
	temp.position.x=(temp.width+1)*5+temp.width/2-30
	temp.state=state
	print(temp.position.x)
	add_child(temp)	
	
