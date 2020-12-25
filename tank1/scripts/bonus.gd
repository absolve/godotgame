extends Node2D

var type=0	#0是手雷 1帽子 2时钟 3 铲子 4坦克 5星星 6手枪 7船

var rect=Rect2(-16,-16,32,32)


func _ready():
	if type==0:
		$Sprite.texture=Game.grenade
		pass
	elif type==1:
		$Sprite.texture=Game.helmet
		pass
	elif type==2:
		$Sprite.texture=Game.clock
		pass
	elif type==3:
		$Sprite.texture=Game.shovel
		pass
	elif type==4:
		$Sprite.texture=Game.tank
		pass
	elif type==5:
		$Sprite.texture=Game.star
		pass
	elif type==6:
		$Sprite.texture=Game.gun
		pass
	elif type==7:
		$Sprite.texture=Game.boat
		pass	
	pass

func getRect()->Vector2:
	var temp =rect
	temp.position+=position
	return temp

func getSize():
	return rect.size.x

func destroy():
	queue_free()
	

func _draw():
#	if debug:
	draw_rect(rect,Color.white,false,1,true)
	pass	
