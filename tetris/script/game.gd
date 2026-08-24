extends Control
# 俄罗斯方块 - Godot 4
# 操作: ← → / A D 移动, ↑ / W 旋转, ↓ / S 软降, 空格 硬降
#       R 重新开始, ESC 返回主菜单

const COLS := 10
const ROWS := 20
const CELL := 30
const BOARD_X := 20
const BOARD_Y := 100
const PREVIEW_X := 340
const PREVIEW_Y := 130
const PREVIEW_CELL := 18
const CLEAR_ANIM_DURATION := 0.4  # 消行动画时长 (秒)

# 7 种方块 (4x4 矩阵 + 颜色): I O T S Z J L
const PIECES: Array = [
	{ "matrix": [[0,0,0,0],[1,1,1,1],[0,0,0,0],[0,0,0,0]], "color": Color(0.0, 1.0, 1.0) },     # I
	{ "matrix": [[0,1,1,0],[0,1,1,0],[0,0,0,0],[0,0,0,0]], "color": Color(1.0, 1.0, 0.0) },     # O
	{ "matrix": [[0,1,0,0],[1,1,1,0],[0,0,0,0],[0,0,0,0]], "color": Color(0.6, 0.0, 1.0) },     # T
	{ "matrix": [[0,1,1,0],[1,1,0,0],[0,0,0,0],[0,0,0,0]], "color": Color(0.0, 1.0, 0.0) },     # S
	{ "matrix": [[1,1,0,0],[0,1,1,0],[0,0,0,0],[0,0,0,0]], "color": Color(1.0, 0.0, 0.0) },     # Z
	{ "matrix": [[1,0,0,0],[1,1,1,0],[0,0,0,0],[0,0,0,0]], "color": Color(0.0, 0.0, 1.0) },     # J
	{ "matrix": [[0,0,1,0],[1,1,1,0],[0,0,0,0],[0,0,0,0]], "color": Color(1.0, 0.5, 0.0) },    # L
]

var grid: Array = []           # ROWS x COLS, 0=空, 1..7=颜色索引
var current_matrix: Array = [] # 4x4 of 0/1
var current_color: int = 0     # 1..7
var current_x: int = 0
var current_y: int = 0
var next_piece: int = 0

var score := 0
var lines := 0
var level := 1
var game_over := false
var fall_timer := 0.0
var fall_interval := 0.8

# 消行动画状态
var clearing := false
var clearing_rows: Array = []   # 待消除的行号
var clear_anim_time := 0.0
var clear_direction := 1        # 1=从左往右, -1=从右往左

# 暂停状态
var paused := false
var pause_btn: Button

var score_label: Label
var level_label: Label
var lines_label: Label
var message_label: Label


func _ready() -> void:
	randomize()
	_build_ui()
	_start()


func _build_ui() -> void:
	# 顶部工具栏
	var top_bar := HBoxContainer.new()
	top_bar.set_anchors_preset(PRESET_TOP_WIDE)
	top_bar.offset_left = 20
	top_bar.offset_top = 20
	top_bar.offset_right = -20
	top_bar.offset_bottom = 80
	add_child(top_bar)

	var back_btn := Button.new()
	back_btn.text = "← 主菜单"
	back_btn.pressed.connect(_on_back)
	top_bar.add_child(back_btn)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	score_label = Label.new()
	score_label.text = "得分: 0"
	score_label.add_theme_font_size_override("font_size", 22)
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_bar.add_child(score_label)

	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer2)

	pause_btn = Button.new()
	pause_btn.text = "暂停 (P)"
	pause_btn.pressed.connect(_toggle_pause)
	top_bar.add_child(pause_btn)

	var restart_btn := Button.new()
	restart_btn.text = "重新开始 (R)"
	restart_btn.pressed.connect(_start)
	top_bar.add_child(restart_btn)

	# 右侧信息面板
	var next_label := Label.new()
	next_label.text = "下一个"
	next_label.position = Vector2(PREVIEW_X, BOARD_Y)
	next_label.add_theme_font_size_override("font_size", 16)
	add_child(next_label)

	level_label = Label.new()
	level_label.text = "等级: 1"
	level_label.position = Vector2(PREVIEW_X, BOARD_Y + 130)
	level_label.add_theme_font_size_override("font_size", 16)
	add_child(level_label)

	lines_label = Label.new()
	lines_label.text = "消除: 0"
	lines_label.position = Vector2(PREVIEW_X, BOARD_Y + 160)
	lines_label.add_theme_font_size_override("font_size", 16)
	add_child(lines_label)

	var hint := Label.new()
	hint.text = "← →: 移动\n↑: 旋转\n↓: 软降\n空格: 硬降\nP: 暂停/继续"
	hint.position = Vector2(PREVIEW_X, BOARD_Y + 200)
	hint.add_theme_font_size_override("font_size", 14)
	add_child(hint)

	# 底部消息
	message_label = Label.new()
	message_label.set_anchors_preset(PRESET_BOTTOM_WIDE)
	message_label.offset_left = 20
	message_label.offset_top = -40
	message_label.offset_right = -20
	message_label.offset_bottom = -10
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 20)
	add_child(message_label)


