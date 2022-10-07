extends CanvasLayer

#游戏标题的功能
onready var _hbox=$hbox
onready var _name=$hbox/name
onready var _score=$hbox/name/score
onready var _coin=$hbox/Label5/Label4/coin
onready var _coinNum=$hbox/Label5/Label4/coinNum
onready var _level=$hbox/world/level
onready var _time=$hbox/timeLable/time

var countDownStart=true
var currentTime=0  #时间
var tick=0
var tickNum=25
var fastTickNum=1
var status=constants.empty
var score=0
var coinNum=0  #硬币的数量
var lastTime=0

func _ready():
	_time.text="%0*d"%[3,currentTime]
	_coinNum.text="%0*d"%[2,coinNum]
#	hide()
	pass 

func setScore(s):
	score=s
	_score.text="%0*d"%[9,score]

func setTime(t):
	currentTime=t

func getTime():
	return 	currentTime
	
#添加分数
func addScore(s):
	score+=s
	_score.text="%0*d"%[9,score]
	pass

func setCoin(c=0):
	coinNum=c
	_coinNum.text="%0*d"%[2,coinNum]	
	
func addCoin(c=1):
	coinNum+=c
	
	if coinNum>=100:
		coinNum=0
		pass
	_coinNum.text="%0*d"%[2,coinNum]	
	
#隐藏时间	
func hideTime()->void:
	_time.hide()
	pass

#设置名字	
func setName(name)->void:
	_name.text=name

#设置关卡
func setLevel(l:String)->void:
	_level.text=l

#停驶硬币动画	
func stopCoinAni()->void:
	_coin.playing=false
	_coin.frame=0
	pass

func hide():
	_hbox.hide()

func show():
	_hbox.show()

func startCountDown():
	status=constants.countDown

func fastCountDown():	
	print("time",currentTime)	
	status=constants.fastCountDown
	
func stopCountDown():	
	status=constants.empty

func recordLastTime():
	lastTime=currentTime
	
func _update(_delta):
	if status==constants.countDown:
		tick+=1
		if tick>=tickNum:
			tick=0
			currentTime-=1
			if currentTime==100:
				Game.emit_signal("hurryup")
			if currentTime<=0:
				status=constants.empty
				Game.emit_signal("timeOut")
			_time.text="%0*d"%[3,currentTime]
	elif status==constants.fastCountDown:	
		if currentTime>0:
			tick+=1
			if tick>=fastTickNum:	
				tick=0
				currentTime-=1
				addScore(100)
				SoundsUtil.playScore()
				if currentTime<=0:
					Game.emit_signal("countFinish")
					status=constants.empty
			_time.text="%0*d"%[3,currentTime]
	pass	
	
