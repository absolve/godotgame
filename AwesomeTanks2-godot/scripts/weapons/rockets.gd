extends ATWeapon
## rockets 武器（Rockets 制导火箭）——对应原项目 window.AT.weapon.RocketLauncher（L21560~21585）
##
## 玩家规则（H5）：
##   - 按下开火：手上没有在飞的导弹 → 发射一发（交给 Level 制导：player.follow）；
##     已经在制导 → 直接引爆那一发；
##   - 一次只能有一发（H5 tank.follow 的单发约束）；
##   - 松开开火只重置"本次按下"标记，导弹继续飞、继续受鼠标控制；
##   - 切换武器 → 引爆在飞的导弹（H5 deactivate：follow.requestKill = true）。
## 敌方火箭走基类逻辑（自动开火），由 ATRocket 自己追踪玩家。

class_name ATWeaponRockets

## 本次"按下开火"是否已经处理过（H5 RocketLauncher._fire）
var fire: bool = false


func setFiring(on: bool) -> void:
	if team != Constants.Team.PLAYER:
		super.setFiring(on)
		return
	if not on:
		fire = false
		super.setFiring(false)          # 交给基类收尾（停循环音等；本武器没有循环音）
		return
	var rocket := guidedRocket()
	if rocket != null:
		if not fire:
			rocket.call("detonate")      # H5：再按一次开火 = 引爆当前导弹
	elif not fire:
		if ammo <= 0:
			outOfAmmo.emit(self)
		else:
			shoot()                     # 直接发射，不走 rate 节流（H5 每次按下只发一发）
	fire = true


## 切走武器时引爆在飞的导弹（H5 deactivate）
func deactivate() -> void:
	var rocket := guidedRocket()
	if rocket != null:
		rocket.call("detonate")
	fire = false


## 玩家正在制导的那发火箭（H5 tank.follow）
func guidedRocket() -> Node:
	if tank == null or not is_instance_valid(tank) or not ("follow" in tank):
		return null
	var r = tank.get("follow")
	if r is Node and is_instance_valid(r):
		return r
	return null
