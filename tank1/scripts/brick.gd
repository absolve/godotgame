extends Node2D


#根据类型来判断是那种方块

var type=0
var size=16	#碰撞都是正方形

var hitCount=0	#砖块击中次数  同一个方向被击中2次就没了  不同方向会剩下一小格
var lastDir=0 #上一次子弹的方向

var rect= Rect2(Vector2(-8,-8),Vector2(16,16))
var debug=true
onready var _sprite=$Sprite
var offset=Vector2.ZERO  #图片原点的坐标  每次被击中的话中心点会发生变化

var aniStartTime=0	#动画时间
var aniFps=50

func _ready():
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
	
	pass

	
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
func hit(dir):
	if type==0:	#砖块
		if hitCount==0:
			if dir==0:	#上
				_sprite.region_rect = Rect2(0,0,size,size/2)
				_sprite.position.y-=size/4
				rect.size=Vector2(size,size/2)
				offset.y=-size/4
				pass
			elif dir==1:#下
				_sprite.region_rect = Rect2(0,size/2,size,size/2)
				_sprite.position.y+=size/4
				rect.size=Vector2(size,size/2)
				rect.position.y+=size/2
				offset.y=size/4
				pass
			elif dir==2:	#左
				_sprite.region_rect = Rect2(0,0,size/2,size)
				_sprite.position.x-=size/4
				rect.size=Vector2(size/2,size)
				offset.x=-size/4
				pass
			elif dir==3:#右
				_sprite.region_rect = Rect2(0,0,size/2,size)
				_sprite.position.x+=size/4
				rect.size=Vector2(size/2,size)
				rect.position=Vector2(0,-size/2)
				offset.x=size/4
				pass	
			lastDir=dir	
			hitCount+=1
			update()
		elif hitCount==1:
			rect.size=Vector2(size/2,size/2)
			if dir==0:#上
				offset.y=-size/4
				if lastDir==0 or lastDir==1:
					queue_free()
				elif lastDir==2:
					_sprite.region_rect = Rect2(0,size/2,size/2,size/2)
					_sprite.position.y-=size/4
					rect.size=Vector2(size/2,size/2)
					pass
				elif lastDir==3:
					_sprite.region_rect = Rect2(0,size/2,size/2,size/2)
					_sprite.position.y+=size/4
					rect.size=Vector2(size/2,size/2)
					pass
			elif dir==1:	#下
				offset.y=size/4
				if lastDir==0 or lastDir==1:
					queue_free()	
				elif lastDir==2:
					print("lastDir==2")
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.x-=size/4
					rect.position.y=0
					pass
				elif lastDir==3:
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.x+=size/4
					rect.position.y=0
					pass	
			elif dir==2:#左
				offset.x=size/4
				if lastDir==2 or lastDir==3:
					queue_free()	
				elif lastDir==0:
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.x+=size/4
					rect.position=Vector2(0,-size/2)
					pass
				elif lastDir==1:
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.x-=size/4
					pass
			elif dir==3:#右
				offset.x=-size/4
				if lastDir==2 or lastDir==3:
					queue_free()	
				elif lastDir==0:
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.x+=size/4
					#rect.position=Vector2(0,-size/2)
					rect.position.y=0
					pass
				elif lastDir==1:
					print("lastDir==1")
					_sprite.region_rect = Rect2(size/2,0,size/2,size/2)
					_sprite.position.x-=size/4
					rect.position.x=0
				#	rect.position=Vector2(0,-size/2)
					pass						
			hitCount+=1
			update()
			pass	
		else: #第三次击中自动消失 
			queue_free()
			pass
		pass
	pass


#第二次击中砖块
#func brickHitSecond(dir):
#	if lastDir==dir:
#		queue_free()
#	else:
#		if dir==0:
#			if lastDir==0:
#				queue_free()
#			elif lastDir==1:
#				queue_free()
#
#			elif lastDir==2:	#左
#				$Sprite.region_rect = Rect2(size/2,0,size/2,size/2)
#				$Sprite.position.y-=size/4
#				$Area2D/shape.scale.y=0.5
#				$Area2D.position.y-=size/4
#				pass
#			elif lastDir==3:	#右
#				$Sprite.region_rect = Rect2(0,0,size/2,size/2)
#				$Sprite.position.y-=size/4
#				$Area2D/shape.scale.y=0.5
#				$Area2D.position.y-=size/4
#				pass
#		elif dir==1:	
#			if lastDir==0:
#				queue_free()
#			elif lastDir==1:
#				queue_free()
#
#			elif lastDir==2:
#				$Sprite.region_rect = Rect2(0,0,size/2,size/2)
#				$Sprite.position.y+=size/4
#				$Area2D/shape.scale.y=0.5
#				$Area2D.position.y+=size/4
#				pass
#			elif lastDir==3:
#				$Sprite.region_rect = Rect2(size/2,0,size/2,size/2)
#				$Sprite.position.y+=size/4
#				$Area2D/shape.scale.y=0.5
#				$Area2D.position.y+=size/4
#				pass
#			pass
#		elif dir==2:	#左
#			if lastDir==0:
#				$Sprite.region_rect = Rect2(0,size/2,size/2,size/2)
#				$Sprite.position.x-=size/4
#				$Area2D/shape.scale.x=0.5
#				$Area2D.position.x-=size/4
#
#			elif lastDir==1:
#				$Sprite.region_rect = Rect2(size/2,0,size/2,size/2)
#				$Sprite.position.x-=size/4
#				$Area2D/shape.scale.x=0.5
#				$Area2D.position.x-=size/4
#			elif lastDir==2:
#				queue_free()
#
#			elif lastDir==3:
#				queue_free()
#
#		elif dir==3:	#右
#			if lastDir==0:
#				$Sprite.region_rect = Rect2(0,0,size/2,size/2)
#				$Sprite.position.x+=size/4
#				$Area2D/shape.scale.x=0.5
#				$Area2D.position.x+=size/4
#			elif lastDir==1:
#				$Sprite.region_rect = Rect2(size/2,0,size/2,size/2)
#				$Sprite.position.x+=size/4
#				$Area2D/shape.scale.x=0.5
#				$Area2D.position.x+=size/4
#
#			elif lastDir==2:
#				queue_free()
#
#			elif lastDir==3:
#				queue_free()
				


#设置类型
func setType(type:int):
	
	pass

func get_class():
	return 'brick'
