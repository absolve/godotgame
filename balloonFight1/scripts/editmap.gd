extends Node2D

onready var itemList=$layer/Control/TabContainer/map/VBox/itemList
onready var attribute=$layer/Control/TabContainer/map/VBox/attribute

const blockSize=16  #方块的大小
var selectItem='' #选择的item 名字
var selectItemType='' #选择的item类型'
var allTiles=[]  #所有方块的集合
var currentLevel  #文件数据

func _ready():
	VisualServer.set_default_clear_color(Color(0.1,0.1,0.1,0.1))
	
	itemList.connect("itemSelect",self,"itemSelect")
	pass

#载入文件
func loadMapFile(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		currentLevel= parse_json(file.get_as_text())
		allTiles.clear()
		for i in currentLevel['data']:
			allTiles.append(i)						
		file.close()
	else:
		print('文件不存在')	
	


#保存到文件
func save2File(fileName):
	var data={
		'data':allTiles,
	}
	var file = File.new()
	file.open(fileName, File.WRITE)
	file.store_string(to_json(data))
	file.close()

func checkTile(obj):
	var flag=false		
	for i in allTiles:
		if i["x"]==obj["x"]&&i["y"]==obj["y"]:	
			flag=true
			break
	return 	flag
	
#检查点击的位置是否有这个方块 背景和其他物体可以重复
func checkHasItem(pos,selectType):
	print(selectType)
	var x = pos.x
	var y=pos.y
	var indexX = int(x)/(blockSize)
	var indexY=int(y)/(blockSize)
	var flag=false
	if selectType=='del':
		for i in allTiles:
			if i["x"]==indexX&&i["y"]==indexY:
				flag=true
				break			
	else:	
		for i in allTiles:
			if i["x"]==indexX&&i["y"]==indexY:
				flag=true
	return 	flag



	
#选择方块
func selectItem(type,itemName):
	selectItemType=type
	selectItem=itemName
	
