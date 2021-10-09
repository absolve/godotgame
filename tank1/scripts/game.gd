extends Node



signal baseDestroyed  #基地被消灭
signal hitEnemy(enemyType,players,pos) #敌人被消灭
signal tankDestroy(id)
signal addBonus(enemyType)	#添加物品事件
signal hitPlayer(id) #玩家被消灭

var groups={'player':'player','base':'base',
			'enemy':'enemy','bullet':'bullet'}

var player1={"up":KEY_W,"down":KEY_S,"left":KEY_A,"right":KEY_D,'fire':KEY_J}
var player2={"up":KEY_UP,"down":KEY_DOWN,"left":KEY_LEFT,"right":KEY_RIGHT,'fire':KEY_KP_0 }

enum game_state{LOAD,START,PAUSE,OVER,NEXT_LEVEL}
enum tank_state{IDLE,DEAD,STOP,START,INVINCIBLE,RESTART}
enum bulletType{players,enemy}
enum brickType{brickWall,stoneWall,water,bush,ice}
enum bulletPower{normal,fast,super}
enum enemyType{TYPEA,TYPEB,TYPEC,TYPED}

var explode=preload("res://scenes/explode.tscn")
var flash=preload("res://scenes/flash.tscn")

var grenade =preload("res://sprites/bonus_grenade.png")
var helmet=preload("res://sprites/bonus_helmet.png")
var clock=preload("res://sprites/bonus_clock.png")
var shovel=preload("res://sprites/bonus_shovel.png")
var tank=preload("res://sprites/bonus_tank.png")
var star=preload("res://sprites/bonus_star.png")
var gun=preload("res://sprites/bonus_gun.png")
var boat=preload("res://sprites/bonus_boat.png")
var bullet=preload("res://scenes/bullet.tscn")
var ship1 = preload("res://sprites/ship1.png")
var ship2 = preload("res://sprites/ship2.png")
var baseNew=preload("res://sprites/base_new.png")

#方块图片
var brick=preload("res://sprites/brick.png")
var stone=preload("res://sprites/stone.png")
var ice=preload("res://sprites/ice.png")
var bush=preload("res://sprites/bush.png")
var water=preload("res://sprites/water1.png")
var water1=preload("res://sprites/water2.png")

var enemy=preload("res://scenes/enemy.tscn")

var _welcomeScene="res://scenes/welcome.tscn"
var _mainScene="res://scenes/main.tscn"	#主界面
var _menuScene="res://scenes/menu.tscn" #记分界面
const _settingScene="res://scenes/setting.tscn" #设置界面

var mainRoot
var mainScene #主场景 用来添加子弹数据
var otherObj  #其他对象
var winSize=Vector2(480,416)	#屏幕大小

var mapDir="res://levels"	#内置地图路径

var mapNum	#地图数量
var mapNameList=[]  #地图文件名字
var level=0  #默认关卡1

var mode=1	#游戏单人1 双人2
var playerLive=[2,2]	#玩家生命数
var playerScore={"player1":0,"player2":0}  #玩家分数
var p1Score={'typeA':0,'typeB':1,'typeC':0,'typeD':0} #击中的坦克数量
var p2Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
var p1State={'level':1,'life':1,'hasShip':false} #坦克信息
var p2State={'level':1,'life':1,'hasShip':false}
var isGameOver=false#游戏是否结束
var canSelectLevel=true#选择关卡
var controls =['p1_up','p1_down','p1_left','p1_right','p1_fire',
	'p2_up','p2_down','p2_left','p2_right','p2_fire','game_start']
var configFile="config.ini"
var ActionEvent:Dictionary = {} #事件集合
var gameConfigFile="gameConfig.ini"
var useExtensionMap=false  #使用你扩展

func _ready():
#	mapNum = getBuiltInMapNum(mapDir,mapNameList)
	#mapDir.split()
#	mapNameList.sort_custom(self,"sort")
	printFont()
	loadConfig()
	loadGameConfig()
	loadMaps()
	print(mapNameList)	
	pass 

static func sort(a:String,b:String):
	var flag=true
	var aname=a.get_basename()
	var bname=b.get_basename()
	if aname.to_int()>=bname.to_int():
		flag=false
	return flag


#改变到选择场景
func change2SceneLevel(stagePath):
	Splash.setLevel(str(level+1)) #关卡从0开始	
	Splash.playIn()
	yield(Splash.find_node("ani"),"animation_finished")
	Splash.select=true
	pass
	
#更改场景
func changeSceneAni(stagePath):
	Splash.setLevel(str(level+1)) #关卡从0开始	
	Splash.playIn()
	yield(Splash.find_node("ani"),"animation_finished")
#	Splash.select=true
	set_process_input(false)
	get_tree().change_scene(stagePath)
	set_process_input(true)
	Splash.playOut()
	SoundsUtil.playMusic()
	yield(Splash.find_node("ani"),"animation_finished")
	

func changeScene(stagePath):
	set_process_input(false)
	get_tree().change_scene(stagePath)
	set_process_input(true)

