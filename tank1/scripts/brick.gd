extends Node2D

#参考资料 https://developer.ibm.com/technologies/javascript/tutorials/wa-build2dphysicsengine/
#根据类型来判断是那种方块

var type=0
var size=16	#碰撞都是正方形

func _ready():
	if type==0:
		$Sprite.texture=Game.brick
		pass
	elif type==1:
		$Sprite.texture=Game.stone
		pass
	elif type==2:
		$Sprite.texture=Game.water
		$Area2D.collision_mask=1+2
		pass
	elif type==3:
		$Sprite.texture=Game.bush
		$Area2D.collision_mask=4
		$Sprite.z_index=2
		pass
	elif type==4:
		$Sprite.texture=Game.ice
		pass	
	pass


func _physics_process(delta):
	#print("brick _physics_process")
	var list=$Area2D.get_overlapping_bodies()
	for body in list:
		if body.get_class()=="player":
			#print("player")
			
			var dx=(position.x-body.position.x)/(size/2)
			var dy=(position.y-body.position.y)/(size/2)
			var absDX = abs(dx)
			var absDY = abs(dy)
			
			if abs(absDX - absDY) < .1:
				print(.1)
				if dx<0:
					body.position.x=position.x+size/2+body.size/2
					pass
				else:
					body.position.x=position.x-size/2-body.size/2
					pass
				if dy<0:
					body.position.y=position.y+size/2+body.size/2
					pass
				else:
					body.position.y=position.y-size/2-body.size/2
					pass	
			elif absDX > absDY:
				if dx<0:
					body.position.x=position.x+size/2+body.size/2
					pass
				else:
					body.position.x=position.x-size/2-body.size/2
					pass
				pass	
			else:
				if dy<0:
					body.position.y=position.y+size/2+body.size/2
					pass
				else:
					body.position.y=position.y-size/2-body.size/2
					pass
				pass

	
	pass

#设置类型
func setType(type:int):
	pass


func _on_Area2D_body_entered(body):
#	if body.get_class()=="player":
#		print("player")
#		#x轴判断
#		if position.x>body.position.x:
#			body.position.x=position.x-size/2-body.size/2
#			print(body.position.x)
#			body.vec=Vector2.ZERO
#		#	body.state=Game.tank_state.STOP
#			print(2222)
#			pass
#		else:
#			body.position.x=position.x+size/2+body.size/2
#			pass	
#		#调整y轴
##		if position.y>body.position.y:
##			body.position.y=position.y+size/2+body.size/2
##			pass
##		else:
##			body.position.y=position.y-size/2-body.size/2
##			pass
#
#		pass
	
	pass # Replace with function body.


func _on_Area2D_body_exited(body):
	
	pass # Replace with function body.
