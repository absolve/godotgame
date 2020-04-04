extends Node
#游戏中的一些状态和功能

#场景
var mainScene="res://scenes/main.tscn"
var welcomeScene="res://scenes/welcome.tscn"

#得分显示不同的奖牌 铜牌到白金
const MEDAL_BRONZE   = 1
const MEDAL_SILVER   = 20
const MEDAL_GOLD     = 40
const MEDAL_PLATINUM = 60

#bird的状态
var idle=101
var fly=102
var play=103
var dead=105

#pipe的状态
var move=1001	#移动
var stop=1002	#停止
#地面的状态
var slow=1003	#缓慢移动
var fast=1004	#快速移动


#游戏的状态
var startGame=2001
var endGame=2002
var stopGame=2003

#分组信息
var group_bird="group_bird"
var group_pipe="group_pipe"
var group_ground="group_ground"

#分数
var score=0
var highScore=0

#窗口大小
var winHeight
var winWidth


func _ready():
	winWidth=ProjectSettings.get_setting("display/window/size/width")
	winHeight=ProjectSettings.get_setting("display/window/size/height")
	#OS.center_window()
	print(winHeight)
	print("[Screen Metrics]")
	print("Display size: ", OS.get_screen_size())
	print("Decorated Window size: ", OS.get_real_window_size())
	print("Window size: ", OS.get_window_size())
	print("Project Settings: Width=", ProjectSettings.get_setting("display/window/size/width"), " Height=", ProjectSettings.get_setting("display/window/size/height")) 
	print(OS.get_window_size().x)
	print(OS.get_window_size().y)
	

#更改场景
func changeScene(stagePath):
	set_process_input(false)

	if AudioPlayer:
		AudioPlayer.playSfxSwooshing()

	if splash:
		var ani=splash.get_node("ani")
		ani.play("fade_in")
		yield(ani,"animation_finished")
	
	get_tree().change_scene(stagePath)
	
	if splash:
		var ani=splash.get_node("ani")
		ani.play("fade_out")
		yield(ani,"animation_finished")
	
	set_process_input(true)
	
#获取每个数字
func get_digits(number):
	var str_number = str(number)
	var digits     = []
	
	for i in range(str_number.length()):
		digits.append(str_number[i].to_int())
	return digits

