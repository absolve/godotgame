extends Node2D

#class_name enemy

var rect=Rect2(Vector2(-14,-14),Vector2(28,28))
var speed=40 
var dir=1 # 0上 1下 2左 3右
var bullets=[]
var type=0  # 0 typeA  1 typeB 2 typeC 3 typeD
var bulletMax=1	#发射最大子弹数
var armour=0  #护甲等级  不同等级护甲不同
var bullet=Game.bullet
var vec=Vector2.ZERO

func _ready():
	randomize()
	if type==0:
		$ani.play("typeA")
	elif type==1:
		$ani.play("typeB")
	elif type==2:
		$ani.play("typeC")
	elif type==3:
		$ani.play("typeD")
	pass


#获取矩形
func getRect()->Vector2:
	var temp =rect
	temp.position+=position
	return temp

func getSize():
	return rect.size.x
	
func _process(delta):
	if dir==0:
		vec.y=-speed
		vec.x=0
	elif dir==1:
		vec.x=0
		vec.y=speed
	elif dir==2:
		vec.x=-speed
		vec.y=0
	elif dir==3:
		vec.y=0
		vec.x=speed		
	else:
		vec=Vector2.ZERO	
	animation(dir,vec)	
	position+=vec*delta		
	pass

func animation(dir,vec):
	if dir==0:
		$ani.flip_v=true
		$ani.flip_h=true
		$ani.rotation_degrees=0
		pass
	elif dir==1:
		$ani.flip_v=false
		$ani.flip_h=false
		$ani.rotation_degrees=0
		pass
	elif dir==2:
		$ani.flip_v=false
		$ani.flip_h=false
		if $ani.rotation_degrees!=90:
			$ani.rotation_degrees=90
		pass
	elif dir==3:
		$ani.flip_v=false
		$ani.flip_h=false
		if $ani.rotation_degrees!=-90:
			$ani.rotation_degrees=-90

#改变方向
func turnDirection():
	dir = randi()%4

	pass

func setPos(pos:Vector2):
	position=pos

func hit():
	pass

func get_class():
	return 'enemy'
