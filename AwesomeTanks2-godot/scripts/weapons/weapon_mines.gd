extends ATWeapon
## ATMinesWeapon —— 地雷武器节点：set_firing(true) 即布设一枚地雷（带冷却），随后自动置 false

class_name ATMinesWeapon

@export var mineScene: PackedScene = null
@export var mineRadius: float = 85.0

var cooldown: float = 0.0


func setFiring(on: bool) -> void:
	super.setFiring(on)
	if on:
		layMine()
		setFiring(false)


func layMine() -> void:
	if ammo <= 0 or cooldown > 0.0 or mineScene == null or tank == null or not is_instance_valid(tank):
		return
	cooldown = 0.45
	var mine: Area2D = mineScene.instantiate()
	var holder: Node = tank.get_parent()
	if holder == null:
		return
	holder.add_child(mine)
	mine.global_position = tank.global_position
	if "ownerActor" in mine:
		mine.ownerActor = tank
	if mine.has_method("setup"):
		mine.setup(team, damage, mineRadius)
	Audio.playSfx("mine.mp3")
	if not hasInfiniteAmmo():
		ammo -= 1
		if ammo <= 0:
			ammo = 0
			outOfAmmo.emit(self)
	shot.emit(self)

func _physics_process(delta: float) -> void:
	if cooldown > 0.0:
		cooldown -= delta
