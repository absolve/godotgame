extends Control
## AbandonAlert —— 放弃关卡确认框（对应 H5 AbandonAlert：abandon 图 + YES/NO）
## 纯视觉组件：只发 confirmed/canceled 信号，由关卡根脚本执行离开/继续逻辑。

signal confirmed
signal canceled


func _ready() -> void:
	visible = false
	($Center/Panel/YesBtn as TextureButton).pressed.connect(onYes)
	($Center/Panel/NoBtn as TextureButton).pressed.connect(onNo)


func open() -> void:
	visible = true


func close() -> void:
	visible = false


func onYes() -> void:
	Audio.playButtonDown()
	confirmed.emit()


func onNo() -> void:
	Audio.playButtonDown()
	canceled.emit()
