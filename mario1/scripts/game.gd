extends Node

#游戏中一些数据
signal stateChange
signal stateFinish
signal flagEnd  #旗到了底部
signal timeOut #时间到
signal hurryup #时间快到了 
signal flagRising #旗在城堡升起来
signal invincibleFinish #无敌时间结束
signal marioStateChange #状态发生变化
signal marioStateFinish #状态变化结束
signal marioInCastle  #进入城堡
signal marioIntoPipe #进入水管 
signal countFinish #计算分数结束
signal marioDead #死亡
signal marioStartSliding #开始
signal marioContactAxe  #mario碰到斧头
signal bowserDrop #boss掉出屏幕
signal marioCastleEnd #马里奥到了城堡最后
signal marioGrapVineTop #马里奥爬到藤曼顶部
signal vineEnd #藤蔓生长结束 只有藤蔓长度有限制的时候
signal mazegate #碰到迷宫大门

signal btnClose	#设置关闭按钮

#游戏的背景色 白天 黑夜 水下
var  backgroundcolor = ['#5C94FC',
						'#000',
						'#2038EC']
#var score =preload("res://scenes/score.tscn")
var fireball=preload("res://scenes/fireball.tscn")

#保存的数据 level地图文件名  mapName显示的标题名字 subLevel 地图中可以进来或者出去的点
var playerData={"score":0,"coin":0,"lives":3,"level":"1-1","subLevel":'','mapName':"",
				"time":0,
				"mario":{"big":false,"fire":false}}
var map  #地图
var configFile='mario1.ini' #配置文件名字
var config={'Resolution':{'Fullscreen':false,'Borderless':false,'Scale':1},
'Volume':{'Master':1,'Bg':0.5,'Sfx':0.5}}


func _ready():
	printFont()
#	print(OS.get_executable_path().get_base_dir())
	getConfig()
	
	pass 

func getConfig():
	var cfg = ConfigFile.new()
	var err = cfg.load(OS.get_executable_path().get_base_dir()+"/"+configFile)

	if err != OK:
		print(err)
		newConfigFile()
		return
	for i in cfg.get_sections():
		if i=='Resolution':
			config.Resolution.Fullscreen=cfg.get_value(i,'Fullscreen')
			config.Resolution.Borderless=cfg.get_value(i,'Borderless')
			config.Resolution.Scale=cfg.get_value(i,'Scale')
		elif i=='Volume':
			config.Volume.Master=cfg.get_value(i,'Master')
			config.Volume.Bg=cfg.get_value(i,'Bg')
			config.Volume.Sfx=cfg.get_value(i,'Sfx')
			
	print(config)
	pass

func newConfigFile():
	var config = ConfigFile.new()
	config.set_value("Resolution","Fullscreen",false)
	config.set_value("Resolution","Borderless",false)
	config.set_value("Resolution","Scale",1)
	
	config.set_value("Volume","Master",1)
	config.set_value("Volume","Bg",0.5)
	config.set_value("Volume","Sfx",0.5)
	config.save(OS.get_executable_path().get_base_dir()+"/"+configFile)


func saveConfigFile():
	var cfg = ConfigFile.new()
	cfg.set_value("Resolution","Fullscreen",config.Resolution.Fullscreen)
	cfg.set_value("Resolution","Borderless",config.Resolution.Borderless)
	cfg.set_value("Resolution","Scale",config.Resolution.Scale)
	
	cfg.set_value("Volume","Master",config.Volume.Master)
	cfg.set_value("Volume","Bg",config.Volume.Bg)
	cfg.set_value("Volume","Sfx",config.Volume.Sfx)
	cfg.save(OS.get_executable_path().get_base_dir()+"/"+configFile)


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

func addObj(obj):
	map.addObj(obj)

func addScore(_position,_score=100):
	map.addScore(_position,_score)

func addCoin(_position,_coin=1):
	map.addCoin(_position,_coin)

func addLive(_position,id):
	map.addLive(_position,id)

func getPlayerBulletCount(id):
	return map.getBulletCount(id)

func getMario():
	return map.getMario()

#获取地图中方块对象
func getMapBrick(x,y):
	return map.getMapBrick(x,y)
	pass

func checkMapBrick(x,y):
	return map.checkMapBrick(x,y)

func checkMapBrickIndex(x,y):
	return map.checkMapBrickIndex(x,y)

func getObj():
	return map.getObj()

func getCamera():
	return map.getCamera()

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
