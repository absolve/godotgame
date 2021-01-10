extends Node2D

#class_name enemy

var rect=Rect2(Vector2(-14,-14),Vector2(28,28))
var speed=40 
var dir=1 # 0上 1下 2左 3右

var type=0  # 0 typeA  1 typeB 2 typeC 3 typeD
var bulletMax=1	#发射最大子弹数
var armour=0  #护甲等级  不同等级护甲不同
var vec=Vector2.ZERO
var isStop=false#是否停止
var keepDirectionTime=0 #保持方向的时间 ms
var directionTime=0
var targetPos=Vector2(0,0)	#目标位置
var bullet=Game.bullet
var bullets=[]
var fireTime=0
var reloadTime=800


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
	keepDirectionTime = 1000
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
	
	directionTime+=delta*1000
	fireTime+=delta*1000
	#print(directionTime)
	if directionTime>keepDirectionTime:
		print("change")
		keepDirectionTime=randi()%1200+300	
		directionTime=0
		var dx=targetPos.x-position.x
		var dy=targetPos.y-position.y
		if abs(dx)>abs(dy):
			if dx<0:
				dir=2
			else:
				dir=3
		else:
			if dy<0:
				dir=0
			else:
				dir=1	
			
		dir=randi()%4
	if fireTime>reloadTime:
		fireTime=0
		reloadTime=randi()%1000
		fire()
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
	
	pass

func setStop(isStop):
	self.isStop=isStop

func setPos(pos:Vector2):
	position=pos

func hit():
	pass

#开火
func fire():
	print("dir",dir)	
	var del=[]
	for i in bullets: #清理无效对象
		print(is_instance_valid(i))
		if not is_instance_valid(i):
			del.append(i)
	for i in del:
		bullets.remove(bullets.find(i))
	if bullets.size()<bulletMax:
		var temp=bullet.instance()
		temp.setType("player")
		temp.position=position
		#temp.power=2
		temp.setDir(dir)
		bullets.append(temp)
		Game.mainScene.add_child(temp)

func get_class():
	return 'enemy'
