extends Node2D
## Fog —— 战争迷雾（对应原项目 window.AT.Fog，awesome_tanks_2.js L22679~22686）
##
## H5 机制（分析结论）：
##   1) tiles[fogHeight][fogWidth] 布尔网格，初始全 false(=有雾)，永久揭示、不回收；
##   2) 渲染：整幅 RenderTexture + inverse_alpha shader → 未揭示处不透明黑雾，
##      已揭示(被画过)处透明显示下方地图；
##   3) 三种揭示：
##        revealTile(x,y)          —— 永久揭开一格（画 12px 小圆 fog_tile）；
##        revealTileArea(x,y)      —— 玩家所在格每帧刷大圈 fog_circle(36px)，脚下常亮；
##        revealFogAtLocation(body)—— 开火/被击中时揭该格（敌人开枪会暴露自己）。
##   4) 扇形视野 revealFogArc(tankBody, turretAngle±viewAngle, viewDistance)：
##        每 2π/36 一条射线，向远处每次推进 (dist/20)，逐格 revealTile；
##        若该格在 objects 网格中有活的遮挡物(墙/砖/crate/油桶/炮塔…)
##        → 立即 break：被挡的格子（箱子/墙后面）不会揭雾。
##   5) 由关卡每 1~3 帧调用 updateFog，玩家初始位置也立刻执行一次。
##
## Godot 实现：行为层保留 tiles 网格（可 headless 验证）；渲染层自绘一张
## 低分辨率黑色 ImageTexture（每瓦片 SCALE 像素），揭示时把该瓦片圆形区域
## alpha 渐变置 0（透明=雾消失），Sprite2D 铺满地图即可，无需额外 shader。

class_name ATFog

## 每瓦片纹理像素数（H5 fogResolution=12；8 已够平滑且图很小）
const SCALE: int = 8

## 单格揭示圆半径（瓦片单位；H5 fog_tile≈0.5 放大后约 1 格）
const TILE_RADIUS: float = 0.62
## 玩家脚下大圈半径（瓦片单位；H5 fog_circle 36px≈0.7，放大后约 1.5 格）
const AREA_RADIUS: float = 1.6
## 圆形边缘羽化宽度（瓦片单位）
const SOFT: float = 0.55

var fog_width: int = 0
var fog_height: int = 0
var tiles: Array = []            # tiles[y][x] = true 已揭示
var tile_offset_x: int = 0
var tile_offset_y: int = 0
var tile_size: int = Settings.TILE_SIZE

var _img: Image = null
var _tex: ImageTexture = null
var _sprite: Sprite2D = null
var _dirty := false

## 是否阻塞视线的回调（由关卡提供：静态墙 / crate / 砖 / 油桶 等）
## 传 null 表示无遮挡。
var _blocked_cb: Callable = Callable()


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.name = "FogSprite"
	_sprite.centered = false
	_sprite.position = Vector2.ZERO
	add_child(_sprite)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


## 关卡初始化调用。w/h 为地图瓦片数；offset 为世界原点对应的瓦片角。
func configure(offset_x: int, offset_y: int, w: int, h: int) -> void:
	tile_offset_x = offset_x
	tile_offset_y = offset_y
	fog_width = w
	fog_height = h
	tiles.clear()
	for y in range(h):
		var row: Array = []
		for x in range(w):
			row.append(false)
		tiles.append(row)
	_build_texture()
	_sprite.scale = Vector2(float(tile_size) / SCALE, float(tile_size) / SCALE)


func set_blocked_cb(cb: Callable) -> void:
	_blocked_cb = cb


## 重建全黑 Image 纹理（未探索=不透明黑）
func _build_texture() -> void:
	_img = Image.create(fog_width * SCALE, fog_height * SCALE, false, Image.FORMAT_RGBA8)
	_img.fill(Color(0, 0, 0, 1))
	_tex = ImageTexture.create_from_image(_img)
	_sprite.texture = _tex


func _sync_texture() -> void:
	if _dirty and _tex != null and _img != null:
		_tex.update(_img)
		_dirty = false


# ============================================================
# 揭示 API（决策 + 纹理）
# ============================================================
## 揭开一格（含羽化圆斑）；已揭过则跳过（避免重复写纹理）
func reveal_tile(x: int, y: int) -> bool:
	var tx := x - tile_offset_x
	var ty := y - tile_offset_y
	if tx < 0 or ty < 0 or tx >= fog_width or ty >= fog_height:
		return false
	if tiles[ty][tx]:
		return false
	tiles[ty][tx] = true
	_paint_hole(Vector2(tx + 0.5, ty + 0.5), TILE_RADIUS)
	return true


