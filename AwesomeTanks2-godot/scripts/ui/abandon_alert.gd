extends Control
## AbandonAlert —— 放弃关卡确认框（对应 H5 AbandonAlert：abandon 图 + YES/NO）
## 纯视觉组件：只发 confirmed/canceled 信号，由关卡根脚本执行离开/继续逻辑。

signal confirmed
signal canceled


func _ready() -> void:
	visible = false
	($Center/Panel/YesBtn as TextureButton).pressed.connect(_on_yes)
	($Center/Panel/NoBtn as TextureButton).pressed.connect(_on_no)


func open() -> void:
	visible = true


func close() -> void:
	visible = false


func _on_yes() -> void:
	Audio.play_button_down()
	confirmed.emit()


func _on_no() -> void:
	Audio.play_button_down()
	canceled.emit()
