extends Node2D

var rect=Rect2(Vector2(-14,-14),Vector2(28,28))
var dir=Game.up # 0上 1下 2左 3右
var debug=false
var isStop=false#是否停止
var bullet=Game.bullet
var bullets=[]
var bulletMax=1	#发射最大子弹数
var life=1  #生命默认1

#获取矩形
func getRect()->Vector2:
	var temp =rect
	temp.position+=position
	return temp

func getSize():
	return rect.size.x
	
func _draw():
	if debug:
		draw_rect(rect,Color.white,false,1,true)
	pass	
