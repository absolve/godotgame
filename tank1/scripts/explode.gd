extends AnimatedSprite


var big=false
var size=Vector2(32,32)

func _ready():
	if big:
		play("explode_big")
	else:
		play("explode_small")	
	
#	if position.x<size.x/2:
#		position.x=size.x/2
#	elif position.x>Game.winSize.x-size.x/2:
#		position.x=Game.winSize.x-size.x/2
#	if position.y<	size.y/2:
#		position.y=size.y/2
#	elif position.y>Game.winSize.y-size.y/2:
#		position.y=Game.winSize.y-size.y/2
#	pass 





func _on_explode_animation_finished():
	queue_free()
	pass 
