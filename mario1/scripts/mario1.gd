extends "res://scripts/object.gd"


var maxXVel=constants.marioWalkMaxSpeed
var maxYVel=0
var big = false #是否变大
var faceRight=true
var fire = false #是否能发射子弹
var status=constants.stand
var acceleration =constants.acceleration #加速度
var isOnFloor=false #是否在地面上

var stand_small_animation=['stand_small','stand_small_green',
						'stand_small_red','stand_small_black']
var slide_small_animation=['slide_small','slide_small_green',
						'slide_small_red','slide_small_black']
var walk_small_animation=['walk_small','walk_small_green',
						'walk_small_red','walk_small_black']
var jump_small_animation=['jump_small','jump_small_green',
						'jump_small_red','jump_small_black']
var stand_big_animation=['stand_big','stand_big_green',
						'stand_big_red','stand_big_black']
var walk_big_animation=['walk_big','walk_big_green',
						'walk_big_red','walk_big_black']
var slide_big_animation=['slide_big','slide_big_green',
						'slide_big_red','slide_big_black']
var jump_big_animation=['jump_big','jump_big_green',
						'jump_big_red','jump_big_black']	
							
var aniIndex=0						
onready var ani=$ani

func _ready():
	debug=true
	self.rect=Rect2(Vector2(-13,-16),Vector2(26,32))	
	gravity=constants.marioGravity
	pass 


func _update(delta):
	if status==constants.stand:
		stand(delta)
	elif status==constants.walk:
		walk(delta)
	elif status==constants.fall:
		fall(delta)
	elif status==constants.jump:
		jump(delta)	
	elif status==constants.small2big:
		pass
	pass
	

func stand(delta):
	self.xVel=0
	self.yVel+=gravity*delta
	animation("stand")
	if Input.is_action_pressed("ui_left"):
		faceRight=false
		status = constants.walk
	elif Input.is_action_pressed("ui_right"):
		faceRight=true
		status = constants.walk
	elif Input.is_action_pressed("ui_jump"):	
		print('stand','ui_jump')
		yVel=-constants.marioJumpSpeed
		gravity=constants.marioJumpGravity
		status=constants.jump
	position.y+=yVel*delta	
	if !isOnFloor:
		status=constants.fall
	pass

func walk(delta):
	yVel+=gravity*delta
	if xVel>0:
		ani.speed_scale=1+xVel/constants.marioAniSpeed
	elif xVel<0:
		ani.speed_scale=1+xVel/constants.marioAniSpeed*-1
	
	if Input.is_action_pressed("ui_action"):
		acceleration=constants.runAcceleration
		maxXVel=constants.marioRunMaxSpeed
	else:
		acceleration=constants.acceleration
		maxXVel=constants.marioWalkMaxSpeed	
	
	#跳跃
	if Input.is_action_pressed("ui_jump"):
		yVel=-constants.marioJumpSpeed
		gravity=constants.marioJumpGravity
		status=constants.jump
		print('walk jump')
		return
	
	if Input.is_action_pressed("ui_left"):
		if xVel>0: #反方向
			animation("slide")
			acceleration=constants.slideFriction
		else:
			acceleration=constants.acceleration
			faceRight=false
			animation('walk')
			
		if xVel>-maxXVel:
			xVel-=acceleration
		elif xVel<-maxXVel:
			xVel+=acceleration
	elif Input.is_action_pressed("ui_right"):
		faceRight=true
		if xVel<0:
			animation("slide")
			acceleration=constants.slideFriction
		else:
			faceRight=true
			acceleration=constants.acceleration
			animation('walk')
			
		if xVel<maxXVel:
			xVel+=acceleration
		elif xVel>maxXVel:
			xVel-=acceleration
	else:
		if faceRight:
			if	self.xVel>0:
				self.xVel-=acceleration
				animation("walk")
			else:
				self.xVel=0
				ani.speed_scale=1
				status=constants.stand	
		else:
			if self.xVel<0:
				self.xVel+=acceleration
				animation("walk")
			else:
				self.xVel=0
				ani.speed_scale=1
				status=constants.stand	
					
	position.x+=xVel*delta
	position.y+=yVel*delta	
	pass

func jump(delta):
	yVel+=gravity*delta
	animation("jump")
#	print(yVel)
	if yVel>0:
		gravity=constants.marioGravity
		status=constants.fall	
		print('jump')
		return
		
	if Input.is_action_just_released("ui_jump"):#如果跳跃键放开重力修改
		print(2121)
		gravity=constants.marioGravity
	
	if Input.is_action_pressed("ui_left"):
		if xVel>-maxXVel:
			xVel-=acceleration
	elif Input.is_action_pressed("ui_right"):
		if xVel<maxXVel:
			xVel+acceleration
	position.x+=self.xVel*delta
	position.y+=self.yVel*delta	
	pass

func fall(delta):
	yVel+=gravity*delta
#	animation("jump")
	if Input.is_action_pressed("ui_left"):
		if xVel<-maxXVel:
			xVel-=acceleration
	elif Input.is_action_pressed("ui_right"):
		if xVel>maxXVel:
			xVel-=acceleration	
	position.x+=xVel*delta
	position.y+=yVel*delta	
	
	if isOnFloor:
		status = constants.walk
		print('fall end')			
	pass

func small2Big():
	status=constants.small2big
	ani.play("small2big")
	pass

func animation(type):
	if type=='stand':
		if big:
			ani.play(stand_big_animation[aniIndex])
		else:	
			ani.play(stand_small_animation[aniIndex])
	elif type=='slide':
		if big:
			ani.play(slide_big_animation[aniIndex])
		else:	
			ani.play(slide_small_animation[aniIndex])
	elif type=='walk':
		if big:
			ani.play(walk_big_animation[aniIndex])
		else:	
			ani.play(walk_small_animation[aniIndex])
	elif type=='jump':
		if big:
			ani.play(jump_small_animation[aniIndex])
		else:	
			ani.play(jump_small_animation[aniIndex])
	if faceRight && ani.flip_h:
		ani.flip_h=false
	elif !faceRight && !ani.flip_h:
		ani.flip_h=true	
	pass


func _on_ani_frame_changed():
	if status==constants.small2big:
		print(ani.frame)
		if ani.frame in [0,2,4]:
			ani.position.y= 0
		else:
			ani.position.y=-20
		
#		if ani.frame==11:
#			big=true
#			status=constants.walk
	pass # Replace with function body.


func _on_ani_animation_finished():
	if status==constants.small2big:
			big=true
			status=constants.walk
	pass # Replace with function body.
