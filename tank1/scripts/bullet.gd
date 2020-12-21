extends Node2D


export var dir=2 # 0上 1下 2左 3右
var speed=80
var type=Game.bulletType.players
var playerID  #玩家id
var power=1  #1是基本火力 2是最强火力
#var winSize=Vector2(480,416)	#屏幕大小
var size=Vector2(6,8)	#图片大小
var vec= Vector2.ZERO

var rect=Rect2(Vector2(-3,-4),Vector2(6,8))

func _ready():
	if dir==0:
		$Sprite.flip_v=true
		vec.x=0
		vec.y=-speed
	elif dir==1:
		vec.x=0
		vec.y=speed
	elif dir==2:
		$Sprite.rotation_degrees=90
		$Sprite.rotation_degrees=90
		rect =Rect2(Vector2(-4,-3),Vector2(8,6))
		vec.x=-speed
		vec.y=0
	elif dir==3:
		$Sprite.rotation_degrees=-90
		$Sprite.rotation_degrees=-90
		rect =Rect2(Vector2(-4,-3),Vector2(8,6))
		vec.x=speed
		vec.y=0

		
func getRect()->Rect2:
	var temp =rect
	temp.position+=position
	return temp

func getSize():
	return rect.size.x

func setFastSpeed():
	speed=110
	pass

func _process(delta):
	position+=vec*delta
	
	pass		
	
func get_class():
	return 'bullet'

func getType():
	return type

func setType(type:String):
	if type=="player":
		self.type=Game.bulletType.players
	elif type=="enemy":
		self.type=Game.bulletType.enemy

func setDir(dir):
	self.dir=dir

func destroy():
	queue_free()

func addExplode(big):
	var temp=Game.explode.instance()
	if big:
		temp.big=true
	temp.position=position
	Game.mainScene.add_child(temp)
	
	
func _draw():
	draw_rect(rect,Color.white,false,1,true)
	
	pass

