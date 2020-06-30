extends Sprite


export var gravity=40
export var speed=1400	#y轴飞行速度
export var dropSpeed=10
export var xSpeed=200	#x偏移
export var rotateSpeed=40	#旋转速度	
export var dropXSpeed=0	#下落之后的x速度

#export var rgb={'r':0,'g':0,'b':0} #颜色
export var rgb= Color(0,0,0)

var angle = 0 #角度
var vec=Vector2.ZERO


func _ready():
	vec.y=-speed
	vec.x=xSpeed
	modulate=rgb
	#set_modulate(rgb)

func _process(delta):
	if vec.y>0:
		vec.y=dropSpeed
		vec.x=dropXSpeed
	else:
		vec.y+=gravity
	
	angle+=rotateSpeed*delta
	rotation_degrees=round(angle)
	
	if angle>360 or angle<-360:
		angle=0
	
	position+=vec*delta

	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
