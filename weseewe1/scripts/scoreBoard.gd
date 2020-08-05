extends Node2D

func _ready():
	print(Game.data['best_round'])
	print(str("Best round  ",Game.data['best_round']))
	setScore()
	pass


#设置分数
func setScore():
	$msg/panel/hbox/score/best_round2.text=str(Game.data['best_round'])
	$msg/panel/hbox/score/last_round2.text=str(Game.data['last_round'])
	$msg/panel/hbox/score/rounds_played2.text=str(Game.data['rounds_played'])
	$msg/panel/hbox/score/avg_per_round2.text=str(Game.data['avg_per_round'])
	$msg/panel/hbox/score/colors_earned2.text=str(Game.data['colors_earned'])
	pass
