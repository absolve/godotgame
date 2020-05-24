extends AnimatedSprite


#显示闪光的功能

var OFFSET=22 #偏移的位置

func _ready():
	randomize()
#	show()


#显示闪光
func show():
	visible=true
	play("default")
	pass

func setNewPos():
	position.x=randi()%OFFSET
	position.y=randi()%OFFSET


func _on_spark_animation_finished():
	setNewPos()
