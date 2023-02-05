extends Node2D

#"""
#地图显示砖块，箱子
#参考资料(关于碰撞) https://developer.ibm.com/technologies/javascript/tutorials/wa-build2dphysicsengine/
#"""
const blockSize=32  #方块的大小
const minWidthNum=20  #一个屏幕宽20块
const heightNun=15

var debug=true
var isPress=false #编辑时是否按下鼠标
var mapWidthSize=20  #地图宽度 
#var enemyList=[] #敌人列表
#var specialEntrance=[] #特殊入口 水管和树的入口
var currentLevel  #文件数据
var path="res://levels/1-1.json"
var mapDir="res://levels"	#内置地图路径
var currentMapWidth=0 #当前地图的宽度
var bg="overworld" #overworld   castle underwater
var time=400 #时间
var allTiles=[]  #所有方块的集合
var bgTiles=[]   #单独背景方块
var marioPos={} #mario地图出生地
var selectItem='' #选择的item 名字
var selectItemType='' #选择的item类型'
var selectItemLayer=0 #选择的item layer
var state=constants.empty
var selectedItem={'x':-1,'y':-1}	#编辑选中方块
#var delList=[] #删除列表
var timer=0
#var tick=2*60
var nextStatus=constants.empty
#var lastMarioXPos=0  #用来标记mario进入城堡是x位置
#var castleFlagObj=null #城堡旗帜  只有一个
#var checkPoint=[] #检查点 用于判断马里奥死亡后重新复活的位置
var marioDeathPos={'x':-1,'y':-1} #保存死亡时的位置
var music="" #背景音乐
#var screenbrick=[] #当前屏幕方块
var winWidth  #窗体大小
var winHeight
#var subLevel="" #子关卡 是否从水管或者树里面出来
#var pipeIndex=0 #当前水管入口的索引
var font

var mode="edit"  #game正常游戏  edit编辑  test测试  show展示
#onready var _brick=$brick
onready var _bg=$bg
onready var camera=$Camera2D
onready var _itemList=$layer/Control/tab/map/vbox/itemList
onready var _tab=$layer/Control/tab
onready var _itemAttr=$layer/Control/tab/map/vbox/attribute
onready var _toolBtn=$layer/Control/toolBtn
onready var _saveDialog=$layer/FileDialog
onready var _mapWidth=$layer/Control/tab/common/vbox/mapWidth
onready var _time=$layer/Control/tab/common/vbox/time
onready var _background=$layer/Control/tab/common/vbox/background
onready var _music=$layer/Control/tab/common/vbox/music
onready var _spriteSet=$layer/Control/tab/common/vbox/spriteset
onready var _mapName=$layer/Control/tab/common/vbox/mapName
onready var _nextLevel=$layer/Control/tab/common/vbox/nextLevel
onready var _status=$layer/Control/tab/common/vbox/status
onready var _subLevel=$layer/Control/tab/common/vbox/subLevel
onready var _bonusLevel=$layer/Control/tab/common/vbox/bonusLevel
onready var _underwater=$layer/Control/tab/common/vbox/underwater

#onready var _marioList=$mario
#onready var _brickList=$brick
#onready var _bulletList=$bullet
#onready var _itemsList=$item
#onready var _otherobjList=$otherObj
#onready var _enemyList=$enemy
onready var _loadDiaglog=$layer/loadDialog
onready var _title = $title
#onready var _bgList=$background
#onready var _poleList=$pole
onready var _fps=$layer/fps
#onready var _collisionList=$collision


func _ready():
	VisualServer.set_default_clear_color(Color(0.1,0.1,0.1,0.1))
	_itemList.connect("itemSelect",self,'selectItem')
#	Game.setMap(self)
#	winWidth= ProjectSettings.get_setting("display/window/size/width")
#	winHeight=ProjectSettings.get_setting("display/window/size/height")
#	print("winHeight",winHeight)
	font=DynamicFont.new()
	font.font_data = load("res://fonts/Fixedsys500c.ttf")
	font.size = 20
	_mapWidth.valueObj.connect("text_changed",self,"text_changed")
	if mode=='edit':
		_bg.hide()
		_title.hide()
	elif mode=='game':
		pass	
	elif mode=='test':
		pass
	elif mode=='show':	
		_bg.show()
		_tab.hide()
		_toolBtn.hide()	
		_title.hideTime()



