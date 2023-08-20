extends Node2D

var dir="screenshot"
var thread:Thread=null

func _ready():
	var temp = Directory.new()
	if !temp.dir_exists(OS.get_executable_path().get_base_dir()+"/"+dir):
		temp.make_dir(OS.get_executable_path().get_base_dir()+"/"+dir)
	
	
#截图
func capture():
	print('capture')
	SoundsUtil.playCoin()
#	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
#	yield(VisualServer, "frame_post_draw")
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	var name="screenshot_{0}.png".format([int(Time.get_unix_time_from_system())])
	img.save_png(OS.get_executable_path().get_base_dir()+"/"+dir+"/"+name)
#	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ALWAYS)

#开始捕获
func startCapture():
	if thread!=null&&thread.is_alive():
		return
	if	thread!=null&&thread.is_active():
		thread.wait_to_finish()
	thread=	Thread.new()
	thread.start(self, "capture")

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if (event as InputEventKey).scancode==KEY_F1:	
				startCapture()
				
				
func _exit_tree():
	if thread!=null&&thread.is_alive():
		thread.wait_to_finish()
