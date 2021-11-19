extends "res://scripts/object.gd"


var maxXVel=constants.marioWalkMaxSpeed
var maxYVel=0
var big = true #是否变大
#var faceRight=true
var fire = false #是否能发射子弹
var status=constants.stand
var acceleration =constants.acceleration #加速度
var isOnFloor=false #是否在地面上
var dir=constants.right

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
var crouch_animation=['crouch','crouch_green',
						'crouch_red','crouch_black']
var throw_animation=['throw','throw_green',
						'throw_red','throw_black']
							
var aniIndex=0	#动画索引					
onready var ani=$ani

func _ready():
	debug=true
	if big:
		rect=Rect2(Vector2(-15,-32),Vector2(30,64))	
	else:	
		rect=Rect2(Vector2(-13,-16),Vector2(26,32))	
	gravity=constants.marioGravity
	if big && fire:
		aniIndex=2
	animation("stand")
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
	elif status==constants.crouch:
		crouch(delta)
		pass
	update()	
	pass
	

func stand(delta):
	xVel=0
	yVel+=gravity*delta
	animation("stand")
	if Input.is_action_pressed("ui_left"):
#		faceRight=false
		dir=constants.left
		status = constants.walk
	elif Input.is_action_pressed("ui_right"):
#		faceRight=true
		dir=constants.right
		status = constants.walk
	elif Input.is_action_pressed("ui_jump"):	
#		print('stand','ui_jump')
		yVel=-constants.marioJumpSpeed
		gravity=constants.marioJumpGravity
		status=constants.jump
	if Input.is_action_just_pressed("ui_down") &&big:
		startCrouch()
		return
		
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
	
	if Input.is_action_just_pressed("ui_down") &&big:
		startCrouch()
		return
	
	if Input.is_action_pressed("ui_left"):
		if xVel>0: #反方向
			animation("slide")
			acceleration=constants.slideFriction
		else:
			acceleration=constants.acceleration
#			faceRight=false
			dir=constants.left
			animation('walk')
			
		if xVel>-maxXVel:
			xVel-=acceleration
		elif xVel<-maxXVel:
			xVel+=acceleration
	elif Input.is_action_pressed("ui_right"):
#		faceRight=true
		if xVel<0:
			animation("slide")
			acceleration=constants.slideFriction
		else:
#			faceRight=true
			dir=constants.right
			acceleration=constants.acceleration
			animation('walk')
			
		if xVel<maxXVel:
			xVel+=acceleration
		elif xVel>maxXVel:
			xVel-=acceleration
	else:
		if dir==constants.right:
			if	xVel>0:
				xVel-=acceleration
				animation("walk")
			else:
				xVel=0
				ani.speed_scale=1
				status=constants.stand	
		else:
			if xVel<0:
				xVel+=acceleration
				animation("walk")
			else:
				xVel=0
				ani.speed_scale=1
				status=constants.stand	
					
	position.x+=xVel*delta
	position.y+=yVel*delta	
	if !isOnFloor:
		ani.stop()
		status=constants.fall
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
		
	position.x+=xVel*delta
	position.y+=yVel*delta	
	pass

func fall(delta):
	yVel+=gravity*delta
#	animation("jump")
	if Input.is_action_pressed("ui_left"):
		if xVel>-maxXVel:
			xVel-=acceleration
	elif Input.is_action_pressed("ui_right"):
		if xVel<maxXVel:
			xVel+=acceleration	
			
	position.x+=xVel*delta
	position.y+=yVel*delta	
	
	if isOnFloor:
		status = constants.walk
		print('fall end')			
	pass

func startCrouch():
	status=constants.crouch	
	rect=Rect2(Vector2(-15,-16),Vector2(30,32))	
	position.y+=15  #不能到边界
#	position.y+=16
#	rect.size.y-=32
	ani.position.y-=20
	
func crouch(delta):
	yVel+=gravity*delta
	animation("crouch")
	if Input.is_action_just_released("ui_down"):
		status=constants.walk	
		rect=Rect2(Vector2(-15,-32),Vector2(30,64))	
		position.y-=15
#		rect.size.y+=32
		ani.position.y=0
		pass
	elif Input.is_action_pressed("ui_jump"):
		yVel=-constants.marioJumpSpeed
		gravity=constants.marioJumpGravity
		status=constants.jump
		pass
		
	if dir==constants.right:
		if	xVel>0:
			xVel-=acceleration
		else:
			xVel=0
			ani.speed_scale=1
	else:
		if xVel<0:
			xVel+=acceleration
		else:
			xVel=0
			ani.speed_scale=1		
	position.x+=xVel*delta
	position.y+=yVel*delta
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
			ani.play(jump_big_animation[aniIndex])
		else:	
			ani.play(jump_small_animation[aniIndex])
	elif type=='crouch':
		if big:
			ani.play(crouch_animation[aniIndex])		
	if dir==constants.right && ani.flip_h:
		ani.flip_h=false
	elif dir==constants.left && !ani.flip_h:
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
