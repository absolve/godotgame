extends "res://scripts/object.gd"
#"""
#大的金币
#"""
onready var ani=$ani
var status=constants.empty
var coin=preload("res://scenes/coin.tscn")

func _ready():
	mask=[constants.box]
	type=constants.bigCoin
#	debug=true
	rect=Rect2(Vector2(-10,-15),Vector2(20,30))	
	ani.play('coin')
	pass


func floorCollide(obj):
	if obj.type==constants.box:
		print('2121')
		if obj.status==constants.bumped:
			SoundsUtil.playCoin()
			active=false
			destroy=true
			var temp=coin.instance()
			temp.position=position
			temp.position.y=position.y-getSizeY()/2
			Game.addObj(temp)
			Game.addCoin(self,1)
			Game.addScore(position,200)
		pass
	pass
