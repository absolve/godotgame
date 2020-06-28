extends Node2D


export var num = 40 #粒子数量
export var pos=Vector2.ZERO	#发射位置

var particle=preload("res://scenes/particle.tscn")

func _ready():
	position=pos
#	print(52/255)
	
	print(stepify(randf(),0.1))
	
	randomize()
	 
func setPos(pos:Vector2):
	position=pos

func addParticle():
	for i in range(num):
		var temp=particle.instance()
		temp.gravity+=randi()%30
		temp.dropSpeed+=randi()%30
		var xspeed=randi()%380
		var rotateSpeed = randi()%50
		var dropXSpeed = randi()%40
		if randi()%10>=5:
			temp.xSpeed=xspeed
			temp.rotateSpeed=rotateSpeed
		else:
			temp.xSpeed=-xspeed
			temp.rotateSpeed=-rotateSpeed
		
		if randi()%10>=5:
			temp.dropXSpeed=dropXSpeed
		else:
			temp.dropXSpeed=-dropXSpeed
			
		var r=stepify(randf(),0.1)
		var g=stepify(randf(),0.1)
		var b=stepify(randf(),0.1)
		
		temp.rgb=Color(r,g,b)
		

		#print(stepify(randf(),0.1))
		
		add_child(temp)

#添加随机粒子	
func addRandomParticle():
	
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
