extends Node




signal baseDestroyed

var groups=['player','base']

var player1={"up":KEY_W,"down":KEY_S,"left":KEY_A,"right":KEY_D,'fire':KEY_J}

enum tank_state{IDLE,DEAD,STOP,START}


func _ready():
	pass 

#更改场景
func changeScene(stagePath):
#	Splash.find_node("ani").play("moveIn")
#	yield(Splash.find_node("ani"),"animation_finished")
	set_process_input(false)
	get_tree().change_scene(stagePath)
	set_process_input(true)
#	Splash.find_node("ani").play("moveOut")

func loadMap(level):
	pass

