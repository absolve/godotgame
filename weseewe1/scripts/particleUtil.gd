extends Node2D


export var num = 40 #粒子数量
export var pos=Vector2.ZERO	#发射位置

var particle=preload("res://scenes/particle.tscn")

func _ready():
	randomize()
	position=pos
#	print(52/255)
	$Timer.connect("timeout",self,"_randomParticle")
	
	print(stepify(randf(),0.1))
	
	#startRandomParticle()
	 
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
			
#		var r=stepify(randf(),0.1)
#		var g=stepify(randf(),0.1)
#		var b=stepify(randf(),0.1)	
#		temp.rgb=Color(r,g,b)
		temp.rgb=Color(Game.blockColor[randi()%10])
		#print(stepify(randf(),0.1))
		add_child(temp)

#添加随机粒子	
func startRandomParticle():
	$Timer.start()
	pass

func stopRandomParticle():
	$Timer.stop()
	
	

func _randomParticle():
	#print(12313)
	var temp=particle.instance()
	temp.gravity=randi()%20+20
	temp.position=Vector2(330,30+randi()%300)
	var xspeed=randi()%360+20
	var dropXSpeed = randi()%40
	temp.speed=0
	temp.xSpeed=-xspeed
	temp.dropXSpeed=-dropXSpeed
	var rotateSpeed = randi()%50
	if randi()%10>=5:
		temp.rotateSpeed=rotateSpeed
	else:
		temp.xSpeed=-xspeed
#	var r=stepify(randf(),0.1)
#	var g=stepify(randf(),0.1)
#	var b=stepify(randf(),0.1)
	
	temp.rgb=Color(Game.blockColor[randi()%10])
	add_child(temp)
	pass


