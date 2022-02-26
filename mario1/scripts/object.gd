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
var offsetX=0
var offsetY=0
var collisionShow=false  #测试的时候显示是否碰撞

func _ready():
#	set_process(false)
#	set_physics_process(false)
	pass 



func getRect():
	var temp =rect
	temp.position+=position
	return temp

func getSize():
	return rect.size.x

func getSizeY():
	return rect.size.y

func getLeft():
	return position.x-rect.size.x/2

func getRight():
	return position.x+rect.size.x/2

func getTop():
	return position.y-rect.size.y/2

func getBottom():
	return position.y+rect.size.y/2

func _update(delta):
	if debug:
		update()

func _draw():
	if debug:
		draw_rect(rect,Color.white,false,1)
		if collisionShow:
			draw_rect(rect,Color(1,0,0,0.3))	
	pass
