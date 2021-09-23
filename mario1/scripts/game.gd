extends Node

#游戏中一些数据

#游戏的背景色 白天 黑夜 水下
var  backgroundcolor = ['#5C94FC',
						'#000',
						'#2038EC']

var mainScene
var otherObj

func _ready():
	printFont()
	pass 

func add2MainScene(obj):
	mainScene.add_child(obj)

func add2OtherObj(obj):
	otherObj.add_child(obj)

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