func _start() -> void:
	grid = []
	for y in ROWS:
		var row: Array = []
		for x in COLS:
			row.append(0)
		grid.append(row)
	score = 0
	lines = 0
	level = 1
	fall_interval = 0.8
	game_over = false
	clearing = false
	clearing_rows = []
	clear_anim_time = 0.0
	paused = false
	if pause_btn:
		pause_btn.text = "暂停 (P)"
	next_piece = randi() % 7
	message_label.text = ""
	_spawn_piece()
	fall_timer = fall_interval
	_render()


# 生成新方块, 若不能放置则游戏结束
func _spawn_piece() -> void:
	var piece_type := next_piece
	next_piece = randi() % 7
	current_matrix = PIECES[piece_type].matrix.duplicate(true)
	current_color = piece_type + 1
	current_x = 3   # 4x4 矩阵在 10 列棋盘中居中: (10-4)/2 = 3
	current_y = 0
	if not _is_valid_position(current_matrix, current_x, current_y):
		game_over = true
		message_label.text = "游戏结束! 按 R 重新开始"


# 检查矩阵在 (x, y) 处能否放置 (不越界、不冲突)
func _is_valid_position(matrix: Array, x: int, y: int) -> bool:
	for i in 4:
		for j in 4:
			if matrix[i][j]:
				var gx: int = x + j
				var gy: int = y + i
				if gx < 0 or gx >= COLS or gy >= ROWS:
					return false
				if gy >= 0 and grid[gy][gx] != 0:
					return false
	return true


# 顺时针旋转 4x4 矩阵
func _rotate_cw(matrix: Array) -> Array:
	var rotated: Array = []
	for i in 4:
		var row: Array = []
		for j in 4:
			row.append(matrix[3 - j][i])
		rotated.append(row)
	return rotated


func _try_rotate() -> void:
	if game_over or current_color == 2:  # O 方块不旋转
		return
	var rotated := _rotate_cw(current_matrix)
	# 墙踢: 尝试在原位及左右偏移放置
	for offset in [0, -1, 1, -2, 2]:
		if _is_valid_position(rotated, current_x + offset, current_y):
			current_matrix = rotated
			current_x += offset
			_render()
			return


func _try_move(dx: int) -> void:
	if game_over:
		return
	if _is_valid_position(current_matrix, current_x + dx, current_y):
		current_x += dx
		_render()


# 下落一格, 不能下落则锁定
func _fall_one_step() -> void:
	if game_over:
		return
	if _is_valid_position(current_matrix, current_x, current_y + 1):
		current_y += 1
		fall_timer = fall_interval
		_render()
	else:
		_lock_piece()


# 把当前方块固定到网格, 检测满行启动消行动画 (或直接生成下一个)
func _lock_piece() -> void:
	for i in 4:
		for j in 4:
			if current_matrix[i][j]:
				var gx: int = current_x + j
				var gy: int = current_y + i
				if gy >= 0 and gy < ROWS and gx >= 0 and gx < COLS:
					grid[gy][gx] = current_color

	# 找出所有满行 (但不立刻消除)
	clearing_rows = []
	for y in ROWS:
		var full := true
		for x in COLS:
			if grid[y][x] == 0:
				full = false
				break
		if full:
			clearing_rows.append(y)

	if clearing_rows.is_empty():
		# 没有可消的行, 直接生成下一个方块
		_spawn_piece()
		fall_timer = fall_interval
		_render()
	else:
		# 启动消行动画, 随机方向
		clearing = true
		clear_anim_time = 0.0
		clear_direction = 1 if randf() < 0.5 else -1
		_render()