#载入文件
func loadMapFile(fileName:String):
	var file = File.new()
	if file.file_exists(fileName):
		file.open(fileName, File.READ)
		currentLevel= parse_json(file.get_as_text())
		mapWidthSize=int(currentLevel['mapSize'])
		time =int(currentLevel['time'])
		if currentLevel['bg']=="overworld":
			_bg.color=Color(Game.backgroundcolor[0])
		elif currentLevel['bg']=="castle":
			_bg.color=Color(Game.backgroundcolor[1])
		elif currentLevel['bg']=="underwater":	
			_bg.color=Color(Game.backgroundcolor[2])
		
		_mapWidth.setValue(str(mapWidthSize))
		_time.setValue(str(currentLevel['time']))
		_background.setValue(str(currentLevel['bg']))
		_music.setValue(str(currentLevel['music']))
		music=str(currentLevel['music'])
		if currentLevel.has('mapName'):
			_mapName.setValue(str(currentLevel['mapName']))
		if 	currentLevel.has('status'):
			_status.setValue(str(currentLevel['status']))
		if currentLevel.has('nextLevel'):
			_nextLevel.setValue(str(currentLevel['nextLevel']))	
		if currentLevel.has('subLevel'):
			_subLevel.setValue(str(currentLevel['subLevel']))	
		if currentLevel.has('bonusLevel'):
			_bonusLevel.setValue(str(currentLevel['bonusLevel']))	
		if currentLevel.has('underwater'):
			_underwater.setValue(str(currentLevel['underwater']))	
		SoundsUtil.bgm=music
		SoundsUtil.isLowTime=false
		
		var pos = currentLevel['marioPos']
#		if !pos.empty():  #添加mario
#			if mode=='game' ||  mode=='show':
#				var temp=mario.instance()
#				temp.position.x=pos['x']*blockSize+blockSize/2
#				temp.position.y=pos['y']*blockSize+blockSize/2
#				temp.big=Game.playerData['mario']['big']
#				temp.fire=Game.playerData['mario']['fire']
#				_marioList.add_child(temp)
		
		marioPos=pos
		if mode=='edit':
			allTiles.clear()
			bgTiles.clear()
			
		for i in currentLevel['data']:
			if mode=='edit':
				allTiles.append(i)
#			if i['type'] =='brick':
#				if mode=='edit':
#					allTiles.append(i)
#				pass
#			elif i['type']=='box':
#				if mode=='edit':
#					allTiles.append(i)
#			elif i['type']=='goomba' || i['type']=='koopa'||\
#					i['type']==constants.plant:	
#				if mode=='edit':
#					allTiles.append(i)	
#			elif i['type']=='pipe':
#				if mode=='edit':
#					allTiles.append(i)
#			elif i['type']=='bg':	
#				if mode=='edit':
#					bgTiles.append(i)
#			elif  i['type']=='flag':  #旗杆
#				if mode=='edit':
#					allTiles.append(i)		
#			elif  i['type']=='collision':
#				if mode=='edit':
#					allTiles.append(i)
#			elif i['type']=='castleFlag':	
#				if mode=='edit':
#					allTiles.append(i)	
#			elif i['type']=='coin':
#				if mode=='edit':
#					allTiles.append(i)												
		file.close()
	else:
		print('文件不存在')	
		pass
	pass


#保存到文件
func save2File(fileName):
	var data={
		"mapSize":_mapWidth.getValue(),
		"bg":_background.getValue(),
		"music":_music.getValue(),
		'time':_time.getValue(),
		"mapName":_mapName.getValue(),
		"nextLevel":_nextLevel.getValue(),
		"subLevel":_subLevel.getValue(),
		"bonusLevel":_bonusLevel.getValue(),
		"underwater":_underwater.getValue(),
		'status':_status.getValue(),
		'marioPos':marioPos,
		'data':allTiles+bgTiles,
	}
