extends Control

#var color1="#fc361c"
#var color2="#bfa080"

var score=100  #每辆坦克100分
var playerNum=1 #如果是两个人 就显示两个

onready var stage=$stage
onready var hiscore=$HBoxContainer/hiscore
onready var p1Score=$p1Score
onready var p2Score=$p2Score

onready var p1TypeA=$p1TypeA
onready var p1TypeAPoint=$p1TypeA/num
onready var p1TypeANum=$p1TypeANum
onready var p1TypeANum_=$p1TypeANum/num
onready var p1TypeB=$p1TypeB
onready var p1TypeBPoint=$p1TypeB/num
onready var p1TypeBNum=$p1TypeBNum
onready var p1TypeBNum_=$p1TypeBNum/num
onready var p1TypeC=$p1TypeC
onready var p1TypeCPoint=$p1TypeC/num
onready var p1TypeCNum=$p1TypeCNum
onready var p1TypeCNum_=$p1TypeCNum/num
onready var p1TypeD=$p1TypeD
onready var p1TypeDPoint=$p1TypeD/num
onready var p1TypeDNum=$p1TypeDNum
onready var p1TypeDNum_=$p1TypeDNum/num
onready var p1Total=$p1Total

onready var p2TypeA=$p2TypeA
onready var p2TypeAPoint=$p2TypeA/num
onready var p2TypeANum=$p2TypeANum
onready var p2TypeANum_=$p2TypeANum/num
onready var p2TypeB=$p2TypeB
onready var p2TypeBPoint=$p2TypeB/num
onready var p2TypeBNum=$p2TypeBNum
onready var p2TypeBNum_=$p2TypeBNum/num
onready var p2TypeC=$p2TypeC
onready var p2TypeCPoint=$p2TypeC/num
onready var p2TypeCNum=$p2TypeCNum
onready var p2TypeCNum_=$p2TypeCNum/num
onready var p2TypeD=$p2TypeD
onready var p2TypeDPoint=$p2TypeD/num
onready var p2TypeDNum=$p2TypeDNum
onready var p2TypeDNum_=$p2TypeDNum/num
onready var p2Total=$p2Total

onready var reward=$reward
onready var timer=$Timer
onready var initTimer=$initTimer

var p1Pos=Vector2(8,400)
var p2Pos=Vector2(392,400)


func _ready():
	stage.set_text("stage %d"%(Game.level+1))
	if Game.mode==1: #单人
		p1Score.set_text("%d"%Game.playerScore["player1"])
		p2Score.set_visible(false)
		p2TypeA.set_visible(false)
		p2TypeB.set_visible(false)
		p2TypeC.set_visible(false)
		p2TypeD.set_visible(false)
		pass
	else: #双人
		p1Score.set_text("%d"%Game.playerScore["player1"])
		p2Score.set_text("%d"%Game.playerScore["player2"])	
		pass
	if 	Game.playerScore["player1"]>=Game.playerScore["player2"]:
		hiscore.set_text("%d"%Game.playerScore["player1"])
	else:
		hiscore.set_text("%d"%Game.playerScore["player2"])
	timer.connect("timeout",self,"nextLevel")	
	print(Game.p1Score)
	print(Game.p2Score)
	initTimer.connect("timeout",self,"startCount")
	initTimer.start()
	pass

var state=-1
var countStartTime=0
var countTime=320  #ms
var index=0  #计分开始的位置
var p1Num=1
var p2Num=1

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		pass
	if state==0:
		if OS.get_system_time_msecs()-countStartTime>=countTime:
			countStartTime=OS.get_system_time_msecs()	
			var result1=setp1Num(index,p1Num)
			var result2=false
			if Game.mode==2:
				result2=setp2Num(index,p2Num)
			
			if Game.mode==2 && result2 && result1:
				state=1
				index+=1
				p2Num=1
				p1Num=1
			elif Game.mode==1 && result1:
				state=1
				index+=1
				p1Num=1
			else:	
				if Game.mode==1:
					p1Num+=1	
				else:
					p1Num+=1	
					p2Num+=1	
			SoundsUtil.playPoint()
	elif state==1: #进入下一个分数
		if index==0:
#			p1TypeA.set_visible(true)
			p1TypeANum.set_visible(true)
			p1TypeANum_.set_visible(true)
			p1TypeAPoint.set_visible(true)
			state=0	
			if Game.mode==2:
#				p2TypeA.set_visible(true)
				p2TypeANum.set_visible(true)
				p2TypeANum_.set_visible(true)
				p2TypeAPoint.set_visible(true)
		elif index==1:
#			p1TypeB.set_visible(true)
			p1TypeBNum.set_visible(true)
			p1TypeBNum_.set_visible(true)
			p1TypeBPoint.set_visible(true)
			state=0	
			if Game.mode==2:
