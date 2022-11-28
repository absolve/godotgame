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
var active=true#是否是活动的
var maxXVel=0
var maxYVel=0
var mask=[] #用来判断物体之前是否可以碰撞
var destroy=false
var localx=0  #地图中位置
var localy=0
var isOnFloor=false #是否在地面上

func _ready():
#	debug=true
#	set_process(false)
#	set_physics_process(false)
	pass 



func getRect()->Rect2:
	var temp =rect
	temp.position+=position
	return temp

func getCenterX():
	return position.x
	
func getCenterY():
	return position.y

func getSize()->float:
	return rect.size.x

func getSizeY()->float:
	return rect.size.y

func getLeft()->float:
	return position.x-rect.size.x/2

func getRight()->float:
	return position.x+rect.size.x/2

func getTop()->float:
	return position.y-rect.size.y/2

func getBottom()->float:
	return position.y+rect.size.y/2

func checkMask(obj):
	return mask.has(obj)
		
func pause():
	pass
	
func resume():
	pass	

func _update(delta):
#	if debug:
#		update()
	pass	

func _draw():
	if debug:
		draw_rect(rect,Color.white,false,1)
		if collisionShow:
			draw_rect(rect,Color(1,0,0,0.3))	
	pass
