extends Node




signal baseDestroyed

var groups={'player':'player','base':'base',
			'enemy':'enemy','bullet':'bullet'}

var player1={"up":KEY_W,"down":KEY_S,"left":KEY_A,"right":KEY_D,'fire':KEY_J}

enum tank_state{IDLE,DEAD,STOP,START}

enum bulletType{players,enemy}

enum brickType{brickWall,stoneWall,bush,water,ice}

var explode=preload("res://scenes/explode.tscn")
var grenade =preload("res://sprites/bonus_grenade.png")
var helmet=preload("res://sprites/bonus_helmet.png")
var clock=preload("res://sprites/bonus_clock.png")
var shovel=preload("res://sprites/bonus_shovel.png")
var tank=preload("res://sprites/bonus_tank.png")
var star=preload("res://sprites/bonus_star.png")
var gun=preload("res://sprites/bonus_gun.png")
var boat=preload("res://sprites/bonus_boat.png")

var brick=preload("res://sprites/brick.png")
var stone=preload("res://sprites/stone.png")
var ice=preload("res://sprites/ice.png")
var bush=preload("res://sprites/bush.png")
var water=preload("res://sprites/water.png")

var mainRoot
var mainScene #主场景


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