#	print(data)
	var file = File.new()
	file.open(fileName, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	pass

func checkTile(obj):
	var flag=false		
	for i in allTiles:
		if i["x"]==obj["x"]&&i["y"]==obj["y"]:	
			flag=true
			break
	return 	flag		
		
func checkBgTile(obj):
	var flag=false		
	for i in bgTiles:
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
	if selectType=='bg':
		for i in bgTiles:
			if i["x"]==indexX&&i["y"]==indexY:
				flag=true
				break
		pass
	elif selectType=='del':
		for i in bgTiles+allTiles:
			if i["x"]==indexX&&i["y"]==indexY:
				flag=true
				break			
	else:	
		for i in allTiles:
			if i["x"]==indexX&&i["y"]==indexY:
#				print(i)
				if i.has('layer'):
					if int(i['layer'])==int(selectItemLayer):
						flag=true
				else:	
					flag=true
					
#	print(flag)
	return 	flag


#添加方块信息
func addItem(type,key,pos):
	if type=='del':
		return
	if not constants.tilesAttribute.has(key):
		print('item type error ',key)
		return	
	if key=='mario':
		marioPos={'x':pos.x,'y':pos.y}
		return
	var g=constants.tilesAttribute[key].duplicate()
	g.x=pos.x
	g.y=pos.y
	print(type,key,pos)
	if type=='bg':
		bgTiles.append(g)	
	else:	
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
	for i in range(bgTiles.size()):
		if bgTiles[i]["x"]==indexX&&bgTiles[i]["y"]==indexY:
			bgTiles.remove(i)
			break

#选择方块
func selectItem(type,itemName,layer):
	selectItemType=type
	selectItem=itemName
	selectItemLayer=layer

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
			if i.has('layer'): #层不一样就继续查找
				if int(i['layer'])!=int(selectItemLayer):
					continue
			_itemAttr.clearAttr()
			for y in i.keys():  #根据
				if constants.tilesAttributeType.has(y) && \
				 constants.tilesAttributeType[y]=='int':
					_itemAttr.addAttrInt(y,i[y])
				else:
					_itemAttr.addAttr(y,i[y])
			#保存选中数据
			selectedItem["x"]=indexX	
			selectedItem["y"]=indexY
			break


func sort(a,b):
	if a['x']>b['x']:
		return true
	else:
		return false

func text_changed(str1):
	print(str1)
	mapWidthSize=int(str1)
	
func _update(delta):
#	if mode=='edit':
#		pass
#	elif mode=='game':
#			pass	
#	elif mode=='show':
#		pass
	pass


func _process(delta):
	if debug && mode=="edit": 
		update()
	_fps.set_text(str("fps:",Engine.get_frames_per_second()))	
#	_update(delta)
	pass

func _input(event):
	if mode=='edit':
		if _saveDialog.visible||_loadDiaglog.visible:
			return
		if event is InputEventKey:
			if event.is_pressed():
				if (event as InputEventKey).scancode==KEY_LEFT:	
					if camera.position.x>-minWidthNum/2*blockSize:  #前后一半屏幕
						camera.position.x-=20
					pass
				elif (event as InputEventKey).scancode==KEY_RIGHT:	
					if camera.position.x<mapWidthSize*blockSize-minWidthNum/2*blockSize:
						camera.position.x+=20
					pass	
		elif event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and  event.pressed:
				if _tab.is_visible_in_tree()&& _tab.get_rect().has_point(camera.get_local_mouse_position()):
					return
				if _toolBtn.is_visible_in_tree()&&_toolBtn.get_rect().has_point(camera.get_local_mouse_position()):
					return
				isPress=true
				if checkHasItem(get_global_mouse_position(),selectItemType):
					if selectItemType=='del':
						delItem(get_global_mouse_position())
					else:  #显示属性
						getItemAttr(get_global_mouse_position())
						pass
					pass
				else:	
					var pos=getItemPos(get_global_mouse_position())	
					addItem(selectItemType,selectItem,pos)
				pass
			elif !event.pressed:	
				isPress=false
				pass	
			pass
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
					

func _draw():
	if mode=="edit":
		for i in range(mapWidthSize+1):
			if i%20==0:
				draw_line(Vector2(i*blockSize,0),Vector2(i*blockSize,blockSize*heightNun)
			,Color.red,1.2,true)
			else:
				draw_line(Vector2(i*blockSize,0),Vector2(i*blockSize,blockSize*heightNun)
			,Color.gray,0.5,true)
		for i in range(mapWidthSize):
			draw_line(Vector2(0,i*blockSize),Vector2(blockSize*mapWidthSize,i*blockSize),
			Color.gray,0.5,true)	
		for i in bgTiles+allTiles:
			if i.type=='goomba'||i.type=='axe':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))
				pass
			elif i.type=='koopa':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize-12),Color(1,1,1,0.7))
			elif i.type=='bowser':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))
			elif i.type=='box':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))	
				if i.content!=constants.empty&&i.content!='':
#					print(i.content)
					if constants.mapTiles.has(i.content):
						draw_texture(constants.mapTiles[i.content]['0'],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
					elif i.content.begins_with('coins'):
						draw_texture(constants.mapTiles['coin']['0'],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))	
			elif i.type=='brick'||i.type=='bridge'||i.type==constants.cannon:	
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))	
			elif i.type=='coin':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type]['0'],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))	
			elif i.type=='pipe':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
