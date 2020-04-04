extends CanvasLayer

#游戏标题的功能

func _ready():
	pass 

#添加分数
func addScore(score):
	pass

#隐藏时间	
func hideTime()->void:
	$hbox/timeLable/time.hide()
	pass

#设置名字	
func setName(name)->void:
	$hbox/name.text=name

#设置关卡
func setLevel(num1:String,num2:String)->void:
	$hbox/world/level.text=num1+"-"+num2

#停驶硬币动画	
func stopCoinAni()->void:
	$hbox/Label5/Label4/coin.playing=false
	$hbox/Label5/Label4/coin.frame=0
	pass
	
	
	
