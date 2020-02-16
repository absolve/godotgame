extends Node2D
#字体图片的高度是8px宽度是512

var font_img=preload("res://fonts/font.png")

var startpos=8  #起始位置
export var text=""  #显示的文本
var fontlist=['+',',','-','.','/','0','1','2','3','4','5','6','7','8','9',
':',';','<',"=",'>','?','（C）','a','b',
'c','d','e','f','g','h','i','j','k','l','m','n','o','p','q',
'r','s','t','u','v','w',
'x','y','z']

func _ready():
	var a = Sprite.new()
	a.texture = font_img
	a.centered=false
	a.position= Vector2(0,200)
	add_child(a)
	if text:
		print(text)
		var xpos=0
		for i in text:
			print(i)
			if i in fontlist:
				var index=fontlist.find(i)
				print("pos ",index)
				var font = Sprite.new()
				font.texture = font_img
				font.centered=false
				font.position= Vector2(xpos,0)
				font.region_enabled=true
				font.region_rect=Rect2(startpos+index*8,0,8,8)
				add_child(font)
				xpos+=8
#		var font = Sprite.new()
#		font.texture = font_img
#		font.centered=false
#		font.position= Vector2(0,200)
#		xpos+=8
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
