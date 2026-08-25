extends Node
## ImportAtlas — 一次性工具：把 Phaser TexturePacker JSON Hash atlas
## 转换为 Godot 4 AtlasTexture .tres 资源。
##
## 用法：
##   1. 把本脚本挂到 tools/RunImport.tscn 根节点
##   2. 先运行 `godot --headless --path <project> --import --quit` 让 Godot 把
##      所有 png 注册为 CompressedTexture2D 资源（母图必须先经过导入流程，
##      load() 才能拿到 Texture2D）
##   3. 临时把 project.godot 的 main_scene 改为 tools/RunImport.tscn
##   4. 运行一次 `godot --headless --path <project> --quit-after 15000`
##   5. 完成后改回 main_scene = Boot.tscn
##
## 输入：每套 atlas 是一对 <atlas_path>.png + .json（atlas_path 不含扩展名）
## 输出：res://sprites/<帧名>.tres（帧名直接作为相对路径，保留原项目目录结构）
##   例如 "menu/loading/tank.png" -> res://sprites/menu/loading/tank.png.tres
##        "game/player/body_0.png" -> res://sprites/game/player/body_0.png.tres

const OUTPUT_ROOT := "res://sprites/"

## 要处理的 atlas 列表（res:// 路径，不含 .png/.json 扩展名）
const ATLASES: Array[String] = [
	"res://sprites/menu/loading",                # menu/loading.png + .json
	"res://sprites/menu/levels",                # menu/levels.png + .json
	"res://sprites/menu/title/parts",            # menu/title/parts.png + .json
	"res://sprites/menu/upgrades/parts",         # menu/upgrades/parts.png + .json
	# 如需重新生成 game atlas，取消下面这行注释
	# "res://sprites/atlas/game",
]

func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	var total_count := 0
	var total_skipped := 0

	for atlas_path in ATLASES:
		var result := _import_one(atlas_path)
		total_count += result[0]
		total_skipped += result[1]

	print("[ImportAtlas] 全部完成：共 %d 帧已生成 .tres（跳过 %d）" % [total_count, total_skipped])
	print("[ImportAtlas] 耗时 %d ms" % (Time.get_ticks_msec() - t0))
	get_tree().quit(0)

## 处理单个 atlas，返回 [count, skipped]
func _import_one(atlas_path: String) -> Array:
	var png_path := atlas_path + ".png"
	var json_path := atlas_path + ".json"
	var samples: Array[String] = []
	var count := 0
	var skipped := 0

	# 1. 加载母纹理（要求先经过 `godot --import` 注册为 CompressedTexture2D）
	var master_tex: Texture2D = load(png_path)
	if master_tex == null:
		push_error("[ImportAtlas] 无法加载母纹理: %s" % png_path)
		push_error("[ImportAtlas] 请先运行: godot --headless --path <project> --import --quit")
		return [0, 0]

	# 2. 读 JSON
	if not FileAccess.file_exists(json_path):
		push_error("[ImportAtlas] 缺少 JSON: %s" % json_path)
		return [0, 0]
	var f := FileAccess.open(json_path, FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		push_error("[ImportAtlas] JSON 解析失败: %s" % json_path)
		return [0, 0]
	var data: Dictionary = parsed
	var frames: Dictionary = data.get("frames", {})

	# 3. 遍历每个帧，构造 AtlasTexture 并保存
	for key: String in frames.keys():
		var info: Dictionary = frames[key]
		# 帧名直接作为相对路径，例如 "menu/loading/tank.png"
		var rel: String = key
		# 跳过空帧名或异常键
		if rel.is_empty():
			skipped += 1
			continue

		var frame: Dictionary = info.get("frame", {})
		var fx: int = int(frame.get("x", 0))
		var fy: int = int(frame.get("y", 0))
		var fw: int = int(frame.get("w", 0))
		var fh: int = int(frame.get("h", 0))
		if fw <= 0 or fh <= 0:
			skipped += 1
			continue

		# Phaser JSON Hash 中可能存在 rotated/trimmed 字段，这里仅作基础处理
		# （本项目 4 个 atlas 实测无 rotated/trimmed，故简化）
		var at := AtlasTexture.new()
		at.atlas = master_tex
		at.region = Rect2(fx, fy, fw, fh)
		at.margin = Rect2(0, 0, 0, 0)

		# 保存为 .tres（保留原 .png 后缀，便于和原项目帧名对应查找）
		var out_path: String = OUTPUT_ROOT + rel + ".tres"
		var sub_dir: String = out_path.get_base_dir()
		DirAccess.make_dir_recursive_absolute(sub_dir)

		var err := ResourceSaver.save(at, out_path)
		if err != OK:
			push_error("[ImportAtlas] 保存失败 %s -> 错误 %d" % [out_path, err])
			continue
		count += 1
		if samples.size() < 4:
			samples.append(out_path)

	print("[ImportAtlas] %s -> %d 帧（跳过 %d）" % [atlas_path, count, skipped])
	for s in samples:
		print("  -> %s" % s)
	return [count, skipped]
