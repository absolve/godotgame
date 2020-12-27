extends Node



signal baseDestroyed
signal hitEnemy(enemyType,players)
signal tankDestroy(id)

var groups={'player':'player','base':'base',
			'enemy':'enemy','bullet':'bullet'}

var player1={"up":KEY_W,"down":KEY_S,"left":KEY_A,"right":KEY_D,'fire':KEY_J}

enum game_state{LOAD,START,PAUSE,OVER,NEXT_LEVEL}
enum tank_state{IDLE,DEAD,STOP,START}
enum bulletType{players,enemy}
enum brickType{brickWall,stoneWall,bush,water,ice}
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

#方块图片
var brick=preload("res://sprites/brick.png")
var stone=preload("res://sprites/stone.png")
var ice=preload("res://sprites/ice.png")
var bush=preload("res://sprites/bush.png")
var water=preload("res://sprites/water.png")



var _mainScene="res://scenes/main.tscn"	#主界面

var mainRoot
var mainScene #主场景 用来添加子弹数据
var otherObj  #其他对象
var winSize=Vector2(480,416)	#屏幕大小

var mapDir="res://levels"	#内置地图路径

var mapNum	#地图数量
var mapNameList=[]  #地图文件名字
var level=0  #默认关卡1

var mode=1	#游戏单人 双人
var playerLive=[2,2]	#玩家生命数



func _ready():
	mapNum = getBuiltInMapNum(mapDir,mapNameList)
	#mapDir.split()
	print(mapNameList)
	pass 


#更改场景
func changeScene(stagePath):
#	Splash.find_node("ani").play("moveIn")
#	yield(Splash.find_node("ani"),"animation_finished")
	Splash.playIn()
	yield(Splash.find_node("ani"),"animation_finished")
	set_process_input(false)
	get_tree().change_scene(stagePath)
	set_process_input(true)
#	Splash.find_node("ani").play("moveOut")

func loadMap(level):
	
	pass

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
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return num


#获取扩展的地图	
func getExtensionMapNum():
	var num=0
	var baseDir=OS.get_executable_path().get_base_dir()
	var mapPath=baseDir+"/levels"
	var dir = Directory.new()
	if dir.dir_exists(mapPath):
		print("1212")
		if dir.open(mapPath) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if !dir.current_is_dir():
					num+=1
					print("Found file: " + file_name)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")
	else:
		print("Directory not exist")
	return num
