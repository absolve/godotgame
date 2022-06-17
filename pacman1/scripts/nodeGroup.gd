extends Node2D


var data=[] #所有的节点
const node = preload("res://scripts/node.gd")
var debug=true
var nodeList=[]

func _ready():
	pass # Replace with function body.

func setMapArray(row:int,col:int):
	for y in range(row):
		data.append([])
		data[y].resize(col)
		for x in range(col):
			data[y][x] = null
#	print(data)
	pass

#读取节点
func createNode(file):
	for i in file:
		var temp = node.new()
		temp.position.x=i.x*Constants.tileWidth+Constants.tileWidth/2
		temp.position.y=i.y*Constants.tileWidth+Constants.tileWidth/2
		temp.type=i.type
#		print(temp.position)
		add_child(temp)
		data[i.y][i.x]=temp
		nodeList.append(temp)
#		print(temp.position)
#	var temp = node.instance()
#	temp.position.x=328
#	temp.position.y=8
#	temp.type="node"
#	add_child(temp)
#	data[0][0]=temp

	setHorizontallyNode()
	setVerticallyNode()
	pass

func setHorizontallyNode():
	for i in range(data.size()): #行
#		var col=data[i]
		var node=null
		for y in range(data[i].size()): #列
			if data[i][y]&&data[i][y].type=='node':
				if node==null:
					node=data[i][y]
				else:
					var other=data[i][y]
					node.neighbors[Constants.right]=other
					other.neighbors[Constants.left]=node
					node=other
	pass
	
func setVerticallyNode():
	if data.size()>0:
		var width=data[0].size()
		for i in range(width):
			var node=null
			for y in range(data.size()):
				if data[y][i]&&data[y][i].type=='node':
					if node==null:
						node=data[y][i]
					else:
						var other=data[y][i]
						node.neighbors[Constants.down]=other
						other.neighbors[Constants.up]=node
						node=other
					pass
	pass



