extends Node2D

#参考资料 https://developer.ibm.com/technologies/javascript/tutorials/wa-build2dphysicsengine/
#根据类型来判断是那种方块

var type=0
var size=16	#碰撞都是正方形

var hitCount=0	#砖块击中次数  同一个方向被击中2次就没了  不同方向会剩下一小格
var lastDir=0 #上一次子弹的方向

var rect= Rect2(Vector2(-8,-8),Vector2(16,16))
var debug=true

func _ready():
	if type==0:
		$Sprite.texture=Game.brick	
	elif type==1:
		$Sprite.texture=Game.stone
	elif type==2:
		$Sprite.texture=Game.water
		$Area2D.collision_mask=1+2	
	elif type==3:
		$Sprite.texture=Game.bush
		$Area2D.collision_mask=4
		$Sprite.z_index=2	
	elif type==4:
		$Sprite.texture=Game.ice	
	

func setPos(pos:Vector2):
	rect.position=pos

func getRect()->Rect2:
	var temp =rect
	temp.position+=position
	return temp

func getSize():
	return rect.size.x

func _draw():
#	if debug:
#		draw_rect(rect,Color.white,false,1,true)
	
	pass

	
func _process(delta):
#	update()
	
	pass
	
func _physics_process(delta):
	
	pass
	#print("brick _physics_process")
#	var list=$Area2D.get_overlapping_bodies()
#	for body in list:
#		if body.get_class()=="player" or body.get_class()=="enemy":
#		#	print(1111111111111)	
#			if type==3 or type==4:	#草丛 冰块
#				return
#
#			var dx=(position.x-body.position.x)/(size/2)
#			var dy=(position.y-body.position.y)/(size/2)
#			var absDX = abs(dx)
#			var absDY = abs(dy)
#
#			if abs(absDX - absDY) < .1:
#				if dx<0:
#					body.position.x=position.x+size/2+body.size/2				
#				else:
#					body.position.x=position.x-size/2-body.size/2
#
#				if dy<0:
#					body.position.y=position.y+size/2+body.size/2			
#				else:
#					body.position.y=position.y-size/2-body.size/2						
#			elif absDX > absDY:
#				if dx<0:
#					body.position.x=position.x+size/2+body.size/2				
#				else:
#					body.position.x=position.x-size/2-body.size/2	
#			else:
#				if dy<0:
#					body.position.y=position.y+size/2+body.size/2
#				else:
#					body.position.y=position.y-size/2-body.size/2
#
#				pass
#		elif body.get_class()=="bullet":
#			if type==1:	#石头
#				if body.power>1:
#					queue_free()
#					body.addExplode(false)
#					body.destroy()
#					pass
#				else:
#					body.addExplode(false)
#					body.destroy()
#
#			elif type==3:	#草丛
#
#				pass
#			elif type==0:	#砖块			
#				if body.dir==0:	#上
#					if hitCount==0:
#						$Sprite.region_rect=Rect2(0,0,size,size/2)
#						$Sprite.position.y-=size/4
#						$Area2D/shape.scale.y=0.5
#						$Area2D.position.y-=size/4
#						pass
#					elif hitCount==1:
#						brickHitSecond(body.dir)							
#					else:
#						queue_free()				
#				elif body.dir==1:	#下
#					if hitCount==0:
#						$Sprite.region_rect=Rect2(0,size/2,size,size/2)
#						$Sprite.position.y+=size/4
#						$Area2D/shape.scale.y=0.5
#						$Area2D.position.y+=size/4
#					elif hitCount==1:
#						brickHitSecond(body.dir)	
#					else:
#						queue_free()				
#				elif body.dir==2:	#左
#					if hitCount==0:
#						$Sprite.region_rect=Rect2(0,0,size/2,size)
#						$Sprite.position.x+=size/4
#						$Area2D/shape.scale.x=0.5
#						$Area2D.position.x+=size/4
#					elif hitCount==1:
#						brickHitSecond(body.dir)	
#					else:
#						queue_free()	
#
#				elif body.dir==3:	#右
#					if hitCount==0:
#						$Sprite.region_rect=Rect2(size/2,0,size/2,size)
#						$Sprite.position.x-=size/4
#						$Area2D/shape.scale.x=0.5
#						$Area2D.position.x-=size/4
#					elif hitCount==1:
#						brickHitSecond(body.dir)	
#					else:
#						queue_free()
#					pass
#				lastDir=body.dir
#				hitCount+=1
#				body.addExplode(false)
#				body.destroy()
#				pass
	

#第二次击中砖块
func brickHitSecond(dir):
	if lastDir==dir:
		queue_free()
	else:
		if dir==0:
			if lastDir==0:
				queue_free()
			elif lastDir==1:
				queue_free()
				
			elif lastDir==2:	#左
				$Sprite.region_rect = Rect2(size/2,0,size/2,size/2)
				$Sprite.position.y-=size/4
				$Area2D/shape.scale.y=0.5
				$Area2D.position.y-=size/4
				pass
			elif lastDir==3:	#右
				$Sprite.region_rect = Rect2(0,0,size/2,size/2)
				$Sprite.position.y-=size/4
				$Area2D/shape.scale.y=0.5
				$Area2D.position.y-=size/4
				pass
		elif dir==1:	
			if lastDir==0:
				queue_free()
			elif lastDir==1:
				queue_free()
				
			elif lastDir==2:
				$Sprite.region_rect = Rect2(0,0,size/2,size/2)
				$Sprite.position.y+=size/4
				$Area2D/shape.scale.y=0.5
				$Area2D.position.y+=size/4
				pass
			elif lastDir==3:
				$Sprite.region_rect = Rect2(size/2,0,size/2,size/2)
				$Sprite.position.y+=size/4
				$Area2D/shape.scale.y=0.5
				$Area2D.position.y+=size/4
				pass
			pass
		elif dir==2:	#左
			if lastDir==0:
				$Sprite.region_rect = Rect2(0,size/2,size/2,size/2)
				$Sprite.position.x-=size/4
				$Area2D/shape.scale.x=0.5
				$Area2D.position.x-=size/4
				
			elif lastDir==1:
				$Sprite.region_rect = Rect2(size/2,0,size/2,size/2)
				$Sprite.position.x-=size/4
				$Area2D/shape.scale.x=0.5
				$Area2D.position.x-=size/4
			elif lastDir==2:
				queue_free()
				
			elif lastDir==3:
				queue_free()
				
		elif dir==3:	#右
			if lastDir==0:
				$Sprite.region_rect = Rect2(0,0,size/2,size/2)
				$Sprite.position.x+=size/4
				$Area2D/shape.scale.x=0.5
				$Area2D.position.x+=size/4
			elif lastDir==1:
				$Sprite.region_rect = Rect2(size/2,0,size/2,size/2)
				$Sprite.position.x+=size/4
				$Area2D/shape.scale.x=0.5
				$Area2D.position.x+=size/4
				
			elif lastDir==2:
				queue_free()
				
			elif lastDir==3:
				queue_free()
				


#设置类型
func setType(type:int):
	
	pass

func get_class():
	return 'brick'
