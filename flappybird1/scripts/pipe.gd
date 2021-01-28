extends StaticBody2D


#地面的高度
const GROUND_HEIGHT = 56
const OFFSET_Y      = 55
const PIPE_WIDTH    = 26 #水管长度
const OFFSET_X      = 65 #每个水管的位置
  
#signal scoreChange	#分数变化

#状态
var state=game.stop
var speed=55	#速度


func _ready():
	randomize()
	add_to_group(game.group_pipe)


func _physics_process(delta):
	if state==game.stop:
		pass
	elif state==game.move:
	#	constant_linear_velocity = Vector2(-10,0)
		position.x-=speed*delta
		if position.x<-PIPE_WIDTH:
			#当最后一个水管坐标-PIPE_WIDTH时在屏幕外 放到最一根的后面 每个水管的距离是PIPE_WIDTH+OFFSET_X
			position.x=(PIPE_WIDTH+OFFSET_X)*3-PIPE_WIDTH
			setRandomYpos()
	pass	

#设置状态
func setState(newState):
	state=newState
	
#设置随机的y坐标 	
func setRandomYpos():
	position.y=rand_range(OFFSET_Y,game.winHeight-GROUND_HEIGHT-OFFSET_Y)
	

#进入到水管中间就算得分
func _on_Area2D_body_entered(body):
	#print("_on_Area2D_body_entered")
	if body.is_in_group(game.group_bird):
		game.emit_signal("scoreChange")

