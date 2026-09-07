extends ATWeapon
## shock 武器脚本（场景继承 weapon.tscn 基类；重写射击逻辑时改 _shoot/_physics_process）
## 电枪：发射 shock_bullet（链式伤害）

class_name ATWeaponShock