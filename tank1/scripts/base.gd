extends KinematicBody2D

var destroy=false
var destroyImg=preload("res://sprites/base_destroyed.png")
var size=32

func _ready():
	#setBaseDestroyed()
	pass

func _physics_process(delta):
	pass

#基地被摧毁
func setBaseDestroyed():
	$Sprite.texture=destroyImg
	$shape.disabled=true
	Game.emit_signal("baseDestroyed")
	pass
	
func get_class():
	return 'base'
