extends PanelContainer

onready var list=$list
signal itemSelect

func _ready():
	for i in Constants.tilesAttribute.keys():
		var type=Constants.tilesAttribute[i]['type']	
		if type=='del':
			if Constants.mapTiles.has(type)&&!Constants.mapTiles[type].empty():
				list.add_item(i,Constants.mapTiles[type]['0'])
			else:
				list.add_item(i)	
		else:
			if Constants.mapTiles.has(type)&&!Constants.mapTiles[type].empty():
				var index=Constants.tilesAttribute[i]['spriteIndex']
				list.add_item(i,Constants.mapTiles[type][str(index)])
			else:
				list.add_item(i)
	


func _on_list_item_selected(index):
	var name=list.get_item_text(index)
	var t=Constants.tilesAttribute[name]['type']
	emit_signal("itemSelect",t,name)
	

