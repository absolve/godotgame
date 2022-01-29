extends Control

onready var list=$list
signal itemSelect

func _ready():
	addItem()
	pass

func addItem():
	for i in constants.tilesAttribute.keys():
		var type=constants.tilesAttribute[i]['type']
		if type=='mario'||type=='goomba'||type=='koopa'||type=='del'\
			||type=='plant'||type=='coin':
			if constants.mapTiles.has(type)&&!constants.mapTiles[type].empty():
				list.add_item(i,constants.mapTiles[type]['0'])
			else:
				list.add_item(i,null)	
		elif type=='box'||type=='brick'||type=='bg':
			if constants.mapTiles.has(type)&&!constants.mapTiles[type].empty():
				var index=constants.tilesAttribute[i]['spriteIndex']
				list.add_item(i,constants.mapTiles[type][str(index)])
			else:
				list.add_item(i)
		elif type=='pipe'||type=='flag':
			if constants.mapTiles.has(type)&&!constants.mapTiles[type].empty():
				var index=constants.tilesAttribute[i]['spriteIndex']
				list.add_item(i,constants.mapTiles[type][str(index)])
			else:
				list.add_item(i)
			pass
		elif type=="collision":
			if constants.mapTiles.has(type) &&!constants.mapTiles[type].empty():
				var index=constants.tilesAttribute[i]['spriteIndex']
				list.add_item(i,constants.mapTiles[type][str(index)])
			else:
				list.add_item(i)			
	pass


func _on_list_item_selected(index):
	var name=list.get_item_text(index)
	var spriteIndex=0
	if constants.tilesAttribute[name].has('spriteIndex'):
		spriteIndex=constants.tilesAttribute[name]['spriteIndex']
	emit_signal("itemSelect",spriteIndex,name)
	pass # Replace with function body.
