extends Area2D

var type=0	#0是五角星




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

func destroy():
	queue_free()
	


func _on_bonus_body_entered(body):
	if body.is_in_group(Game.groups['player']):
		print(body)
	else:
		pass	
	pass # Replace with function body.
