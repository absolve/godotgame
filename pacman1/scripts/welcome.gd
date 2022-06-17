extends Node2D


var nodes
var obj=[]
var pacman=preload("res://scenes/pacman.tscn")
var ghost=preload("res://scenes/ghost.tscn")



func _ready():
	nodes= load("res://scripts/nodeGroup.gd").new()

	var file = File.new()
	if file.file_exists("res://maps/test.json"):
		file.open("res://maps/test.json", File.READ)
		var currentLevel= parse_json(file.get_as_text())
		print(currentLevel)
	
		nodes.setMapArray(currentLevel['map']['height'],currentLevel['map']['width'])
		nodes.createNode(currentLevel['data'])
		
		file.close()
	else:
		print('文件不存在')	
	
	add_child(nodes)
#	obj.append(tempn)
	
	var temp=pacman.instance()
	temp.setStartNode(nodes.data[0][0])
	add_child(temp)
	obj.append(temp)
	
	var t=ghost.instance()
#	t.position=tempn.data[0][25].position
	add_child(t)
	obj.append(t)
#	update()	



func _process(delta):
#	update()
	for i in obj:
		
		i._update(delta)
	
	pass


func _draw():
	for y in nodes.nodeList:
		for i in y.neighbors.keys():
			if y.neighbors[i]:
				draw_line(y.position,y.neighbors[i].position,Color.white,5)
	pass
