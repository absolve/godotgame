extends Node
## Audio — 音频管理单例（移植自原项目 window.AT.audio）
##
## 负责：
##   - 音效播放（一次性）与循环音（激光/火焰/闪电/弹跳）
##   - 背景音乐淡入淡出
##   - 全局静音开关（音效/音乐分离）

## 音效 / 音乐开关变化（setSoundEnabled / setMusicEnabled 发出来）。
## 界面上的开关按钮与 HUD 图标都靠它自动同步，不用各处手写 refresh 逻辑。
signal soundToggled(on: bool)
signal musicToggled(on: bool)

var sfxPool: Array[AudioStreamPlayer] = []
var musicPlayer: AudioStreamPlayer = null
var musicTween: Tween = null

# 循环音句柄（key -> AudioStreamPlayer）
var loops: Dictionary = {}
# 每种循环音的引用计数
var loopRefs: Dictionary = {}
# 受击音专用声道（文件名 -> AudioStreamPlayer）：同一音效不叠加，见 _play_hit_sfx
var hitPlayers: Dictionary = {}

# 资源路径前缀（sounds/ 下所有 mp3）
const SOUND_DIR := "res://sounds/"

func _ready() -> void:
	musicPlayer = AudioStreamPlayer.new()
	musicPlayer.bus = "Music"
	add_child(musicPlayer)

# ============================================================
# 音效（一次性）
# ============================================================
func playSfx(soundName: String, volumeDb: float = 0.0) -> AudioStreamPlayer:
	if not isSoundEnabled():
		return null
	var path := SOUND_DIR + soundName
	if not ResourceLoader.exists(path):
		return null
	var p := acquirePlayer()
	p.stream = load(path)
	p.volume_db = volumeDb
	p.bus = "SFX"
	p.play()
	return p

func playButtonUp() -> void:
	playSfx("button_on.mp3")

func playButtonDown() -> void:
	playSfx("button_off.mp3")

func playEnemyHit() -> void:
	var r := randf() * 3.0
	if r < 1.0: playHitSfx("enemy_hit_1.mp3", -12.0)
	elif r < 2.0: playHitSfx("enemy_hit_2.mp3", -12.0)
	else: playHitSfx("enemy_hit_3.mp3", -12.0)

func playSpawnerHit() -> void:
	var r := randf() * 3.0
	if r < 1.0: playHitSfx("spawner_hit_1.mp3")
	elif r < 2.0: playHitSfx("spawner_hit_2.mp3")
	else: playHitSfx("spawner_hit_3.mp3")

## 受击音：同一个音效复用一条声道，重复触发即从头重播。
## H5 走 Phaser SoundManager（同一音效不会叠成多路），而火焰武器每秒 20+ 次命中，
## 若每次都新建播放器会叠成噪音，故按文件名复用。
func playHitSfx(file: String, volumeDb: float = 0.0) -> void:
	if not isSoundEnabled():
		return
	var path := SOUND_DIR + file
	if not ResourceLoader.exists(path):
		return
	var p: AudioStreamPlayer = hitPlayers.get(file)
	if p == null or not is_instance_valid(p):
		p = AudioStreamPlayer.new()
		p.bus = "SFX"
		p.stream = load(path)
		add_child(p)
		hitPlayers[file] = p
	p.volume_db = volumeDb
	p.play()

# ============================================================
# 循环音（武器持续音）
# ============================================================
func startLoop(key: String, file: String) -> void:
	if not isSoundEnabled():
		return
	if not ResourceLoader.exists(SOUND_DIR + file):
		return
	loopRefs[key] = int(loopRefs.get(key, 0)) + 1
	if loopRefs[key] == 1 and not loops.has(key):
		var p := AudioStreamPlayer.new()
		p.stream = load(SOUND_DIR + file)
		p.bus = "SFX"
		p.finished.connect(onLoopFinished.bind(p))
		add_child(p)
		p.play()
		loops[key] = p

