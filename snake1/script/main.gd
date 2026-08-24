extends Node2D
# 贪食蛇 - Godot 4
# 操作: 方向键 / WASD 移动, R 重新开始

const CELL := 20 # 每格像素
const COLS := 24 # 列数
const ROWS := 24 # 行数
const TICK := 0.12 # 移动间隔(秒)

var snake: Array[Vector2i] = []
var dir: Vector2i = Vector2i.RIGHT
var pending_dir: Vector2i = Vector2i.RIGHT
var food: Vector2i = Vector2i.ZERO
var score := 0
var game_over := false
var prev_snake: Array[Vector2i] = [] # 上一 tick 的蛇身快照, 用于插值

var timer: Timer
var score_label: Label
var message_label: Label


func _ready() -> void:
	# 计时器驱动蛇的移动
	timer = Timer.new()
	timer.wait_time = TICK
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	# 分数
	score_label = Label.new()
	score_label.position = Vector2(8, 2)
	score_label.add_theme_font_size_override("font_size", 18)
	add_child(score_label)
	# 游戏结束提示(居中)
	message_label = Label.new()
	message_label.position = Vector2(0, ROWS * CELL / 2 - 16)
	message_label.size = Vector2(COLS * CELL, 32)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 22)
	add_child(message_label)
	_start()


func _process(_delta: float) -> void:
	# 每帧重绘, 让插值动画连续
	queue_redraw()


func _start() -> void:
	snake.clear()
	for i in 3:
		snake.append(Vector2i(3 - i, 12)) # 蛇头在(3,12), 向右
	dir = Vector2i.RIGHT
	pending_dir = Vector2i.RIGHT
	score = 0
	game_over = false
	prev_snake = snake.duplicate()
	_spawn_food()
	timer.start()
	_update_ui()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var k = event.physical_keycode
	var nd: Vector2i = dir
	match k:
		Key.KEY_UP, Key.KEY_W: nd = Vector2i.UP
		Key.KEY_DOWN, Key.KEY_S: nd = Vector2i.DOWN
		Key.KEY_LEFT, Key.KEY_A: nd = Vector2i.LEFT
		Key.KEY_RIGHT, Key.KEY_D: nd = Vector2i.RIGHT
		Key.KEY_R: _start(); return
		_: return
	# 禁止 180 度反向
	if nd != -dir:
		pending_dir = nd


func _on_timer_timeout() -> void:
	if game_over:
		return
	dir = pending_dir
	prev_snake = snake.duplicate() # 移动前快照
	var head: Vector2i = snake[0] + dir
	# 撞墙或撞自身
	if head.x < 0 or head.x >= COLS or head.y < 0 or head.y >= ROWS or snake.has(head):
		_game_over()
		return
	snake.insert(0, head)
	if head == food:
		score += 10
		_spawn_food()
	else:
		snake.pop_back()
	_update_ui()
	queue_redraw()


func _spawn_food() -> void:
	var free_cells: Array[Vector2i] = []
	for x in COLS:
		for y in ROWS:
			var c := Vector2i(x, y)
			if not snake.has(c):
				free_cells.append(c)
	if free_cells.is_empty():
		_game_over()
		return
	food = free_cells[randi() % free_cells.size()]


func _game_over() -> void:
	game_over = true
	timer.stop()
	_update_ui()
	queue_redraw()


func _update_ui() -> void:
	score_label.text = "Score: %d" % score
	message_label.text = "Game Over - Press R to Restart" if game_over else ""


func _draw() -> void:
	# 背景
	draw_rect(Rect2(0, 0, COLS * CELL, ROWS * CELL), Color(0.1, 0.1, 0.12), true)
	# 食物
	_draw_cell(Vector2(food), Color(0.95, 0.25, 0.25))
	# 插值因子 t: 0(刚到达上一格) -> 1(即将到达下一格)
	var t := 1.0
	if not game_over and not prev_snake.is_empty():
		t = clamp(1.0 - timer.time_left / TICK, 0.0, 1.0)
	# 吃到食物本 tick 蛇身长度 +1, 身体保持静止只让蛇头滑出
	var grew := snake.size() > prev_snake.size()
	for k in snake.size():
		var new_pos := Vector2(snake[k])
		var old_pos := new_pos
		if k < prev_snake.size():
			var old_idx = k if not grew else max(0, k - 1)
			old_pos = Vector2(prev_snake[old_idx])
		var vp := old_pos.lerp(new_pos, t)
		var col := Color(0.4, 1.0, 0.4) if k == 0 else Color(0.2, 0.75, 0.3)
		_draw_cell(vp, col)


func _draw_cell(cell: Vector2, color: Color) -> void:
	var rect := Rect2(cell.x * CELL + 1, cell.y * CELL + 1, CELL - 2, CELL - 2)
	draw_rect(rect, color, true)
