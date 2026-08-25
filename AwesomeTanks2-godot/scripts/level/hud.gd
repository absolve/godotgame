extends CanvasLayer
## Hud — 游戏内 HUD（血条/弹药/金钱/武器槽/暂停）
## 对应原项目 game/hud 精灵与 Level.hud

class_name ATHud

@onready var _health_bar: ProgressBar = $TopBar/HealthBar
@onready var _money_label: Label = $TopBar/MoneyLabel
@onready var _ammo_label: Label = $TopBar/AmmoLabel
@onready var _weapon_slots: HBoxContainer = $WeaponSlots

var _slot_buttons: Array[Button] = []

func bind_player(player: Node2D) -> void:
	# TODO: 连接玩家信号更新血量/弹药/武器
	if player.has_signal("killed"):
		player.killed.connect(_on_player_killed)
	_build_weapon_slots(player)

func _build_weapon_slots(player: Node2D) -> void:
	for c in _weapon_slots.get_children():
		c.queue_free()
	_slot_buttons.clear()
	var weapons: Array = player.weapons if "weapons" in player else []
	for i in range(weapons.size()):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(48, 40)
		btn.text = "%d" % (i + 1)
		btn.disabled = weapons[i] == null
		if weapons[i] != null:
			btn.pressed.connect(player.change_weapon.bind(i))
		_weapon_slots.add_child(btn)
		_slot_buttons.append(btn)

func update_health(ratio: float) -> void:
	if _health_bar:
		_health_bar.value = clamp(ratio * 100.0, 0.0, 100.0)

func update_money(amount: int) -> void:
	if _money_label:
		_money_label.text = "$%d" % amount

func update_ammo(weapon: String, ammo: int, max_ammo: int) -> void:
	if _ammo_label:
		_ammo_label.text = "%s  %d/%d" % [weapon.capitalize(), ammo, max_ammo]

func set_active_weapon(index: int) -> void:
	for i in range(_slot_buttons.size()):
		var btn: Button = _slot_buttons[i]
		btn.modulate = Color(1, 0.85, 0.3) if i == index else Color.WHITE

func _on_player_killed() -> void:
	# TODO: 死亡 HUD 反馈
	pass
