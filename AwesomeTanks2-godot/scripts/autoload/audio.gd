extends Node
## Audio — 音频管理单例（移植自原项目 window.AT.audio）
##
## 负责：
##   - 音效播放（一次性）与循环音（激光/火焰/闪电/弹跳）
##   - 背景音乐淡入淡出
##   - 全局静音开关（音效/音乐分离）

var _sfx_pool: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer = null
var _music_tween: Tween = null

# 循环音句柄（key -> AudioStreamPlayer）
var _loops: Dictionary = {}
# 每种循环音的引用计数
var _loop_refs: Dictionary = {}

# 资源路径前缀（sounds/ 下所有 mp3）
const SOUND_DIR := "res://sounds/"

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

# ============================================================
# 音效（一次性）
# ============================================================
func play_sfx(name: String, volume_db: float = 0.0) -> AudioStreamPlayer:
	if not Game.current["game"]["sound"]:
		return null
	var path := SOUND_DIR + name
	if not ResourceLoader.exists(path):
		return null
	var p := _acquire_player()
	p.stream = load(path)
	p.volume_db = volume_db
	p.bus = "SFX"
	p.play()
	return p

func play_button_up() -> void:
	play_sfx("button_on.mp3")

func play_button_down() -> void:
	play_sfx("button_off.mp3")

func play_enemy_hit() -> void:
	var r := randf() * 3.0
	if r < 1.0: play_sfx("enemy_hit_1.mp3", -12.0)
	elif r < 2.0: play_sfx("enemy_hit_2.mp3", -12.0)
	else: play_sfx("enemy_hit_3.mp3", -12.0)

func play_spawner_hit() -> void:
	var r := randf() * 3.0
	if r < 1.0: play_sfx("spawner_hit_1.mp3")
	elif r < 2.0: play_sfx("spawner_hit_2.mp3")
	else: play_sfx("spawner_hit_3.mp3")

# ============================================================
# 循环音（武器持续音）
# ============================================================
func start_loop(key: String, file: String) -> void:
	if not Game.current["game"]["sound"]:
		return
	if not ResourceLoader.exists(SOUND_DIR + file):
		return
	_loop_refs[key] = int(_loop_refs.get(key, 0)) + 1
	if _loop_refs[key] == 1 and not _loops.has(key):
		var p := AudioStreamPlayer.new()
		p.stream = load(SOUND_DIR + file)
		p.bus = "SFX"
		add_child(p)
		p.play()
		_loops[key] = p

func stop_loop(key: String) -> void:
	_loop_refs[key] = max(0, int(_loop_refs.get(key, 0)) - 1)
	if _loop_refs[key] == 0 and _loops.has(key):
		(_loops[key] as AudioStreamPlayer).stop()
		(_loops[key] as AudioStreamPlayer).queue_free()
		_loops.erase(key)

func cancel_loop(key: String) -> void:
	_loop_refs[key] = 0
	if _loops.has(key):
		(_loops[key] as AudioStreamPlayer).stop()
		(_loops[key] as AudioStreamPlayer).queue_free()
		_loops.erase(key)

# 激光/火焰/闪电/弹跳的便捷封装
func start_laser_loop() -> void: start_loop("laser", "laser_loop.mp3")
func stop_laser_loop() -> void: stop_loop("laser")
func cancel_laser_loop() -> void: cancel_loop("laser")
func start_flame_loop() -> void: start_loop("flame", "flame_loop.mp3")
func stop_flame_loop() -> void: stop_loop("flame")
func start_shock_loop() -> void: start_loop("shock", "shock_loop.mp3")
func stop_shock_loop() -> void: stop_loop("shock")
func start_ricochet_loop() -> void: start_loop("ricochet", "ricochet_loop.mp3")
func stop_ricochet_loop() -> void: stop_loop("ricochet")

# ============================================================
# 背景音乐
# ============================================================
func play_music(file: String, fade_ms: int = 200, volume: float = 1.0) -> void:
	if not Game.current["game"]["music"]:
		return
	var path := SOUND_DIR + file
	if not ResourceLoader.exists(path):
		return  # 资源尚未导入
	var stream := load(path)
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.volume_db = -40.0
	_music_player.play()
	_fade_to(volume, fade_ms)

func stop_music(fade_ms: int = 200) -> void:
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", -80.0, fade_ms / 1000.0)
	_music_tween.tween_callback(_music_player.stop)

func _fade_to(volume: float, ms: int) -> void:
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", linear_to_db(volume), ms / 1000.0)

# ============================================================
# 全局开关
# ============================================================
func set_sound_enabled(enabled: bool) -> void:
	Game.current["game"]["sound"] = enabled
	if not enabled:
		for key in _loops.keys():
			cancel_loop(key)
	Game.save()

func set_music_enabled(enabled: bool) -> void:
	Game.current["game"]["music"] = enabled
	if enabled:
		# 恢复当前曲
		if _music_player.stream:
			_music_player.play()
			_fade_to(1.0, 200)
	else:
		stop_music()
	Game.save()

# ============================================================
# 内部：对象池
# ============================================================
func _acquire_player() -> AudioStreamPlayer:
	for p in _sfx_pool:
		if not p.playing:
			return p
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	add_child(p)
	_sfx_pool.append(p)
	return p