## 玩家脚下大圈（H5 revealTileArea：无条件画 fog_circle，覆盖格标记为已揭示）
func reveal_tile_area(x: int, y: int) -> void:
	var tx := x - tile_offset_x
	var ty := y - tile_offset_y
	if tx < 0 or ty < 0 or tx >= fog_width or ty >= fog_height:
		return
	_paint_hole(Vector2(tx + 0.5, ty + 0.5), AREA_RADIUS)
	# 圈内覆盖到的瓦片也记作已揭示（与纹理一致，供查询/测试）
	_mark_circle_tiles(tx + 0.5, ty + 0.5, AREA_RADIUS)


func _mark_circle_tiles(cx: float, cy: float, radius: float) -> void:
	var r2 := radius * radius
	var x0 := maxi(0, int(cx - radius) - 1)
	var x1 := mini(fog_width - 1, int(cx + radius) + 1)
	var y0 := maxi(0, int(cy - radius) - 1)
	var y1 := mini(fog_height - 1, int(cy + radius) + 1)
	for yy in range(y0, y1 + 1):
		for xx in range(x0, x1 + 1):
			var dx := xx + 0.5 - cx
			var dy := yy + 0.5 - cy
			if dx * dx + dy * dy <= r2:
				tiles[yy][xx] = true


## 画一个中心为瓦片坐标、半径 radius(瓦片) 的透明洞（边缘羽化）
func _paint_hole(center: Vector2, radius: float) -> void:
	if _img == null:
		return
	var px := Vector2(center.x * SCALE, center.y * SCALE)
	var r := radius * SCALE
	var soft := SOFT * SCALE
	var x0 := clampi(int(px.x - r - soft), 0, _img.get_width() - 1)
	var x1 := clampi(int(px.x + r + soft) + 1, 0, _img.get_width())
	var y0 := clampi(int(px.y - r - soft), 0, _img.get_height() - 1)
	var y1 := clampi(int(px.y + r + soft) + 1, 0, _img.get_height())
	for yy in range(y0, y1):
		for xx in range(x0, x1):
			var d := Vector2(xx + 0.5 - px.x, yy + 0.5 - px.y).length()
			if d > r + soft:
				continue
			var target_alpha := 0.0
			if d <= r:
				target_alpha = 0.0
			else:
				target_alpha = clampf((d - r) / maxf(soft, 0.001), 0.0, 1.0)
			var cur := _img.get_pixel(xx, yy)
			# 透明取“更透明”（保持已揭示处干净）
			if target_alpha < cur.a:
				cur.a = target_alpha
				_img.set_pixel(xx, yy, cur)
	_dirty = true


# ============================================================
# 视野扫描（H5 revealFogArc 移植）
# ============================================================
## 玩家视野：以 center(像素) 为原点，朝向 turret_angle，半角 view_angle 的扇形，
## 距离 view_distance(像素)。逐条射线推进，遇遮挡格立即停止。
func update_fov(center: Vector2, turret_angle: float, view_angle: float, view_distance: float) -> void:
	var start_a := turret_angle - view_angle
	var end_a := turret_angle + view_angle
	var step_a := TAU / 36.0   # H5: 2π/36 ≈ 每 10°
	var a := start_a
	while a < end_a:
		_reveal_ray(center, a, view_distance)
		a += step_a
	_sync_texture()


func _reveal_ray(center: Vector2, angle: float, dist: float) -> void:
	var dir := Vector2(cos(angle), sin(angle))
	var steps := 20  # H5 固定 20 小步
	var pos := center
	for _i in steps:
		# 越界即止（墙外无地图）
		if pos.x < 0 or pos.y < 0 or pos.x >= fog_width * tile_size or pos.y >= fog_height * tile_size:
			return
		var tx := int(pos.x / tile_size) + tile_offset_x
		var ty := int(pos.y / tile_size) + tile_offset_y
		# 走到自己坦克格/脚下已用 area 揭示，仍允许 reveal（幂等）
		reveal_tile(tx, ty)
		# 该格有遮挡(墙/箱…) → 射线停下，之后不揭
		if _is_blocked(tx, ty):
			return
		pos += dir * (dist / steps)


func _is_blocked(x: int, y: int) -> bool:
	if _blocked_cb.is_valid():
		return bool(_blocked_cb.call(x, y))
	return false


# ============================================================
# 调试/测试辅助
# ============================================================
func is_revealed(x: int, y: int) -> bool:
	var tx := x - tile_offset_x
	var ty := y - tile_offset_y
	if tx < 0 or ty < 0 or tx >= fog_width or ty >= fog_height:
		return false
	return tiles[ty][tx]


func revealed_count() -> int:
	var n := 0
	for row in tiles:
		for v in row:
			if v:
				n += 1
	return n


func reset() -> void:
	for y in range(fog_height):
		for x in range(fog_width):
			tiles[y][x] = false
	if _img != null:
		_img.fill(Color(0, 0, 0, 1))
		_sync_texture()
