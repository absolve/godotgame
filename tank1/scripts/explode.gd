extends AnimatedSprite


var big=false
var size=Vector2(32,32)

func _ready():
	if big:
		play("explode_big")
	else:
		play("explode_small")	
	




func _on_explode_animation_finished():
	queue_free()
	pass 
