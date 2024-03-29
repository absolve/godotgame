extends Node2D


var dir=Game.down # 0上 1下 2左 3右
var speed=160  
var type=Game.bulletType.players
var playerID  #玩家id
var power=Game.bulletPower.normal  #1是基本火力 2是最强火力
#var winSize=Vector2(480,416)	#屏幕大小
var size=Vector2(6,8)	#图片大小
var vec= Vector2.ZERO
var isValid=false
var rect=Rect2(Vector2(-3,-4),Vector2(6,8))



func _ready():
	if dir==Game.up:
		$Sprite.flip_v=true
		vec.x=0
		vec.y=-speed
	elif dir==Game.down:
		vec.x=0
		vec.y=speed
	elif dir==Game.left:
		$Sprite.rotation_degrees=90
		$Sprite.rotation_degrees=90
		rect =Rect2(Vector2(-4,-3),Vector2(8,6))
		vec.x=-speed
		vec.y=0
	elif dir==Game.right:
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

#func setFastSpeed():
#	speed=200
#	pass

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

func setPlayerId(playerId):
	self.playerID=playerId
	pass

func setDir(dir):
	self.dir=dir

func getDir():
	return self.dir

func setPower(power):
	if power==Game.bulletPower.normal:
		speed=180
	elif power==Game.bulletPower.fast:
		speed=380
	elif power==Game.bulletPower.super:
		speed=380
		pass
	self.power=	power
		
func getPower():
	return power

func destroy():
	queue_free()

func addExplode(big):
	var temp=Game.explode.instance()
	if big:
		temp.big=true
	temp.position=position
	Game.otherObj.add_child(temp)
	destroy()


func _draw():
	#draw_rect(rect,Color.white,false,1,true)
	
	pass

