extends Node2D

var destroy=false
var destroyImg=preload("res://sprites/base_destroyed.png")
var size=32

var rect=Rect2(Vector2(-14,-14),Vector2(28,28))


func _ready():
	#setBaseDestroyed()
	pass


func getRect()->Rect2:
	var temp =rect
	temp.position+=position
	return temp
	
func getSize():
	return rect.size.x

func getPos():
	return position

func _draw():
	draw_rect(rect,Color.white,false,1,true)
	pass

#基地被摧毁
func setBaseDestroyed():
	$Sprite.texture=destroyImg
	destroy=true
	var temp=Game.explode.instance()
	temp.big=true
	temp.position=position
	Game.otherObj.add_child(temp)
	Game.emit_signal("baseDestroyed")
	pass
	
func get_class():
	return 'base'
