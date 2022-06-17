extends Node2D


var mapWidth
var mapHeight

var tile=preload("res://scenes/tile.tscn")
var pellet=preload("res://scenes/pellet.tscn")
var item=preload("res://scenes/item.tscn")
var nodes
var itemList=[]

func _ready():
	
	pass # Replace with function body.

func loadMap(fileName):
	nodes= load("res://scripts/nodeGroup.gd").new()
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		var currentLevel= parse_json(file.get_as_text())
		nodes.setMapArray(currentLevel['map']['height'],currentLevel['map']['width'])
		nodes.createNode(currentLevel['data'])
		
		for i in currentLevel['items']:
			if i['type']=='fruit':
				var temp=item.instance()
				temp.position.x=i.x*Constants.tileWidth+Constants.tileWidth/2
				temp.position.y=i.y*Constants.tileWidth+Constants.tileWidth/2
				temp.type=i['type']
				add_child(temp)
			elif i['type']=='pellet':	
				var temp=pellet.instance()
				temp.position.x=i.x*Constants.tileWidth+Constants.tileWidth/2
				temp.position.y=i.y*Constants.tileWidth+Constants.tileWidth/2
				temp.type=i['type']
				add_child(temp)	
			pass
		for i in currentLevel['tiles']:
			var temp=tile.instance()
			temp.position.x=i.x*Constants.tileWidth+Constants.tileWidth/2
			temp.position.y=i.y*Constants.tileWidth+Constants.tileWidth/2
			temp.type=i['type']
			add_child(temp)
			
		file.close()
	else:
		print('文件不存在')	
	
	add_child(nodes)
	
	
	pass


func _draw():
	if nodes:
		for y in nodes.nodeList:
			for i in y.neighbors.keys():
				if y.neighbors[i]:
					draw_line(y.position,y.neighbors[i].position,Color.white,5)
	pass
