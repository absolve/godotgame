extends Node2D


var block=preload("res://scenes/block.tscn")

var blockstate = Game.blockState.SLOW

func _ready():
	Game.connect("blockExit",self,"_block_exit")
	#init()


#新建
func init():
	for i in range(4):
		var temp=block.instance()
		temp.position.x=(temp.width+2)*i+temp.width/2
		temp.state=blockstate
		add_child(temp)

#设置状态		
func setState(state):
	blockstate=state
	for i in get_children():
		i.setState(state)
	

#设置停止
func stop():
	for i in get_children():
		i.setState(Game.blockState.STOP)
	pass


func _block_exit(pos):
	print("pos",pos)
	var temp=block.instance()	
#	temp.modulate=Color(0,0,0)
	#temp.position.x=(temp.width+2)*3+temp.width/2
	temp.position.x=pos+(temp.width+2)*4
	temp.state=blockstate
	#temp.setColor("#111111")
	print(temp.position.x)
	add_child(temp)	
	
