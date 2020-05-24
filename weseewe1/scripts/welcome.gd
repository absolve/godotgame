extends Node2D


var offsety=80 #摄像机的y偏移
var pos=543
var cameray=400

var gravity=1000

func _ready():
	$block/spawnblock.init()
	pass # Replace with function body.



func _process(delta):
	
	pass

func _physics_process(delta):
	var velocity = $player/player.velocity
	if velocity.y>0:
		$camera.offset.y+=abs(velocity.y/100*0.2)
	elif velocity.y<0:
		$camera.offset.y-=abs(velocity.y/100*0.2)
	
	if $camera.offset.y>240:
		$camera.offset.y=240


func _on_btnStart_pressed():
	
	
	$block/particleUtil.pos=Vector2(240,400)
	$block/particleUtil.addParticle()
	
	
func _on_btnHelp_pressed():
	pass # Replace with function body.




func _on_btnStart_button_up():
	$ui/btnStart.rect_position.x+=5
	$ui/btnStart.rect_position.y-=5
	$ui/btnStart.modulate=Color(1,1,1)
	pass # Replace with function body.


func _on_btnStart_button_down():
	$ui/btnStart.rect_position.x-=5
	$ui/btnStart.rect_position.y+=5
	$ui/btnStart.modulate=Color(0.8,0.8,0.8)
	




func _on_btnScore_pressed():
	pass # Replace with function body.


func _on_btnScore_button_up():
	$ui/btnScore.rect_position.x+=5
	$ui/btnScore.rect_position.y-=5
	$ui/btnScore.modulate=Color(1,1,1)
	

func _on_btnScore_button_down():
	$ui/btnScore.rect_position.x-=5
	$ui/btnScore.rect_position.y+=5
	$ui/btnScore.modulate=Color(0.8,0.8,0.8)
	
	


func _on_btnSound_button_up():
	$ui/btnSound.rect_position.x+=5
	$ui/btnSound.rect_position.y-=5
	$ui/btnSound.modulate=Color(0.8,0.8,0.8)
	



func _on_btnSound_button_down():
	$ui/btnSound.rect_position.x-=5
	$ui/btnSound.rect_position.y+=5
	$ui/btnSound.modulate=Color(1,1,1)
	
func _on_btnSound_pressed():
	if Game.sound:
		Game.sound=false
	else:
		Game.sound=true
	



func _on_btnHelp_button_up():
	$ui/btnHelp.rect_position.x+=5
	$ui/btnHelp.rect_position.y-=5
	$ui/btnHelp.modulate=Color(1,1,1)



func _on_btnHelp_button_down():
	$ui/btnHelp.rect_position.x-=5
	$ui/btnHelp.rect_position.y+=5
	$ui/btnHelp.modulate=Color(0.8,0.8,0.8)
