extends Node2D


#根据类型来判断是那种方块

var type=0
var size=16	#碰撞都是正方形

var hitCount=0	#砖块击中次数  同一个方向被击中2次就没了  不同方向会剩下一小格
var lastDir=Game.up #上一次子弹的方向

var rect= Rect2(Vector2(-8,-8),Vector2(16,16))
var debug=false
onready var _sprite=$Sprite
var offset=Vector2.ZERO  #图片原点的坐标  每次被击中的话中心点会发生变化

var aniStartTime=0	#动画时间
var aniFps=50

func _ready():
	setType(type)
	

func setPos(pos:Vector2):
	rect.position=pos

func getRect()->Rect2:
	var temp =rect
	temp.position+=position
	return temp


func getPos():
	return position+offset

func getXSize():
	return rect.size.x

func getYSize():
	return rect.size.y

func _draw():
	if debug:
		draw_rect(rect,Color.white,false,1,true)

	
func _process(delta):
	#update()
	if type==2:
		aniStartTime+=delta*60
		if aniStartTime>aniFps:
			aniStartTime=0
			if _sprite.texture==Game.water:
				_sprite.texture=Game.water1
			else:
				_sprite.texture=Game.water	
	

#被击中的方向	
func hit(dir,power):
	if type==0:	#砖块
		if power==Game.bulletPower.super:
			queue_free()
		if hitCount==0:
			if dir==Game.up:	#上
				_sprite.region_rect = Rect2(0,0,size,size/2)
				_sprite.position.y-=size/4
#				rect.size=Vector2(size,size/2)
#				offset.y=-size/4
			elif dir==Game.down:#下
				_sprite.region_rect = Rect2(0,size/2,size,size/2)
				_sprite.position.y+=size/4
#				rect.size=Vector2(size,size/2)
#				rect.position.y+=size/2
#				offset.y=size/4
			elif dir==Game.left:	#左
				_sprite.region_rect = Rect2(0,0,size/2,size)
				_sprite.position.x-=size/4
#				rect.size=Vector2(size/2,size)
#				offset.x=-size/4
			elif dir==Game.right:#右
				_sprite.region_rect = Rect2(0,0,size/2,size)
				_sprite.position.x+=size/4
#				rect.size=Vector2(size/2,size)
#				rect.position=Vector2(0,-size/2)
#				offset.x=size/4
			lastDir=dir	
			hitCount+=1
			update()
		elif hitCount==1:#第二次
	#		rect.size=Vector2(size/2,size/2)
			if dir==Game.up:#上
			#	offset.y=-size/4
				if lastDir==Game.up or lastDir==Game.down:
					queue_free()
				elif lastDir==Game.left:
					_sprite.region_rect = Rect2(0,size/2,size/2,size/2)
					_sprite.position.y-=size/4
#					rect.size=Vector2(size/2,size/2)
				elif lastDir==Game.right:
					_sprite.region_rect = Rect2(0,size/2,size/2,size/2)
					_sprite.position.y+=size/4
#					rect.size=Vector2(size/2,size/2)
			elif dir==Game.down:	#下
			#	offset.y=size/4
				if lastDir==Game.up or lastDir==Game.down:
					queue_free()	
				elif lastDir==Game.left:
				#	print("lastDir==2")
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.y+=size/4
#					rect.position.y=0
				elif lastDir==Game.right:
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.y+=size/4
#					rect.position.y=0	
			elif dir==Game.left:#左
	#			offset.x=-size/4
				if lastDir==Game.left or lastDir==Game.right:
					queue_free()	
				elif lastDir==Game.up:	
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.x-=size/4
			#		rect.position.y=0
				elif lastDir==Game.down:
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.x-=size/4
			elif dir==Game.right:#右
	#			offset.x=size/4
				if lastDir==Game.left or lastDir==Game.right:
					queue_free()	
				elif lastDir==Game.up:
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.x+=size/4
					#rect.position=Vector2(0,-size/2)
#					rect.position.y=0
				elif lastDir==Game.down:  #下
	#				print("lastDir==1")
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.x+=size/4					
			hitCount+=1
			update()
		else: #第三次击中自动消失 
			queue_free()

	elif type==1:#石头
		if power==Game.bulletPower.super:
			queue_free()		

				

#设置类型
func setType(type:int):
	if type==0:
		_sprite.texture=Game.brick	
	elif type==1:
		_sprite.texture=Game.stone
	elif type==2:
		_sprite.texture=Game.water
	elif type==3:
		_sprite.texture=Game.bush
		_sprite.z_index=2	
	elif type==4:
		_sprite.texture=Game.ice	
#		rect= Rect2(Vector2(-8,-8),Vector2(16,16))
#		offset=Vector2.ZERO	


#改变类型
func changeType(type:int):
	if self.type==Game.brickType.brickWall:
	#	rect= Rect2(Vector2(-8,-8),Vector2(16,16))
	#	offset=Vector2.ZERO	
		_sprite.region_rect = Rect2(0,0,size,size)
		_sprite.position=Vector2.ZERO
		hitCount=0
		lastDir=Game.up
	setType(type)	
	self.type=type

func getType():
	return type


func get_class():
	return 'brick'
