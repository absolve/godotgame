extends Node2D


func _ready():
	setScore()


#设置分数
func setScore():
	$msg/panel/hbox/score/best_round2.text=str(Game.data['best_round'])
	$msg/panel/hbox/score/last_round2.text=str(Game.data['last_round'])
	$msg/panel/hbox/score/rounds_played2.text=str(Game.data['rounds_played'])
	$msg/panel/hbox/score/avg_per_round2.text=str(stepify(Game.data['avg_per_round'],0.01))
	$msg/panel/hbox/score/colors_earned2.text=str(Game.data['colors_earned'])


func _process(delta):
	update()
	
func _draw():
	draw_line(Vector2(120,0),Vector2(120,$msg.position.y-130),Game.lineColor[0],0.5,true)
	draw_line(Vector2(200,0),Vector2(200,$msg.position.y-130),Game.lineColor[0],0.5,true)


