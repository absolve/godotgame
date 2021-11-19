extends Node

#游戏中一些数据

#游戏的背景色 白天 黑夜 水下
var  backgroundcolor = ['#5C94FC',
						'#000',
						'#2038EC']
var score =preload("res://scenes/score.tscn")

var map  #地图

func _ready():
	printFont()
	pass 

func setMap(obj):
	self.map=obj

func addObj2Brick(obj):
	map.addObj2Brick(obj)

func addObj2Item(obj):
	map.addObj2Item(obj)

func addObj2Other(obj):
	map.addObj2Other(obj)

func printFont():
	print("""
  _____ __ __  ____   ___  ____       ___ ___   ____  ____   ____  ___       ____   ____   ___   _____
 / ___/|  |  ||    \\ /  _]|    \\     |   |   | /    ||    \\ |    |/   \\     |    \\ |    \\ /   \\ / ___/
(   \\_ |  |  ||  o  )  [_ |  D  )    | _   _ ||  o  ||  D  ) |  ||     |    |  o  )|  D  )     (   \\_ 
 \\__  ||  |  ||   _/    _]|    /     |  \\_/  ||     ||    /  |  ||  O  |    |     ||    /|  O  |\\__  |
 /  \\ ||  :  ||  | |   [_ |    \\     |   |   ||  _  ||    \\  |  ||     |    |  O  ||    \\|     |/  \\ |
 \\    ||     ||  | |     ||  .  \\    |   |   ||  |  ||  .  \\ |  ||     |    |     ||  .  \\     |\\    |
  \\___| \\__,_||__| |_____||__|\\_|    |___|___||__|__||__|\\_||____|\\___/     |_____||__|\\_|\\___/  \\___|
	""")
