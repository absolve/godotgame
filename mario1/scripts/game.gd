extends Node

#游戏中一些数据
signal stateChange
signal stateFinish
signal flagEnd  #旗到了底部
signal timeOut #时间到

#游戏的背景色 白天 黑夜 水下
var  backgroundcolor = ['#5C94FC',
						'#000',
						'#2038EC']
var score =preload("res://scenes/score.tscn")
var fireball=preload("res://scenes/fireball.tscn")

#保存的数据
var playerData={"score":0,"coin":0,"lives":3,
				"mario":{"big":false,"fire":false}}


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

func addObj2Bullet(pos,dir):
	var temp=fireball.instance()
	temp.position=pos
	temp.dir=dir
	map.addObj2Bullet(temp)

func addScore(m,_score=100):
	map.addScore(m,_score)

func addCoin(m,_coin=1):
	map.addCoin(m,_coin)

func getPlayerBulletCount(id):
	return map.getBulletCount(id)

func getMario():
	return map.getMario()

#获取地图中方块对象
func getMapBrick(x,y):
	
	pass

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