# 消行动画结束: 真正移除满行, 加分, 升级, 生成下一个
func _end_clear_animation() -> void:
	# 从下往上移除 (这样上方行的索引不会被破坏)
	clearing_rows.sort()
	clearing_rows.reverse()
	for y in clearing_rows:
		grid.remove_at(y)
		var new_row: Array = []
		for x in COLS:
			new_row.append(0)
		grid.insert(0, new_row)

	var cleared := clearing_rows.size()
	var score_table: Array = [0, 100, 300, 500, 800]
	score += score_table[cleared] * level
	lines += cleared
	var new_level: int = lines / 10 + 1
	if new_level > level:
		level = new_level
		fall_interval = maxf(0.05, 0.8 - (level - 1) * 0.07)

	clearing = false
	clearing_rows = []

	_spawn_piece()
	fall_timer = fall_interval
	_render()


# 硬降: 一直下落到底
func _hard_drop() -> void:
	if game_over:
		return
	while _is_valid_position(current_matrix, current_x, current_y + 1):
		current_y += 1
		score += 2  # 硬降奖励
	_lock_piece()


func _process(delta: float) -> void:
	if game_over:
		return
	if clearing:
		# 消行动画进行中, 不下落, 只推进动画
		clear_anim_time += delta
		if clear_anim_time >= CLEAR_ANIM_DURATION:
			_end_clear_animation()
		queue_redraw()
		return
	if paused:
		return  # 暂停时不下落
	fall_timer -= delta
	# 软降 (按住 ↓/S 时 10 倍速)
	if Input.is_physical_key_pressed(KEY_DOWN) or Input.is_physical_key_pressed(KEY_S):
		fall_timer -= delta * 9
	if fall_timer <= 0:
		_fall_one_step()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if clearing:
		# 消行动画期间只允许 R / ESC
		match event.physical_keycode:
			Key.KEY_R: _start()
			Key.KEY_ESCAPE: _on_back()
		return
	# P 键: 暂停/继续 (游戏未结束时可用)
	if event.physical_keycode == Key.KEY_P and not game_over:
		_toggle_pause()
		return
	if paused:
		# 暂停期间只允许 R / ESC (P 已处理)
		match event.physical_keycode:
			Key.KEY_R: _start()
			Key.KEY_ESCAPE: _on_back()
		return
	match event.physical_keycode:
		Key.KEY_LEFT, Key.KEY_A: _try_move(-1)
		Key.KEY_RIGHT, Key.KEY_D: _try_move(1)
		Key.KEY_UP, Key.KEY_W: _try_rotate()
		Key.KEY_DOWN, Key.KEY_S: _fall_one_step()
		Key.KEY_SPACE: _hard_drop()
		Key.KEY_R: _start()
		Key.KEY_ESCAPE: _on_back()


# 切换暂停状态
func _toggle_pause() -> void:
	paused = not paused
	pause_btn.text = "继续 (P)" if paused else "暂停 (P)"
	queue_redraw()


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scene/welcome.tscn")


func _render() -> void:
	score_label.text = "得分: %d" % score
	level_label.text = "等级: %d" % level
	lines_label.text = "消除: %d" % lines
	queue_redraw()


func _draw() -> void:
	_draw_board()
	_draw_preview()
	if paused:
		_draw_pause_overlay()


func _draw_board() -> void:
	var board_size := Vector2(COLS * CELL, ROWS * CELL)
	var board_pos := Vector2(BOARD_X, BOARD_Y)

	# 棋盘外框
	draw_rect(Rect2(board_pos - Vector2(2, 2), board_size + Vector2(4, 4)),
			Color(0.05, 0.05, 0.08), true)

	# 网格背景: 交替明暗棋盘格
	var bg_a := Color(0.10, 0.10, 0.14)
	var bg_b := Color(0.14, 0.14, 0.18)
	for y in ROWS:
		for x in COLS:
			var cell_pos := Vector2(board_pos.x + x * CELL, board_pos.y + y * CELL)
			draw_rect(Rect2(cell_pos, Vector2(CELL, CELL)),
					bg_a if (x + y) % 2 == 0 else bg_b, true)

	# 网格线 (细)
	for x in COLS + 1:
		var xp: float = board_pos.x + x * CELL
		draw_line(Vector2(xp, board_pos.y), Vector2(xp, board_pos.y + board_size.y),
				Color(0.2, 0.2, 0.25), 1.0)
	for y in ROWS + 1:
		var yp: float = board_pos.y + y * CELL
		draw_line(Vector2(board_pos.x, yp), Vector2(board_pos.x + board_size.x, yp),
				Color(0.2, 0.2, 0.25), 1.0)

	# 已锁定的方块 (消行动画期间单独处理)
	if clearing:
		_draw_clearing_cells(board_pos)
	else:
		for y in ROWS:
			for x in COLS:
				if grid[y][x] != 0:
					_draw_cell(Vector2(board_pos.x + x * CELL, board_pos.y + y * CELL),
							CELL, PIECES[grid[y][x] - 1].color)

		# 当前方块的影子 (落点提示)
		_draw_ghost(board_pos)

		# 当前方块
		for i in 4:
			for j in 4:
				if current_matrix[i][j]:
					var gx: int = current_x + j
					var gy: int = current_y + i
					if gy >= 0:
						_draw_cell(Vector2(board_pos.x + gx * CELL, board_pos.y + gy * CELL),
								CELL, PIECES[current_color - 1].color)


