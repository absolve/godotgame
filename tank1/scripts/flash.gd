extends AnimatedSprite


var addNode:Node2D 	#添加的节点
var parentNode:Node2D	#节点添加的父节点
var loopNum=3	#循环次数

func _ready():
	playing=true
	pass


func _on_flash_animation_finished():
	print("_on_flash_animation_finished")
	loopNum-=1
	if loopNum<=0:
		if addNode!=null and parentNode!=null:
			parentNode.add_child(addNode)
		queue_free()
	pass # Replace with function body.
