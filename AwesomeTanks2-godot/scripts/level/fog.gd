extends Node2D
## Fog — 战争迷雾（移植自原项目 window.AT.Fog）
## 原项目用 RenderTexture 逐格渲染；Godot 用 SubViewport + 动态绘制实现。
##
## 未被玩家探索的格子被迷雾覆盖；视野内格子显示。
## TODO: 待 SubViewport 节点搭建后补全渲染逻辑。

class_name ATFog

@onready var _texture: SubViewport = $FogViewport

var fog_width: int = 0
var fog_height: int = 0
var tiles: Array = []
var visible_flag: bool = false

var tile_offset_x: int = 0
var tile_offset_y: int = 0
var tile_size: int = Settings.TILE_SIZE

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

## 在世界坐标 (px) 处揭开迷雾（圆形揭示）
func reveal(world_x: float, world_y: float, radius_px: float) -> void:
	# TODO: 用 _texture 绘制圆形擦除
	pass

func _process(_delta: float) -> void:
	# 懒更新：跟随玩家逐格揭开
	pass
