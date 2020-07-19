extends AnimatedSprite


var big=false


func _ready():
	if big:
		play("explode_big")
	else:
		play("explode_small")	
	
	pass 





func _on_explode_animation_finished():
	queue_free()
	pass 