# 计算当前方块自然下落到底的 Y, 绘制半透明轮廓影子
func _draw_ghost(board_pos: Vector2) -> void:
	var ghost_y := current_y
	while _is_valid_position(current_matrix, current_x, ghost_y + 1):
		ghost_y += 1
	if ghost_y == current_y:
		return  # 已在底部, 不需影子

	var color = PIECES[current_color - 1].color
	var ghost_color = color.darkened(0.6)
	ghost_color.a = 0.5  # 半透明
	for i in 4:
		for j in 4:
			if current_matrix[i][j]:
				var gx: int = current_x + j
				var gy: int = ghost_y + i
				if gy >= 0:
					var cell_pos := Vector2(board_pos.x + gx * CELL, board_pos.y + gy * CELL)
					# 半透明填充 + 虚线轮廓
					draw_rect(Rect2(cell_pos, Vector2(CELL, CELL)), ghost_color, true)
					_grid_outline(cell_pos, CELL, color.lightened(0.2))


# 消行动画: 扫过位置之前的格子消失, 当前扫到的格子闪白缩小
func _draw_clearing_cells(board_pos: Vector2) -> void:
	var sweep_pos: float = (clear_anim_time / CLEAR_ANIM_DURATION) * float(COLS)

	# 先画非清除行里的锁定方块 (静态)
	for y in ROWS:
		if clearing_rows.has(y):
			continue
		for x in COLS:
			if grid[y][x] != 0:
				_draw_cell(Vector2(board_pos.x + x * CELL, board_pos.y + y * CELL),
						CELL, PIECES[grid[y][x] - 1].color)

	# 再画清除行里的方块, 按扫过进度分三种状态
	for row_idx in clearing_rows:
		for x in COLS:
			var color_idx: int = grid[row_idx][x]
			if color_idx == 0:
				continue
			var cell_color: Color = PIECES[color_idx - 1].color
			# dist = 该格距扫过起点的距离 (沿扫过方向)
			var dist: float = float(x) if clear_direction > 0 else float(COLS - 1 - x)
			var cell_pos := Vector2(board_pos.x + x * CELL, board_pos.y + row_idx * CELL)
			if dist < sweep_pos - 1.0:
				# 已扫过, 完全消失
				continue
			elif dist < sweep_pos:
				# 正在被扫, 闪白 + 缩小 (flash_alpha: 0->1, 0=刚开始 1=快消失)
				var flash_alpha: float = sweep_pos - dist
				_draw_flash_cell(cell_pos, CELL, cell_color, flash_alpha)
			else:
				# 尚未扫到, 正常显示
				_draw_cell(cell_pos, CELL, cell_color)


# 扫过瞬间的特效: 颜色变白 + 缩小, flash_alpha 0=刚开始扫 1=快消失
func _draw_flash_cell(pos: Vector2, size: int, color: Color, flash_alpha: float) -> void:
	if flash_alpha <= 0.0:
		return
	# 颜色向白色过渡 (从原色 -> 偏白)
	var flash_color: Color = color.lerp(Color.WHITE, flash_alpha * 0.8)
	# 缩放: 从 1.0 缩到 0.3
	var scale: float = lerpf(1.0, 0.3, flash_alpha)
	var draw_size: float = float(size) * scale
	var offset: float = (float(size) - draw_size) / 2.0
	draw_rect(Rect2(pos + Vector2(offset, offset), Vector2(draw_size, draw_size)),
			flash_color, true)


