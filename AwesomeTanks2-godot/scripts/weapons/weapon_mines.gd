extends ATWeapon
## ATMinesWeapon —— 地雷武器节点：set_firing(true) 即布设一枚地雷（带冷却），随后自动置 false

class_name ATMinesWeapon

@export var mine_scene: PackedScene = null
@export var mine_radius: float = 85.0

var _cooldown: float = 0.0


func _physics_process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta


func set_firing(on: bool) -> void:
	super.set_firing(on)
	if on:
		_lay_mine()
		set_firing(false)


func _lay_mine() -> void:
	if ammo <= 0 or _cooldown > 0.0 or mine_scene == null or tank == null or not is_instance_valid(tank):
		return
	_cooldown = 0.45
	var mine: Area2D = mine_scene.instantiate()
	var holder: Node = tank.get_parent()
	if holder == null:
		return
	holder.add_child(mine)
	mine.global_position = tank.global_position
	if "owner_actor" in mine:
		mine.owner_actor = tank
	if mine.has_method("setup"):
		mine.setup(team, damage, mine_radius)
	Audio.play_sfx("mine.mp3")
	if not has_infinite_ammo():
		ammo -= 1
		if ammo <= 0:
			ammo = 0
			out_of_ammo.emit(self)
	shot.emit(self)