extends Node2D
#参考资料 https://developer.ibm.com/technologies/javascript/tutorials/wa-build2dphysicsengine/

var state=Game.game_state.START
var level



onready var _tank = $map/tanks
onready var _brick=$map/brick
onready var _bullet=$map/bullets
onready var _bonus=$map/bonus


func _ready():
	Game.connect("baseDestroyed",self,"baseDestroy")
	Game.otherObj=$map/obj
	Game.mainScene=$map/bullets
	$map.loadMap(Game.mapDir+"/"+Game.mapNameList[Game.level])
	$map.addNewPlayer(1)
	
	pass 


func _process(delta):
	if state==Game.game_state.LOAD:
		if Input.is_action_just_pressed("ui_accept"):
			#Splash.playOut()
			#state = Game.game_state.START
			setState(Game.game_state.START)
			pass
		pass
	elif state==Game.game_state.START:
		#return
		for i in _tank.get_children():	#检查坦克与砖块的碰撞
			var rect=i.getRect()
			for y in _brick.get_children():
				if y.get_class()=="brick":
					var rect1=y.getRect()
					if rect.intersects(rect1,false):  #碰撞
						print(11)
						var dx=(y.position.x-i.position.x)/(y.getSize()/2)
						var dy=(y.position.y-i.position.y)/(y.getSize()/2)
						var absDX = abs(dx)
						var absDY = abs(dy)

						if abs(absDX - absDY) < .1:
							if dx<0:
								i.position.x=y.position.x+y.getSize()/2+i.getSize()/2			
							else:
								i.position.x=y.position.x-y.getSize()/2-i.getSize()/2	

							if dy<0:
								i.position.y=y.position.y+y.getSize()/2+i.getSize()/2			
							else:
								i.position.y=y.position.y-y.getSize()/2-i.getSize()/2						
						elif absDX > absDY:
							if dx<0:
								i.position.x=y.position.x+y.getSize()/2+i.getSize()/2					
							else:
								i.position.x=y.position.x-y.getSize()/2-i.getSize()/2		
						else:
							if dy<0:
								i.position.y=y.position.y+y.getSize()/2+i.getSize()/2	
							else:
								i.position.y=y.position.y-y.getSize()/2-i.getSize()/2	
						pass
			pass
		
		for i in _bullet.get_children():	#子弹跟方块
			if i.get_class()=="bullet":
				var rect=i.getRect()
				for y in _brick.get_children():
					if y.get_class()=="brick":
						var rect1=y.getRect()
						if rect.intersects(rect1,false):  #碰撞
							i.addExplode(false)
							y.hit(i.getDir())
				
		for i in _bullet.get_children():	#同一个子弹
			if i.get_class()=="bullet":
				var typeA = i.getType()
				for y in _bullet.get_children():
					if i!=y && y.get_class()=="bullet": #排除同一个
						print(222222222)
						var typeB=y.getType()
						if typeA==Game.bulletType.players and typeB==Game.bulletType.enemy:
							i.destroy()
							y.destroy()
						elif typeA==Game.bulletType.enemy and typeB==Game.bulletType.players:
							i.destroy()
							y.destroy()
					pass
		
				
		for i in _bullet.get_children():
			if i.position.x<0 or i.position.x>Game.winSize.x:
				i.destroy()
			if	i.position.y<0 or i.position.y>Game.winSize.y:
				i.destroy()
			pass
		
		for i in _bonus.get_children():
			var rect=i.getRect()
			for y in _tank.get_children():
				if y.get_class()=="player":
					var rect1=y.getRect()
					if rect.intersects(rect1,false):
						pass
					pass
		
		
		pass
	elif state==Game.game_state.NEXT_LEVEL:
		
		pass
	elif state==Game.game_state.OVER:
		pass
	pass



#设置状态
func setState(state):
	if state==Game.game_state.START:
		print('loadMap')
		
		pass
	elif state==Game.game_state.NEXT_LEVEL:
		
		pass	
	elif state==Game.game_state.OVER:
		
		pass
	self.state=state


#基地毁灭	
func baseDestroy():
	print('baseDestroy')
	setState(Game.game_state.OVER)
	pass
