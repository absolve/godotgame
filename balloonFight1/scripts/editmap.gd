extends Node2D

onready var itemList=$layer/Control/TabContainer/map/VBox/itemList
onready var attribute=$layer/Control/TabContainer/map/VBox/attribute
onready var _tab=$layer/Control/TabContainer
onready var camera=$Camera2D
onready var _loadDiaglog=$layer/loadDialog
onready var _saveDialog=$layer/FileDialog

const minWidthNum=20  #一个屏幕宽20块
const blockSize=16  #方块的大小
var selectItem='' #选择的item 名字
var selectItemType='' #选择的item类型'
var selectedItem={'x':-1,'y':-1}	#编辑选中方块
var allTiles=[]  #所有方块的集合
var currentLevel  #文件数据
var isPress=false
var currMousePos=Vector2.ZERO  #当前鼠标位置
var height
var width
var font

func _ready():
	VisualServer.set_default_clear_color(Color(0.1,0.1,0.1,0.1))
	itemList.connect("itemSelect",self,"selectItem")
	var viewRect=get_viewport_rect()
	width=viewRect.size.x
	height=viewRect.size.y
	font=DynamicFont.new()
	font.font_data = load("res://fonts/blocky.ttf")
	font.size = 20
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

#添加方块信息
func addItem(type,key,pos):
	if type=='del':
		return
	if type=='':
		return
	var g=Constants.tilesAttribute[key].duplicate()
	g.x=pos.x
	g.y=pos.y
	print(type,key,pos)
	allTiles.append(g)	

#删除一个方块
func delItem(pos:Vector2):
	var indexX = int(pos.x)/(blockSize)
	var indexY=int(pos.y)/(blockSize)
	var temp = {"x":indexX,"y":indexY}
	for i in range(allTiles.size()):
		if allTiles[i]["x"]==indexX&&allTiles[i]["y"]==indexY:
			allTiles.remove(i)
			break
			
func getItemPos(pos:Vector2):
	return {
		'x':int(pos.x)/blockSize,
		'y':int(pos.y)/blockSize
	}


#获取属性
func getItemAttr(pos:Vector2):
	var indexX = int(pos.x)/(blockSize)
	var indexY=int(pos.y)/(blockSize)
	for i in allTiles:
		if i["x"]==indexX&&i["y"]==indexY:
			attribute.clearAttr()
			for y in i.keys():  #根据
				if Constants.tilesAttributeType.has(y) && \
				 Constants.tilesAttributeType[y]=='int':
					attribute.addAttrInt(y,i[y])
				else:
					attribute.addAttr(y,i[y])
			#保存选中数据
			selectedItem["x"]=indexX	
			selectedItem["y"]=indexY
			break
	
	
	
#选择方块
func selectItem(type,itemName):
	selectItemType=type
	selectItem=itemName
	
func _process(delta):
	update()

func _input(event):	
	if _saveDialog.visible||_loadDiaglog.visible:
		return
	if event is InputEventKey:
		if event.is_pressed():
			if (event as InputEventKey).scancode==KEY_LEFT:	
				if camera.position.x>-minWidthNum/2*blockSize:  #前后一半屏幕
					camera.position.x-=15
			elif (event as InputEventKey).scancode==KEY_RIGHT:	
				if camera.position.x<width-minWidthNum/2*blockSize:
					camera.position.x+=15	
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and  event.pressed:
			if _tab.is_visible_in_tree()&& _tab.get_rect().has_point(camera.get_local_mouse_position()):
				return
#			if _toolBtn.is_visible_in_tree()&&_toolBtn.get_rect().has_point(get_global_mouse_position()):
#				return
			isPress=true
			if checkHasItem(get_global_mouse_position(),selectItemType):
				if selectItemType=='del':
					delItem(get_global_mouse_position())
				else:  #显示属性
					getItemAttr(get_global_mouse_position())
			else:	
				var pos=getItemPos(get_global_mouse_position())	
				addItem(selectItemType,selectItem,pos)
		elif !event.pressed:	
			isPress=false
	elif event is InputEventMouseMotion:	#移动
		if isPress:
			if checkHasItem(get_global_mouse_position(),selectItemType):
				if selectItemType=='del':
					delItem(get_global_mouse_position())
				else:  #显示属性
					getItemAttr(get_global_mouse_position())
			else:	
				var pos=getItemPos(get_global_mouse_position())	
				addItem(selectItemType,selectItem,pos)
		currMousePos=get_global_mouse_position()		

func _draw():
	for i in range(width/blockSize):
		draw_line(Vector2(i*blockSize,0),Vector2(i*blockSize,width),Color.gray,0.5,true)
	for i in range(height/blockSize):
		draw_line(Vector2(0,i*blockSize),Vector2(width,i*blockSize),Color.gray,0.5,true)
		
	for i in allTiles:
		if i.type=='water'||i.type=='tile':
			if Constants.mapTiles.has(i.type)&&Constants.mapTiles[i.type].has(str(i.spriteIndex)):
				draw_texture(Constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))
		elif i.type=='spinBall':
			if Constants.mapTiles.has(i.type)&&Constants.mapTiles[i.type].has(str(i.spriteIndex)):
				draw_texture(Constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize-30,i.y*blockSize),Color(1,1,1,0.7))
		elif i.type=='player':
			if Constants.mapTiles.has(i.type)&&Constants.mapTiles[i.type].has(str(i.spriteIndex)):
				draw_texture(Constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize-5,i.y*blockSize-13),Color(1,1,1,0.7))
			draw_string(font,Vector2(i.x*blockSize,i.y*blockSize),str(i.id),Color.white)
	draw_string(font,currMousePos+Vector2(16,0),'x:'+str(int(currMousePos.x)/blockSize)+" y:"
			+str(int(currMousePos.y)/blockSize),Color.white)


func _on_save_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()
	_saveDialog.current_dir=baseDir
	_saveDialog.popup_centered()



func _on_hide_pressed():
	pass # Replace with function body.


func _on_load_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()
	_loadDiaglog.current_dir=baseDir
	_loadDiaglog.popup_centered()



func _on_return_pressed():
	pass # Replace with function body.


func _on_loadDialog_confirmed():
	var dir=_loadDiaglog.current_dir
	var file=_loadDiaglog.current_file
	if file:
		loadMapFile(dir+"/"+file)



func _on_loadDialog_file_selected(path):
	if path:
		loadMapFile(path)



func _on_FileDialog_confirmed():
	if _saveDialog.current_path:
		save2File(_saveDialog.current_path)
	else:
		print("没有当前文件")


func _on_FileDialog_file_selected(path):
	if path:
		save2File(path)
	else:
		print("没有当前文件")
	
