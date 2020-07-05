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
	for i in range(10):
		unuseColor.append(allColor[i])



#新建最开始的4个
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

#添加新的颜色
func addNewColor():
	if unuseColor.size()>0:
		useColor.append(unuseColor.pop_front())

func _block_exit(pos):
#	print("pos",pos)
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
	elif gameState==Game.state.STATE_START:	#游戏开始的时候
		#print("gameState")
		#temp.position.y=420		#最高位置
		#temp.position.y=590		#最低位置
		temp.position.y=randi()%190+400
		#temp.noCollision=true
		#先判断是否出现连续两个连续不能站立
		if useColor.size()>=10: #那就是获取所有的颜色
			temp.noCollision=false
			temp.setColor(useColor[useColor.size()-1])
		else:	
			var children = get_children()
			if children[children.size()-1].noCollision and children[children.size()-2].noCollision:
				temp.noCollision=false
				var tempcolor=randi()%useColor.size()
				temp.setColor(useColor[tempcolor])
				print('====useColor')
				pass
			else:
				if randi()%10>=4:
					var tempcolor=randi()%unuseColor.size()
					temp.noCollision=true
					temp.setColor(unuseColor[tempcolor])
					print('----unuseColor')
				else:
					var tempcolor=0
					if useColor.size()>0:	#如果一开始没有就用第一个
						tempcolor=randi()%useColor.size()
						temp.setColor(useColor[tempcolor])
					else:
						temp.setColor(unuseColor[tempcolor])
					temp.noCollision=false
					print('====useColor')
	elif gameState==Game.state.STATE_PASS:
		temp.noCollision=false
		temp.position.y=610
		temp.setColor(useColor[useColor.size()-1])
						
	#print(temp.position.x)
	add_child(temp)	
	
