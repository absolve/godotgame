extends CanvasLayer

#游戏标题的功能
onready var _name=$hbox/name
onready var _score=$hbox/name/score
onready var _coin=$hbox/Label5/Label4/coin
onready var _coinNum=$hbox/Label5/Label4/coinNum
onready var _level=$hbox/world/level
onready var _time=$hbox/timeLable/time

var countDownStart=true
var currentTime=400
var tick=0
var tickNum=12
var fastTickNum=1
var status=constants.fastCountDown


func _ready():
	_time.text=str(currentTime)
	pass 

#添加分数
func addScore(score):
	pass

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



	
func _process(delta):
	_update(delta)
		
	
func _update(delta):
	if status==constants.countDown:
		tick+=1
		if tick>=tickNum:
			tick=0
			currentTime-=1
			if currentTime<=0:
				status=constants.empty
			_time.text=str(currentTime)	
	elif status==constants.fastCountDown:	
		if currentTime>0:
			tick+=1
			if tick>=fastTickNum:	
				tick=0
				currentTime-=1
				if currentTime<=0:
					status=constants.empty
			_time.text=str(currentTime)	
	pass	
	
