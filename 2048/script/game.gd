extends Control
# 2048 游戏 - Godot 4
# 操作: 方向键 / WASD 移动, R 重新开始, ESC 返回主菜单

const SIZE := 4
const TILE_SIZE := 100
const TILE_GAP := 10
const BOARD_PAD := 10
const ANIM_DURATION := 0.10  # 滑动时长 (秒)
const POP_DURATION := 0.15   # 合并/生成 弹出时长 (秒)

class Tile:
	var value: int
	var row: int
	var col: int
	var prev_row: int   # 上一次移动前的位置
	var prev_col: int
	var just_merged: bool = false  # 新合并出来的方块
	var just_spawned: bool = false  # 新生成的方块
	var to_remove: bool = false    # 被合并消费, 动画结束后移除

var tiles: Array = []
var score := 0
var game_over := false
var won := false
var win_shown := false
var anim_time := 0.0
var animating := false
var board_origin := Vector2.ZERO
var board_size := 0.0

var score_label: Label
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

	var restart_btn := Button.new()
	restart_btn.text = "重新开始 (R)"
	restart_btn.pressed.connect(_start)
	top_bar.add_child(restart_btn)

	# 底部消息
	message_label = Label.new()
	message_label.set_anchors_preset(PRESET_BOTTOM_WIDE)
	message_label.offset_left = 20
	message_label.offset_top = -60
	message_label.offset_right = -20
	message_label.offset_bottom = -20
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 20)
	add_child(message_label)


func _start() -> void:
	tiles.clear()
	score = 0
	game_over = false
	won = false
	win_shown = false
	message_label.text = ""
	_spawn_tile()
	_spawn_tile()
	anim_time = 0.0
	animating = true
	_render()


# 在空格中随机生成一个方块 (90% 概率为 2, 10% 概率为 4)
func _spawn_tile() -> bool:
	var empty: Array = []
	for y in SIZE:
		for x in SIZE:
			if _get_tile_at(x, y) == null:
				empty.append(Vector2i(x, y))
	if empty.is_empty():
		return false
	var pos: Vector2i = empty[randi() % empty.size()]
	var t := Tile.new()
	t.value = 4 if randf() < 0.1 else 2
	t.row = pos.y
	t.col = pos.x
	t.prev_row = pos.y
	t.prev_col = pos.x
	t.just_spawned = true
	tiles.append(t)
	return true


# 获取 (x, y) 处未消费的方块, 没有则返回 null
func _get_tile_at(x: int, y: int) -> Tile:
	for t in tiles:
		if not t.to_remove and t.row == y and t.col == x:
			return t
	return null


# 按方向构建所有行/列, 每行内 tiles 按移动方向起点排列
func _build_lines(dir: String) -> Array:
	var lines: Array = []
	for line_idx in SIZE:
		var line_tiles: Array = []
		for pos in SIZE:
			var x: int
			var y: int
			match dir:
				"left":
					x = pos
					y = line_idx
				"right":
					x = SIZE - 1 - pos
					y = line_idx
				"up":
					x = line_idx
					y = pos
				"down":
					x = line_idx
					y = SIZE - 1 - pos
			var t := _get_tile_at(x, y)
			if t != null:
				line_tiles.append(t)
		lines.append(line_tiles)
	return lines


# 把"行内第 pos 个位置"转换为棋盘坐标
func _line_to_pos(line_idx: int, pos: int, dir: String) -> Vector2i:
	match dir:
		"left": return Vector2i(pos, line_idx)
		"right": return Vector2i(SIZE - 1 - pos, line_idx)
		"up": return Vector2i(line_idx, pos)
		"down": return Vector2i(line_idx, SIZE - 1 - pos)
	return Vector2i.ZERO