#重新设置数据
func reset():
	level=0
	playerLive=[2,2]	#玩家生命数
	playerScore={"player1":0,"player2":0}  #玩家分数
	p1Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
	p2Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
	p1State={'level':1,'life':1,'hasShip':false}
	p2State={'level':1,'life':1,'hasShip':false}
	isGameOver=false#游戏是否结束
	canSelectLevel=true
	pass

func loadMaps():
	print('loadMaps')
	if useExtensionMap:
		mapNum=getExtensionMapNum(mapNameList)
	else:
		mapNum = getBuiltInMapNum(mapDir,mapNameList)
	if mapNum>0:
		mapNameList.sort_custom(self,"sort")

#获取内置的地图文件数量
func getBuiltInMapNum(mapDir,fileList:Array):
	var num=0
	var dir = Directory.new()
	if dir.open(mapDir) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				num+=1
				fileList.append(file_name)
			#	print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return num


#获取扩展的地图	
func getExtensionMapNum(fileList:Array):
	var num=0
	var baseDir=OS.get_executable_path().get_base_dir()
	var mapPath=baseDir+"/levels"
#	print(OS.get_executable_path())
	var dir = Directory.new()
	if dir.dir_exists(mapPath):
		if dir.open(mapPath) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if !dir.current_is_dir():
					num+=1
					fileList.append(file_name)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")
	else:
		print("Directory not exist ",mapPath)
		var err=dir.make_dir_recursive(mapPath) #新建一个
		print(err==OK)
	return num

#载入配置文件
func loadGameConfig():
	var baseDir=OS.get_executable_path().get_base_dir()
	var config = ConfigFile.new()
	var err = config.load(baseDir+"/"+gameConfigFile)
	if err == OK:
		print(err)
		if config.has_section("map"):
			if config.has_section_key("map","useExtensionMap"):
				useExtensionMap=config.get_value("map","useExtensionMap",false)		
	else:
		print('newGameConfigFile')
		newGameConfigFile()

#保存配置文件
func saveGameConfig(flag):
	var baseDir=OS.get_executable_path().get_base_dir()
	var config = ConfigFile.new()
	var err = config.load(baseDir+"/"+gameConfigFile)
	if err == OK:
		if config.has_section("map"):
			config.set_value("map","useExtensionMap",flag)	
		else:
			config.set_value("map","useExtensionMap",flag)
		config.save(baseDir+"/"+gameConfigFile)	
	else:
		print("err ",err)		
		
func newGameConfigFile():
	var baseDir=OS.get_executable_path().get_base_dir()
#	print(baseDir)
	var file=File.new()
	if !file.file_exists(baseDir+"/"+gameConfigFile):
		file.open(baseDir+"/"+gameConfigFile, File.WRITE)
		file.close()
		
#载入按键配置
func loadConfig():
	var baseDir=OS.get_executable_path().get_base_dir()
	var file=File.new()
#	print(baseDir+configFile)
	if file.file_exists(baseDir+"/"+configFile):
		file.open(baseDir+"/"+configFile, File.READ)
	#	print(file.get_as_text())
		var input=parse_json(file.get_as_text())
		print('data ',input)
		if input:
			for i in controls:
				if !input.has(i):
					continue
				var event=input[i]
				ActionEvent[i]=[]
				for z in event:
					var NewEvent:InputEvent
					if z.eventtype == "InputEventKey":
						NewEvent = InputEventKey.new()
						NewEvent.scancode = z.scancode
					elif z.eventtype == "InputEventJoypadButton":
						NewEvent = InputEventJoypadButton.new()
						NewEvent.device = z.device
						NewEvent.button_index = z.button_index
					elif z.eventtype=='InputEventJoypadMotion':
						NewEvent = InputEventJoypadMotion.new()
						NewEvent.device = z.device
						NewEvent.axis = z.axis
						NewEvent.axis_value = z.axis_value
					ActionEvent[i].append(NewEvent)
			setActionEvent()
		else: #如果都没有配置的话就使用默认自带的
			loadDefaultActions()
		file.close()
	else:
		print("file not exist")
		file.open(baseDir+"/"+configFile, File.WRITE)
		file.close()
		loadDefaultActions()
	pass
	
#设置inputmap的事件根据本地保存
func setActionEvent():
	for i in controls:
		InputMap.action_erase_events(i)
		for event in ActionEvent[i]:
			InputMap.action_add_event(i,event)	

#加载默认的数据
func loadDefaultActions():
	InputMap.load_from_globals() #项目配置的信息
	for  i in controls:
		ActionEvent[i]=InputMap.get_action_list(i)
	
func printFont():
	print(""" 
 ____    ____  ______  ______  _        ___         __  ____  ______  __ __ 
|    \\  /    ||      ||      || |      /   ]       /  ]|    ||      ||  |  |
|  o  )|  o  ||      ||      || |     /  [_       /  /  |  | |      ||  |  |
|     ||     ||_|  |_||_|  |_|| |___ |    _]     /  /   |  | |_|  |_||  ~  |
|  O  ||  _  |  |  |    |  |  |     ||   [_     /   \\_  |  |   |  |  |___, |
|     ||  |  |  |  |    |  |  |     ||     |    \\     | |  |   |  |  |     |
|_____||__|__|  |__|    |__|  |_____||_____|     \\____||____|  |__|  |____/ 
	""")
