extends Node2D

#游戏中所有物体的基本类
var debug=false
var rect=Rect2(Vector2.ZERO,Vector2.ZERO)
#var visible=true #是否可见
var isCollide=true #是否碰撞
var type=constants.empty  #类型
var gravity=0  #重力
var xVel=0 #x轴速度
var yVel=0 #y轴速度


func _ready():
	pass 

func _draw():
	if debug:
		draw_rect(rect,Color.white,false,1)
	pass