func _move(dir: String) -> void:
	if game_over or animating:
		return

	# 防御性清理 (理论上 _end_animation 已清理)
	var i := 0
	while i < tiles.size():
		if tiles[i].to_remove:
			tiles.remove_at(i)
		else:
			i += 1

	# 快照上一帧位置, 清除动画标记
	for t in tiles:
		t.prev_row = t.row
		t.prev_col = t.col
		t.just_merged = false
		t.just_spawned = false

	var moved := false
	var lines := _build_lines(dir)

	for line_idx in lines.size():
		var line_tiles: Array = lines[line_idx]
		var target := 0  # 下一个落点在行内的索引
		var k := 0
		while k < line_tiles.size():
			if k + 1 < line_tiles.size() and line_tiles[k].value == line_tiles[k + 1].value:
				# 合并: 两块都滑到 target 位置, 标记 to_remove, 新建合并块
				var new_value: int = line_tiles[k].value * 2
				var target_pos: Vector2i = _line_to_pos(line_idx, target, dir)
				line_tiles[k].row = target_pos.y
				line_tiles[k].col = target_pos.x
				line_tiles[k].to_remove = true
				line_tiles[k + 1].row = target_pos.y
				line_tiles[k + 1].col = target_pos.x
				line_tiles[k + 1].to_remove = true

				var merged_tile := Tile.new()
				merged_tile.value = new_value
				merged_tile.row = target_pos.y
				merged_tile.col = target_pos.x
				merged_tile.prev_row = target_pos.y
				merged_tile.prev_col = target_pos.x
				merged_tile.just_merged = true
				tiles.append(merged_tile)

				score += new_value
				if new_value == 2048:
					won = true
				target += 1
				k += 2
				moved = true
			else:
				# 仅滑动
				var target_pos: Vector2i = _line_to_pos(line_idx, target, dir)
				if line_tiles[k].row != target_pos.y or line_tiles[k].col != target_pos.x:
					moved = true
				line_tiles[k].row = target_pos.y
				line_tiles[k].col = target_pos.x
				target += 1
				k += 1

	if moved:
		_spawn_tile()
		anim_time = 0.0
		animating = true
		_update_state()
		_render()


func _update_state() -> void:
	if not _has_moves():
		game_over = true
		message_label.text = "游戏结束! 按 R 重新开始"
	elif won and not win_shown:
		win_shown = true
		message_label.text = "🎉 达到 2048! 按 R 重新开始, 或继续挑战"


func _has_moves() -> bool:
	# 存在空格
	for y in SIZE:
		for x in SIZE:
			if _get_tile_at(x, y) == null:
				return true
	# 相邻同值
	for y in SIZE:
		for x in SIZE:
			var t := _get_tile_at(x, y)
			if t == null:
				continue
			if x < SIZE - 1:
				var t_r := _get_tile_at(x + 1, y)
				if t_r != null and t_r.value == t.value:
					return true
			if y < SIZE - 1:
				var t_d := _get_tile_at(x, y + 1)
				if t_d != null and t_d.value == t.value:
					return true
	return false


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		Key.KEY_LEFT, Key.KEY_A: _move("left")
		Key.KEY_RIGHT, Key.KEY_D: _move("right")
		Key.KEY_UP, Key.KEY_W: _move("up")
		Key.KEY_DOWN, Key.KEY_S: _move("down")
		Key.KEY_R: _start()
		Key.KEY_ESCAPE: _on_back()


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scene/welcome.tscn")


func _render() -> void:
	score_label.text = "得分: %d" % score
	queue_redraw()


func _process(delta: float) -> void:
	if animating:
		anim_time += delta
		if anim_time >= ANIM_DURATION + POP_DURATION:
			_end_animation()
		queue_redraw()


func _end_animation() -> void:
	animating = false
	var i := 0
	while i < tiles.size():
		if tiles[i].to_remove:
			tiles.remove_at(i)
		else:
			tiles[i].just_merged = false
			tiles[i].just_spawned = false
			i += 1
	queue_redraw()


func _draw() -> void:
	_compute_board_layout()
	_draw_board()


func _compute_board_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	board_size = SIZE * TILE_SIZE + (SIZE - 1) * TILE_GAP + BOARD_PAD * 2
	var top_y := 100.0
	var bottom_y := viewport_size.y - 80.0
	var avail_height := maxf(board_size, bottom_y - top_y)
	var board_y := top_y + (avail_height - board_size) / 2.0
	var board_x := (viewport_size.x - board_size) / 2.0
	board_origin = Vector2(board_x, board_y)


