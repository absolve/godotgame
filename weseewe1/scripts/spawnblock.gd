extends Node2D


var block=preload("res://scenes/block.tscn")

var blockstate = Game.blockState.SLOW

var useColor = []	#第一个使用的颜色
var unuseColor=[]	#其它没有使用的颜色
var allColor=Game.blockColor

var gameState=Game.state.STATE_IDLE

var index=0	

func _ready():
	randomize()
	Game.connect("blockExit",self,"_block_exit")
	allColor.shuffle()
	#.append(allColor[0])
	#useColor.slice()
	for i in range(1,10):
		unuseColor.append(i)



#新建
func init():
	for i in range(4):
		var temp=block.instance()
		temp.position.x=(temp.width+2)*i+temp.width/2
		temp.state=blockstate
		temp.setColor(allColor[0])  #设置颜色
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

func setGameState(state):
	gameState=state


func _block_exit(pos):
	print("pos",pos)
	var temp=block.instance()	
#	temp.modulate=Color(0,0,0)
	#temp.position.x=(temp.width+2)*3+temp.width/2
	temp.position.x=pos+(temp.width+2)*4
	temp.state=blockstate
	
	if gameState==Game.state.STATE_HELP:
		temp.setColor(allColor[index])
		index+=1
		if index>2:
			index=0
	elif gameState==Game.state.STATE_IDLE:
		temp.setColor(allColor[0])
	elif gameState==Game.state.STATE_START:
		print("gameState")
		#temp.position.y=420		#最高位置
		temp.position.y=610		#最低位置
		temp.noCollision=true
		pass
	
	#print(temp.position.x)
	add_child(temp)	
	
