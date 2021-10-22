extends Control

onready var list=$list
func _ready():
	addItem()
	pass

func addItem():
	var mario=load("res://icon/mario.png")
	var box=load("res://icon/blockq_0.png")
	var brick=load("res://icon/gnd_red_1.png")
	var goomba=load("res://icon/goombas_0.png")
	var koopa=load("res://icon/koopa_0.png")
	var coin=load("res://icon/coin_use00.png")
	var del=load("res://icon/del.png")
	for i in constants.tiles:
		if i=='mario':
			list.add_item(i,mario)
		elif i=='box':
			list.add_item(i,box)
		elif i=='brick'	:
			list.add_item(i,brick)
		elif i=='goomba':
			list.add_item(i,goomba)
		elif i=='koopa':	
			list.add_item(i,koopa)
		elif i=='coin':
			list.add_item(i,coin)	
		elif i=='del':
			list.add_item(i,del)	
	pass