func _draw_board() -> void:
	# 棋盘背景
	draw_rect(Rect2(board_origin, Vector2(board_size, board_size)),
			Color(0.46, 0.42, 0.39), true)

	# 空格子背景
	for y in SIZE:
		for x in SIZE:
			var cell_pos := board_origin + Vector2(
				BOARD_PAD + x * (TILE_SIZE + TILE_GAP),
				BOARD_PAD + y * (TILE_SIZE + TILE_GAP)
			)
			draw_rect(Rect2(cell_pos, Vector2(TILE_SIZE, TILE_SIZE)),
					Color(0.35, 0.32, 0.30), true)

	# 动画进度
	var slide_t := clampf(anim_time / ANIM_DURATION, 0.0, 1.0) if animating else 1.0
	var in_slide := animating and anim_time < ANIM_DURATION
	var in_pop := animating and anim_time >= ANIM_DURATION
	var pop_t := clampf((anim_time - ANIM_DURATION) / POP_DURATION, 0.0, 1.0) if in_pop else 1.0
	# ease-out: 滑动末段减速
	var slide_eased := 1.0 - (1.0 - slide_t) * (1.0 - slide_t)

	for t in tiles:
		# 滑动阶段: 隐藏新生成和合并方块
		if in_slide and (t.just_spawned or t.just_merged):
			continue
		# 弹出阶段: 隐藏被消费的方块
		if in_pop and t.to_remove:
			continue

		var display_col := lerpf(t.prev_col, t.col, slide_eased)
		var display_row := lerpf(t.prev_row, t.row, slide_eased)

		var scale := 1.0
		if in_pop:
			if t.just_merged:
				scale = _merge_scale(pop_t)
			elif t.just_spawned:
				scale = _spawn_scale(pop_t)

		_draw_tile(display_col, display_row, t.value, scale)


func _draw_tile(col_f: float, row_f: float, value: int, scale_factor: float) -> void:
	var cell_pos := board_origin + Vector2(
		BOARD_PAD + col_f * (TILE_SIZE + TILE_GAP),
		BOARD_PAD + row_f * (TILE_SIZE + TILE_GAP)
	)
	var size := TILE_SIZE * scale_factor
	var offset := (TILE_SIZE - size) / 2.0
	var tile_rect := Rect2(cell_pos + Vector2(offset, offset), Vector2(size, size))
	draw_rect(tile_rect, _tile_color(value), true)
	_draw_tile_text(tile_rect.position, size, value)


func _draw_tile_text(cell_pos: Vector2, size: float, val: int) -> void:
	var text := str(val)
	var font := get_theme_default_font()
	var fs := _font_size(val)
	var tc := _font_text_color(val)
	var ts: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var ascent: float = font.get_ascent(fs)
	var top_left := Vector2(
		cell_pos.x + (size - ts.x) / 2.0,
		cell_pos.y + (size - ts.y) / 2.0
	)
	draw_string(font, top_left + Vector2(0, ascent), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, tc)


# 合并弹出: 1.0 -> 1.2 -> 1.0
func _merge_scale(t: float) -> float:
	return 1.0 + 0.2 * sin(t * PI)


# 生成弹出: 0 -> 1.0 (ease-out, 末段减速)
func _spawn_scale(t: float) -> float:
	return 1.0 - (1.0 - t) * (1.0 - t)


func _tile_color(val: int) -> Color:
	match val:
		2: return Color("#eee4da")
		4: return Color("#ede0c8")
		8: return Color("#f2b179")
		16: return Color("#f59563")
		32: return Color("#f67c5f")
		64: return Color("#f65e3b")
		128: return Color("#edcf72")
		256: return Color("#edcc61")
		512: return Color("#edc850")
		1024: return Color("#edc53f")
		2048: return Color("#edc22e")
		_: return Color("#3c3a32")


func _font_text_color(val: int) -> Color:
	if val <= 4:
		return Color("#776e65")
	return Color("#f9f6f2")


func _font_size(val: int) -> int:
	if val < 100:
		return 50
	if val < 1000:
		return 42
	if val < 10000:
		return 34
	return 28
