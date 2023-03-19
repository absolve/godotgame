extends Control

#var mapConfig

onready var _tree=$Panel/vbox/Tree
onready var okbtn=$Panel/vbox/HFlow/ok
onready var cancelbtn=$Panel/vbox/HFlow/cancel
var mapConfig="res://levels/mapInfo.ini"  #地图

signal selectMap 
signal cancel

func _ready():
	var root = _tree.create_item()
	root.set_text(0,"world")
	var file = File.new()
	if file.file_exists(mapConfig):
		file.open(mapConfig, File.READ)
		var mapConfig= parse_json(file.get_as_text())
		print(mapConfig)
		for i in mapConfig['maps']:
			var child1 = _tree.create_item(root)
			child1.set_text(0,'world:'+i['world'])
			if i.has('subLevel'):
				for y in i['subLevel']:
					var child2=_tree.create_item(child1)
					child2.set_text(0,'level:'+y['level'])
					child2.set_meta("filename",y['filename'])



func _on_ok_pressed():
	var item=_tree.get_selected()
	if item!=null:
		if item.has_meta("filename"):
			emit_signal("selectMap",item.get_meta("filename",""))
		else:
			emit_signal("selectMap","")	


func _on_cancel_pressed():
	emit_signal("cancel")

