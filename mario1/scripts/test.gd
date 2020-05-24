extends Node2D


func _ready():
	pass # Replace with function body.



func _on_Button_pressed():
	$mario.beforeSmall2big()
	pass # Replace with function body.


func _on_Button2_pressed():
	$mario.beforebig2fire()
	pass # Replace with function body.


func _on_Button3_pressed():
	$mario.setInvincible()
	pass # Replace with function body.
