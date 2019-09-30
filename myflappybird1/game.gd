extends Node

#游戏中的全局变量

const GROUP_PIPES   = "pipes"
const GROUP_GROUNDS = "grounds"
const GROUP_BIRDS   = "birds"

#场景位置
const state_main = "res://stages/main.tscn"
const state_welcome = "res://stages/welcome.tscn"
#数字的图片
const sprite_numbers = [
	preload("res://sprites/number_middle_0.png"),
	preload("res://sprites/number_middle_1.png"),
	preload("res://sprites/number_middle_2.png"),
	preload("res://sprites/number_middle_3.png"),
	preload("res://sprites/number_middle_4.png"),
	preload("res://sprites/number_middle_5.png"),
	preload("res://sprites/number_middle_6.png"),
	preload("res://sprites/number_middle_7.png"),
	preload("res://sprites/number_middle_8.png"),
	preload("res://sprites/number_middle_9.png")
]

#分数变化的信号
signal score_current_changed
#产生新的分数信号
signal new_score

#分数
var score_current = 0
var best_score=0

func _ready():
	pass

#增加分数
func addScore():
	score_current+=1
	audio_player.play("sfx_point")
	emit_signal("score_current_changed")
	
#设置新分数
func setBestScore(score):
	best_score = score


#最后计算得分
func count_to_score(node,number):
	#如果分数是最高的分数
	if number>best_score:
#		print("best_score")
		best_score = number
		emit_signal("new_score")
	
	
	for child in node.get_children():
		child.free()
	
	for digit in get_digits(number):
		var texture_frame = TextureFrame.new()
		texture_frame.set_texture(sprite_numbers[digit])
		node.add_child(texture_frame)
	pass

#获取每个数字
func get_digits(number):
	var str_number = str(number)
	var digits     = []
	
	for i in range(str_number.length()):
		digits.append(str_number[i].to_int())
	#print(digits)
	return digits



#切换场景
func changeState(stage_path):

	get_tree().get_root().set_disable_input(true)
	splash.get_node("anim").play("fade_in")
	#播放声音
	audio_player.play("sfx_swooshing")
	yield(splash.get_node("anim"),"finished")
	
	get_tree().change_scene(stage_path)
	
	splash.get_node("anim").play("fade_out")
	yield(splash.get_node("anim"),"finished")
	
	get_tree().get_root().set_disable_input(false)
	
	#数据清理
	score_current=0	
	pass

#获取根节点下面的孩子
func get_main_node():
	var root_node = get_tree().get_root()
	return root_node.get_child(root_node.get_child_count()-1)
