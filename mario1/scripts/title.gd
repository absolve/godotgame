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
var currentTime=100  #时间
var tick=0
var tickNum=17
var fastTickNum=1
var status=constants.empty
var score=0
var coinNum=0  #硬币的数量

func _ready():
	_time.text="%0*d"%[3,currentTime]
	_coinNum.text="%0*d"%[2,coinNum]
	hide()
	pass 

func setScore(s):
	score=s
	_score.text="%0*d"%[9,score]

func setTime(t):
	currentTime=t
	
	
#添加分数
func addScore(s):
	score+=s
	_score.text="%0*d"%[9,score]
	pass


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
func setLevel(num1:String,num2:String)->void:
	_level.text=num1+"-"+num2

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
	
func _update(_delta):
	if status==constants.countDown:
		tick+=1
		if tick>=tickNum:
			tick=0
			currentTime-=1
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
				if currentTime<=0:
					status=constants.empty
			_time.text="%0*d"%[3,currentTime]
	pass	
	