func _draw_preview() -> void:
	var preview_size := 4 * PREVIEW_CELL
	var preview_pos := Vector2(PREVIEW_X, PREVIEW_Y)

	# 预览背景 (网格棋盘格)
	var bg_a := Color(0.10, 0.10, 0.14)
	var bg_b := Color(0.14, 0.14, 0.18)
	for i in 4:
		for j in 4:
			var cp := Vector2(preview_pos.x + j * PREVIEW_CELL,
					preview_pos.y + i * PREVIEW_CELL)
			draw_rect(Rect2(cp, Vector2(PREVIEW_CELL, PREVIEW_CELL)),
					bg_a if (i + j) % 2 == 0 else bg_b, true)

	var matrix: Array = PIECES[next_piece].matrix
	var color: Color = PIECES[next_piece].color

	# 找到方块在 4x4 矩阵中的边界框 (min/max 行列), 用于居中
	var min_i := 4
	var max_i := -1
	var min_j := 4
	var max_j := -1
	for i in 4:
		for j in 4:
			if matrix[i][j]:
				min_i = min(min_i, i)
				max_i = max(max_i, i)
				min_j = min(min_j, j)
				max_j = max(max_j, j)
	# 居中偏移: 把边界框居中到 4x4 预览区
	var piece_w := (max_j - min_j + 1) * PREVIEW_CELL
	var piece_h := (max_i - min_i + 1) * PREVIEW_CELL
	var offset_x := (preview_size - piece_w) / 2.0 - min_j * PREVIEW_CELL
	var offset_y := (preview_size - piece_h) / 2.0 - min_i * PREVIEW_CELL

	for i in 4:
		for j in 4:
			if matrix[i][j]:
				_draw_cell(Vector2(preview_pos.x + j * PREVIEW_CELL + offset_x,
						preview_pos.y + i * PREVIEW_CELL + offset_y),
						PREVIEW_CELL, color)


# 暂停遮罩: 半透明黑底 + 居中"已暂停" + 提示
func _draw_pause_overlay() -> void:
	var board_size := Vector2(COLS * CELL, ROWS * CELL)
	var board_pos := Vector2(BOARD_X, BOARD_Y)
	# 半透明遮罩
	draw_rect(Rect2(board_pos, board_size), Color(0, 0, 0, 0.75), true)
	# 居中文字
	var font := get_theme_default_font()
	var center := board_pos + board_size / 2.0
	var title := "已暂停"
	var title_size := 36
	var title_w: float = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
	font.draw_string(get_canvas_item(),
			Vector2(center.x - title_w / 2.0, center.y - 10),
			title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, Color.WHITE)
	var hint := "按 P 继续游戏"
	var hint_size := 18
	var hint_w: float = font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, hint_size).x
	font.draw_string(get_canvas_item(),
			Vector2(center.x - hint_w / 2.0, center.y + 25),
			hint, HORIZONTAL_ALIGNMENT_LEFT, -1, hint_size, Color(0.8, 0.8, 0.8))


# 网格风格方块: 实色填充 + 内部十字网格 + 外边框
func _draw_cell(pos: Vector2, _size: int, color: Color) -> void:
	var rect := Rect2(pos, Vector2(_size, _size))
	var dark := color.darkened(0.45)
	var light := color.lightened(0.25)

	# 实色填充
	draw_rect(rect, color, true)
	# 内部十字网格线 (2x2 子格)
	var mid_x: float = pos.x + _size / 2.0
	var mid_y: float = pos.y + _size / 2.0
	draw_line(Vector2(mid_x, pos.y), Vector2(mid_x, pos.y + _size), dark, 1)
	draw_line(Vector2(pos.x, mid_y), Vector2(pos.x + _size, mid_y), dark, 1)
	# 四角小点 (网格交点强调)
	var dot_size := maxf(2.0, _size * 0.08)
	for cx in [pos.x, mid_x, pos.x + _size]:
		for cy in [pos.y, mid_y, pos.y + _size]:
			draw_rect(Rect2(cx - dot_size / 2, cy - dot_size / 2, dot_size, dot_size), dark, true)
	# 顶部和左侧高光
	draw_line(pos, Vector2(pos.x + _size, pos.y), light, 1.5)
	draw_line(pos, Vector2(pos.x, pos.y + _size), light, 1.5)
	# 外边框
	draw_rect(rect, dark, false, 1.5)


# 虚线轮廓 (用于影子)
func _grid_outline(pos: Vector2, _size: int, color: Color) -> void:
	# 用短虚线段拼出外框
	var dash := 6.0
	var gap := 4.0
	# 上下边
	var x := pos.x
	while x < pos.x + _size:
		var x2 := minf(x + dash, pos.x + _size)
		draw_line(Vector2(x, pos.y), Vector2(x2, pos.y), color, 1.5)
		draw_line(Vector2(x, pos.y + _size), Vector2(x2, pos.y + _size), color, 1.5)
		x += dash + gap
	# 左右边
	var y := pos.y
	while y < pos.y + _size:
		var y2 := minf(y + dash, pos.y + _size)
		draw_line(Vector2(pos.x, y), Vector2(pos.x, y2), color, 1.5)
		draw_line(Vector2(pos.x + _size, y), Vector2(pos.x + _size, y2), color, 1.5)    
		y += dash + gap