#					if i.has('rotate'):
#						draw_set_transform(Vector2.ZERO,PI / 2.0,Vector2(1, 1))

					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))	
					if i.has('pipeType') && (i.pipeType==constants.pipeIn||i.pipeType==constants.pipeOut):
						if i.pipeType==constants.pipeIn:
							draw_texture(constants.mapTiles['pipeIn']["0"],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.4))
						elif i.pipeType==constants.pipeOut:
							draw_texture(constants.mapTiles['pipeOut']["0"],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.4))
						if i.has('pipeNo')&&str(i.pipeNo)!='':
							draw_string(font,Vector2(i.x*blockSize,i.y*blockSize+blockSize),str(i.pipeNo),Color(1,1,1,0.9))

			elif i.type=='bg':
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))
			elif i.type=='flag': #旗杆
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))
					for l in range(i.len):
						draw_texture(constants.mapTiles['stick'][str(i.spriteIndex)],
						Vector2(i.x*blockSize,i.y*blockSize+(l+1)*blockSize),Color(1,1,1,0.5))
			elif i.type=="collision"||i.type=="castleFlag" :
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))	
			elif i.type==constants.platform||i.type==constants.staticPlatform:
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
#					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.5))
					for l in range(i.lens):
						if i.x*blockSize==i.x*blockSize+(-blockSize*int(i.lens)/2)+l*blockSize+blockSize/2:
							draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],
							Vector2(i.x*blockSize+(-blockSize*int(i.lens)/2)+l*blockSize+blockSize/2,i.y*blockSize),Color(1,1,1,0.7))
						else:
							draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],
							Vector2(i.x*blockSize+(-blockSize*int(i.lens)/2)+l*blockSize+blockSize/2,i.y*blockSize),Color(1,1,1,0.4))
								
			elif i.type==constants.plant:
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))
			elif i.type==constants.spinFireball:
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize+blockSize/4,
								i.y*blockSize+blockSize/4),Color(1,1,1,0.7))	
			elif i.type==constants.figures:
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize-16),Color(1,1,1,0.7))					
			elif i.type==constants.jumpingBoard:
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))					
			elif i.type==constants.cheapcheap||i.type==constants.bloober||i.type==constants.podoboo:
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))	
			elif i.type==constants.lakitu:
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))	
			elif i.type==constants.hammerBro:
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize-36),Color(1,1,1,0.7))	
			elif i.type==constants.linkPlatform:
				if constants.mapTiles.has(i.type)&&constants.mapTiles[i.type].has(str(i.spriteIndex)):
					draw_texture(constants.mapTiles[i.type][str(i.spriteIndex)],Vector2(i.x*blockSize,i.y*blockSize),Color(1,1,1,0.7))	
		if !marioPos.empty():
			draw_texture(constants.mapTiles['mario']['0'],Vector2(marioPos.x*blockSize,marioPos.y*blockSize),Color(1,1,1,0.7))


func _on_hide_pressed():
	_toolBtn.show()
	_tab.hide()
	pass # Replace with function body.


func _on_save_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()
	_saveDialog.current_dir=baseDir
#	_saveDialog.current_file="1-1.json"
	_saveDialog.popup_centered()
	pass # Replace with function body.


func _on_toolBtn_pressed():
	_toolBtn.hide()
	_tab.show()
	pass # Replace with function body.


func _on_Button_pressed():
#	for i in _marioList.get_children():
#		i.startDeathJump()
	var baseDir=OS.get_executable_path().get_base_dir()
#	print(baseDir)
	_loadDiaglog.current_dir=baseDir
	_loadDiaglog.popup_centered()	
	pass # Replace with function body.


func _on_FileDialog_confirmed():
	if _saveDialog.current_path:
		save2File(_saveDialog.current_path)
	else:
		print("没有当前文件")


#保存地图信息
func _on_apply_pressed():
	pass # Replace with function body.


func _on_loadDialog_confirmed():
	var dir=_loadDiaglog.current_dir
	var file=_loadDiaglog.current_file
#	print(dir,' ',file)
#	print(_loadDiaglog.current_path)
	if file:
		loadMapFile(dir+"/"+file)
	pass # Replace with function body.

#编辑属性
func _on_edit_pressed():
	for i in allTiles:
		if i["x"]==selectedItem["x"]&&i["y"]==selectedItem["y"]:
			for z in _itemAttr.list.get_children():
				if z.key in constants.tilesAttributeType.keys(): #需要设置整形的属性
					i[z.key]=int(z.getValue())
					if z.key =='x':
						selectedItem["x"]=int(z.getValue())
					if z.key =='y':
						selectedItem["y"]=int(z.getValue())
				else:
					i[z.key]=z.getValue()
			break



func _on_loadDialog_file_selected(_path):
#	print(path)
	if _path:
		loadMapFile(_path)
	pass # Replace with function body.


func _on_return_pressed():
	set_process_input(false)
	var scene=load("res://scenes/welcome.tscn")
	var temp=scene.instance()
	queue_free()
	get_tree().get_root().add_child(temp)
	set_process_input(true)
	pass # Replace with function body.


func _on_FileDialog_file_selected(path):
	if path:
		save2File(path)
	else:
		print("没有当前文件")
	pass # Replace with function body.
