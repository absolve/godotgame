extends PanelContainer

var attr=preload("res://scenes/attr.tscn")
var attrInt=preload("res://scenes/attrInt.tscn")

onready var list=$ScrollContainer/PanelContainer/list

func _ready():
	pass

#添加字符串的属性框
func addAttr(name,value):
	var temp=attr.instance()
	temp.key=str(name)
	temp.value=str(value)
	list.add_child(temp)
	
#添加整形的属性框	
func addAttrInt(name,value):
	var temp=attrInt.instance()
	temp.key=str(name)
	temp.value=str(value)
	list.add_child(temp)


func clearAttr():
	for child in list.get_children():
		child.queue_free()