#				p2TypeB.set_visible(true)
				p2TypeBNum.set_visible(true)
				p2TypeBNum_.set_visible(true)
				p2TypeBPoint.set_visible(true)
		elif index==2:
#			p1TypeC.set_visible(true)
			p1TypeCNum.set_visible(true)	
			p1TypeCNum_.set_visible(true)	
			p1TypeCPoint.set_visible(true)
			state=0	
			if Game.mode==2:
#				p2TypeC.set_visible(true)
				p2TypeCNum.set_visible(true)
				p2TypeCNum_.set_visible(true)	
				p2TypeCPoint.set_visible(true)	
		elif index==3:
#			p1TypeD.set_visible(true)
			p1TypeDNum.set_visible(true)	
			p1TypeDNum_.set_visible(true)	
			p1TypeDPoint.set_visible(true)
			state=0	
			if Game.mode==2:
#				p2TypeD.set_visible(true)
				p2TypeDNum.set_visible(true)	
				p2TypeDNum_.set_visible(true)	
				p2TypeDPoint.set_visible(true)
		else:
			state=2		
	elif state==2:
#		print("end")
		p1Total.set_visible(true)	
		var p1Num=Game.p1Score['typeA']+\
				Game.p1Score['typeB']+Game.p1Score['typeC']+\
				Game.p1Score['typeD']
		p1Total.set_text("%d"%(p1Num))	
		if 	Game.mode==2:
			var p2Num=Game.p2Score['typeA']+\
				Game.p2Score['typeB']+Game.p2Score['typeC']+\
				Game.p2Score['typeD']
			p2Total.set_visible(true)	
			p2Total.set_text("%d"%(p2Num))
			if p1Num>p2Num:
				reward.set_visible(true)
				reward.set_position(p1Pos)
				SoundsUtil.playaward()
				Game.playerScore['player1']+=1000
			elif p1Num<p2Num and p2Num!=0:
				reward.set_visible(true)
				reward.set_position(p2Pos)
				SoundsUtil.playaward()
				Game.playerScore['player2']+=1000
		state=3
		timer.start()		
	elif state==3:
		pass		
	pass

#计分 index第几行  num 个数	 
func setp1Num(index,num):
	var flag=false
	if index==0:
		if Game.p1Score['typeA']>=num:
			p1TypeAPoint.set_text("%d"%(num*100))
			p1TypeANum_.set_text("%d"%num)
		else:
			flag=true
	elif index==1:
		if Game.p1Score['typeB']>=num:
			p1TypeBPoint.set_text("%d"%(num*200))
			p1TypeBNum_.set_text("%d"%num)
		else:
			flag=true
	elif index==2:
		if Game.p1Score['typeC']>=num:
			p1TypeCPoint.set_text("%d"%(num*300))
			p1TypeCNum_.set_text("%d"%num)
		else:
			flag=true	
	elif index==3:
		if Game.p1Score['typeD']>=num:
			p1TypeDPoint.set_text("%d"%(num*400))
			p1TypeDNum_.set_text("%d"%num)
		else:
			flag=true
	return flag				
	

func setp2Num(index,num):
	print('setp2Num',index,num)
	var flag=false
	if index==0:
		if Game.p2Score['typeA']>=num:
			p2TypeAPoint.set_text("%d"%(num*100))
			p2TypeANum_.set_text("%d"%num)
		else:
			flag=true
	elif index==1:
		if Game.p2Score['typeB']>=num:
			p2TypeBPoint.set_text("%d"%(num*200))
			p2TypeBNum_.set_text("%d"%num)
		else:
			flag=true
	elif index==2:
		if Game.p2Score['typeC']>=num:
			p2TypeCPoint.set_text("%d"%(num*300))
			p2TypeCNum_.set_text("%d"%num)
		else:
			flag=true	
	elif index==3:
		if Game.p2Score['typeD']>=num:
			p2TypeDPoint.set_text("%d"%(num*400))
			p2TypeDNum_.set_text("%d"%num)
		else:
			flag=true
	print(flag)		
	return flag	


#计数开始
func startCount():
	state=1
	countStartTime=OS.get_system_time_msecs()

#下一关	
func nextLevel():
	print("nextLevel")
#	gameOver()
	if Game.isGameOver:
		gameOver()
	elif Game.level>=Game.mapNum:	#最后一关
		Game.changeScene("res://scenes/info.tscn")
		pass	
	else:#下一关
		Game.level+=1
		Game.changeSceneAni(Game._mainScene)
		pass	
	pass	
	
#游戏结束	
func gameOver():
	Game.changeScene("res://scenes/gameover.tscn")
	pass	


func _on_Button_pressed():
	state=1
	countStartTime=OS.get_system_time_msecs()	
	pass # Replace with function body.
