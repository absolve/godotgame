extends Control


func _ready():
	hide()
	var bird = game.get_main_node().get_node("bird")
	if bird:
		bird.connect("state_changed",self,"state_changed")
	pass

func state_changed(obj):
	#print("Control2121")
	if obj.get_state()==2:
		show()
		get_node("ani").play("show")
		var num = get_node("panel/hbox")
		game.count_to_score(num,int(game.score_current))
		print(game.score_current)
		print(game.best_score)
#		if game.score_current>game.best_score:
		#game.setBestScore(game.score_current)
		print("game.score_current>game.best_score")
		var bestnum = get_node("panel/hbox2")
		game.count_to_score(bestnum,int(game.best_score))