## MP3 不会自动循环：每播完一遍立即重播，直到 stop_loop/cancel_loop 移除
func onLoopFinished(p: AudioStreamPlayer) -> void:
	if not is_instance_valid(p):
		return
	if loops.values().has(p):
		p.play()

func stopLoop(key: String) -> void:
	loopRefs[key] = max(0, int(loopRefs.get(key, 0)) - 1)
	if loopRefs[key] == 0 and loops.has(key):
		(loops[key] as AudioStreamPlayer).stop()
		(loops[key] as AudioStreamPlayer).queue_free()
		loops.erase(key)

func cancelLoop(key: String) -> void:
	loopRefs[key] = 0
	if loops.has(key):
		(loops[key] as AudioStreamPlayer).stop()
		(loops[key] as AudioStreamPlayer).queue_free()
		loops.erase(key)

# 激光/火焰/闪电/弹跳的便捷封装
func startLaserLoop() -> void: startLoop("laser", "laser_loop.mp3")
func stopLaserLoop() -> void: stopLoop("laser")
func cancelLaserLoop() -> void: cancelLoop("laser")
func startFlameLoop() -> void: startLoop("flame", "flame_loop.mp3")
func stopFlameLoop() -> void: stopLoop("flame")
func startShockLoop() -> void: startLoop("shock", "shock_loop.mp3")
func stopShockLoop() -> void: stopLoop("shock")
func startRicochetLoop() -> void: startLoop("ricochet", "ricochet_loop.mp3")
func stopRicochetLoop() -> void: stopLoop("ricochet")

# ============================================================
# 背景音乐
# ============================================================
func playMusic(file: String, fadeMs: int = 200, volume: float = 1.0) -> void:
	if not isMusicEnabled():
		return
	var path := SOUND_DIR + file
	if not ResourceLoader.exists(path):
		return  # 资源尚未导入
	var stream := load(path)
	if musicPlayer.stream == stream and musicPlayer.playing:
		return
	musicPlayer.stream = stream
	musicPlayer.volume_db = -40.0
	musicPlayer.play()
	fadeTo(volume, fadeMs)

func stopMusic(fadeMs: int = 200) -> void:
	if musicTween:
		musicTween.kill()
	musicTween = create_tween()
	musicTween.tween_property(musicPlayer, "volume_db", -80.0, fadeMs / 1000.0)
	musicTween.tween_callback(musicPlayer.stop)

func fadeTo(volume: float, ms: int) -> void:
	if musicTween:
		musicTween.kill()
	musicTween = create_tween()
	musicTween.tween_property(musicPlayer, "volume_db", linear_to_db(volume), ms / 1000.0)

# ============================================================
# 全局开关
# ============================================================
## 当前音效/音乐是否开启（存档 game.sound / game.music）。
## 各个菜单界面原来都自己写一遍 Game.current.get("game", {}).get(...)，统一从这里读。
func isSoundEnabled() -> bool:
	return bool(Game.current.get("game", {}).get("sound", true))

func isMusicEnabled() -> bool:
	return bool(Game.current.get("game", {}).get("music", true))

func setSoundEnabled(enabled: bool) -> void:
	Game.current["game"]["sound"] = enabled
	if not enabled:
		for key in loops.keys():
			cancelLoop(key)
	Game.save()
	soundToggled.emit(enabled)

func setMusicEnabled(enabled: bool) -> void:
	Game.current["game"]["music"] = enabled
	if enabled:
		# 恢复当前曲
		if musicPlayer.stream:
			musicPlayer.play()
			fadeTo(1.0, 200)
	else:
		stopMusic()
	Game.save()
	musicToggled.emit(enabled)

# ============================================================
# 内部：对象池
# ============================================================
func acquirePlayer() -> AudioStreamPlayer:
	for p in sfxPool:
		if not p.playing:
			return p
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	add_child(p)
	sfxPool.append(p)
	return p
