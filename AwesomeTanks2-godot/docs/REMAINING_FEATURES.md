# Awesome Tanks 2 (Godot 重构) — 剩余功能清单

> 基于已搭建的项目骨架，按系统模块梳理待实现功能。
> 已完成：项目配置、自动加载单例、常量/关卡数据、脚本与场景骨架、着色器转换、game + menu atlas 切分（436 帧 .tres）、字体/音效资源复制、玩家性能档位真实数值（均通过 Godot 4.7 无头验证零错误）。
> 图例：✅ 已实现骨架 ｜ 🔲 待实现 ｜ ⚙️ 需数值/资源

---

## 一、资源准备（核心已就位）

- [x] ✅ 复制精灵图：原项目 `2/images/menu/` → [sprites/menu/](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/sprites/menu/) （4 套 atlas 母图 + 17 张独立图）
- [x] ✅ 复制音效：原项目 `2/sounds/*.mp3` → [sounds/](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/sounds/) （45 个 mp3，含 3 首背景音乐 + 42 个 SFX）
- [x] ✅ 复制字体：`Gunplay` → [fonts/gunplay.ttf](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/fonts/gunplay.ttf) ；⚠️ 未在 `project.godot` 注册为全局 Theme/FontFile（待 UI 阶段处理）
- [x] ✅ 导入精灵图集：基于 [game.json](file:///f:/AwesomeTanks.github.io-main/2/images/game.json) + 4 套 menu atlas 切分为 436 个 `AtlasTexture` .tres（258 game + 7 loading + 49 levels + 19 title + 103 upgrades），工具脚本 [tools/import_atlas.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/tools/import_atlas.gd)
- [ ] ⚙️ 配置 `TileSet` 资源（grass/snow/desert 三套主题贴图 + 墙体变体）

---

## 二、瓦片渲染（TileMap）

文件：[tile_map.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/level/tile_map.gd)

- [ ] 🔲 实现 `_atlas_coord(tile)`：根据瓦片类型 + 主题返回 TileSet atlas 坐标（L47, L56）
- [ ] 🔲 补全 `_build_static_tiles()`：把 WALL/SECRET 写入 `TileMapLayer`（L50-57）
- [ ] 🔲 渲染可破坏砖墙/木箱/门（动态对象，需独立节点而非静态瓦片）
- [ ] 🔲 不同主题的地面贴图铺设

---

## 三、关卡对象实例化（当前全为 pass 存根）

文件：[level.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/level/level.gd)

- [ ] 🔲 `_spawn_player(pos)`：实例化 [Player.tscn](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scenes/Player.tscn)，挂到 `player`，绑定 HUD（L62-63）
- [ ] 🔲 `_spawn_enemy(tile, pos)`：根据瓦片类型实例化 Enemy/TurretEnemy/Spawner，存入 `enemies[]`（L65-66）
- [ ] 🔲 `_spawn_object(kind, pos)`：实例化 barrel/crate/gate/bricks 障碍物（L68-69）
- [ ] 🔲 连接敌人 `killed` 信号 → `on_enemy_killed()`；玩家 `killed` → `on_player_killed()`
- [ ] 🔲 关卡相机：`Camera2D` 跟随玩家 + 边界限制

---

## 四、玩家系统

文件：[player.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/tank/player.gd)

- [ ] 🔲 `_setup_weapons()`：根据 `Game.current["game"]` 的武器等级实例化 10 种武器节点填入 `weapons[]`，minigun 必有（L25-27）
- [ ] 🔲 武器切换：数字键 1-9 / Q E 切换槽位（当前仅 next_weapon）
- [ ] 🔲 `heal(amount)`：医疗包回血接口（被 bonus.gd 调用）
- [ ] 🔲 移动改用 `move_and_collide` 或 `apply_central_force`（当前直接设 `linear_velocity` 可能被物理覆盖）
- [ ] 🔲 玩家死亡处理 + 重生/结算
- [ ] 🔲 移动端虚拟摇杆 + 自动瞄准（`auto_aim` 已声明）

---

## 五、武器系统（10 种，仅基类 + 部分子类骨架）

文件：[weapons/](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/weapons)

### 基类与通用
- [ ] 🔲 [weapon.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/weapons/weapon.gd) `activate()` 实现切换炮塔贴图（L33）
- [ ] 🔲 `_shoot()` 弹药为 0 时切回 minigun（原项目逻辑）
- [ ] 🔲 子弹方向计算修正（L56-57 三元表达式可简化）

### 各武器独立行为
- [ ] 🔲 **Minigun**：默认无限弹药（参数表已在 settings）
- [ ] 🔲 **Shotgun**：多弹丸散射（`spawn_count`/`spread` 已有字段）
- [ ] 🔲 **Ricochet**：子弹碰墙弹跳（需覆盖 bullet 的 `_on_hit`，墙体反弹而非销毁）
- [ ] 🔲 **Flamethrower**：火焰粒子流 + 持续伤害（需粒子 + `flame_loop` 音频已备）
- [ ] 🔲 **Cannon**：等离子弹（普通子弹加大伤害）
- [ ] 🔲 **Shock**：闪电链式跳跃多目标（需目标查找算法）
- [ ] 🔲 **Rockets**：[special_weapons.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/weapons/special_weapons.gd) 追踪 + 烟雾尾迹（L25）+ 范围爆炸（L36）
- [ ] 🔲 **Laser**：[laser_beam.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/weapons/laser_beam.gd) 射线即时命中（骨架已有，需 `laser_loop` 音频 + 视觉）
- [ ] 🔲 **Railgun**：射线穿透多目标
- [ ] 🔲 **Mines**：[mine.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/weapons/mine.gd) 范围伤害（L39）+ 链式

### 通用完善
- [ ] 🔲 [bullet.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/weapons/bullet.gd) 命中火花粒子 + 警报音（L53）
- [ ] 🔲 各武器的 `hit_color`（受击染色）配置
- [ ] ⚙️ 各武器 5 级升级的参数变化（射速/伤害/数量）— 需从原项目逐级提取

---

## 六、敌人 AI（状态机为空壳）

文件：[ai_machine.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/enemies/ai_machine.gd)

- [ ] 🔲 `StateIdle`：巡逻 + 转向逻辑（L52-53 空）
- [ ] 🔲 `StateGoToSound`：调查声音源（需声音系统）
- [ ] 🔲 `StateGoToPlayer`：直接追击（L55 空）
- [ ] 🔲 `StateFollowPlayer`：A* 寻路追击（用 `NavigationAgent2D`，L59 空）
- [ ] 🔲 `StateFrozen`：冰冻（已有，需 `on_unfreeze` 恢复）
- [ ] 🔲 视线检测：`RayCast2D` + 视野角度/距离判断（[enemy.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/enemies/enemy.gd) L24）
- [ ] 🔲 声音警报系统：开火/碰撞产生声音圆，范围内敌人 `alert_others()`（已声明，需调用点）
- [ ] 🔲 警戒链：敌人间互相通知（`alert_others`/`on_alerted` 已声明）

---

## 七、敌人类型

- [ ] 🔲 [enemy.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/enemies/enemy.gd) `patrol()` 实现（L22）
- [ ] 🔲 9 种坦克（minigun/shotgun/cannon/rockets/laser/ricochet/flamethrower/railgun/kamikaze）各自武器与行为
- [ ] 🔲 [turret_enemy.gd](file:///f:/AwesomeTanks2-main/AwesomeTanks2-godot/scripts/enemies/turret_enemy.gd) `_has_line_of_sight()` RayCast2D（L22）
- [ ] 🔲 8 种固定炮塔武器配置
- [ ] 🔲 [spawner.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/enemies/spawner.gd) `_try_spawn()` 实例化敌人放附近空格（L31）
- [ ] 🔲 7 种生成器（颜色对应敌人类型）
- [ ] 🔲 Boss 类：7 种 Boss（高血量 + 特殊武器 + 死亡掉落）
- [ ] 🔲 敌人贴图随武器类型切换

---

## 八、物体交互

文件：[objects/](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/objects)

- [ ] 🔲 [obstacle.gd](file:///f:/AwesomeTanks2-godot/scripts/objects/obstacle.gd) `_die()` 碎片粒子（L27）
- [ ] 🔲 [barrel.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/objects/barrel.gd) `_explode()` 范围伤害 + 链式引爆其它油桶（L19）
- [ ] 🔲 Crate：破坏掉落 bonus
- [ ] 🔲 Gate：开关门逻辑
- [ ] 🔲 Bricks：2 级血量（`BRICKS_1`/`BRICKS_2`）
- [ ] 🔲 [bonus.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/objects/bonus.gd) FREEZE/BOMB 效果实现（L28-30）

---

## 九、HUD

文件：[hud.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/level/hud.gd)

- [ ] 🔲 `bind_player()` 连接玩家信号更新血量/弹药/武器（L13-14）
- [ ] 🔲 `set_active_weapon()` 高亮武器槽（L29-30）
- [ ] 🔲 武器槽 UI 动态生成（10 槽 + mines）
- [ ] 🔲 暂停菜单（Pause 键已绑定）

---

## 十、战争迷雾

文件：[fog.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/level/fog.gd)

- [ ] 🔲 搭建 `SubViewport` 节点结构（L6）
- [ ] 🔲 `reveal()` 圆形擦除绘制（L35）
- [ ] 🔲 `_process` 逐格揭开跟随玩家（L40）
- [ ] 🔲 视野角度/距离限制下的可见区域计算

---

## 十一、特效系统

- [ ] 🔲 [level.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/level/level.gd) `shake_camera()` 相机震动（L89-90）
- [ ] 🔲 爆炸粒子（`GPUParticles2D`）
- [ ] 🔲 受击闪光：应用 [add_tint.gdshader](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/shaders/add_tint.gdshader) 到 Sprite2D material
- [ ] 🔲 死亡灰度：应用 [grayscale.gdshader](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/shaders/grayscale.gdshader)
- [ ] 🔲 时间冻结效果（`freeze_time` 已有，需暂停敌人 update）
- [ ] 🔲 烟雾/火花/碎片/星星粒子资源

---

## 十二、菜单与经济

- [ ] 🔲 [upgrades.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/menu/upgrades.gd) `_refresh()` 刷新武器/性能面板（L10-11）
- [ ] 🔲 武器卡片 UI（图标/等级/价格/弹药条）
- [ ] 🔲 性能升级 UI（speed/turret/sight/armor 4 项）
- [ ] 🔲 补弹按钮（`_on_refill_ammo` 逻辑已有，需 UI）
- [ ] 🔲 购买/升级按钮（`_on_buy_weapon`/`_on_buy_upgrade` 逻辑已有，需 UI）
- [ ] 🔲 [level_select.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/menu/level_select.gd) 关卡按钮样式（锁定/解锁/星级）
- [ ] 🔲 难度选择（简单/中/困难）
- [ ] 🔲 设置界面（音效/音乐开关 — `Audio.set_sound_enabled` 已有）

---

## 十三、结算与流程

- [ ] 🔲 [level.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/level/level.gd) `_show_summary()` 结算面板（L103）
- [ ] 🔲 关卡成功：分数 + 金币奖励 → 解锁下一关 → 升级菜单
- [ ] 🔲 关卡失败：返回升级菜单
- [ ] 🔲 通关祝贺界面（[Congratulations.tscn](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scenes/Congratulations.tscn)）
- [ ] 🔲 Boot 场景资源预加载（`ResourceLoader.load_threaded_request`）

---

## 十四、存档与成就

- [ ] 🔲 成就解锁检测（`increase_achievement` 已有，需触发点 + 通知 UI）
- [ ] 🔲 成就面板展示（9 项）
- [ ] 🔲 统计面板展示（8 项 stats）
- [ ] 🔲 关卡星级/分数记录（`finish_level` 已有）
- [ ] 🔲 总分计算（`get_total_points` 已有）

---

## 十五、音频

- [x] ✅ 导入 50+ 音效资源（[sounds/](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/sounds/) 45 个 mp3 已注册为 AudioStreamMP3）
- [ ] 🔲 武器开火音（每种武器独特音）
- [ ] 🔲 循环音连接：激光/火焰/闪电/弹跳（`start_*_loop` 已封装）
- [ ] 🔲 3 首背景音乐（menu/game/congratulations）
- [ ] 🔲 音频总线（SFX/Music）配置 + 音量调节 UI

---

## 十六、数值平衡（需从原项目精确提取）

文件：[settings.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/autoload/settings.gd)

- [x] ✅ `SPEED_LEVELS` 6 级精确值（来源 [awesome_tanks_2.js#L22535](file:///f:/AwesomeTanks.github.io-main/2/awesome_tanks_2.js#L22535)）
- [x] ✅ `TURRET_LEVELS` 6 级
- [x] ✅ `VIEW_ANGLE_LEVELS` / `VIEW_DISTANCE_LEVELS` 6 级
- [x] ✅ `ARMOR_LEVELS` 6 级 + `ACCELERATION_LEVELS`（新增）
- [ ] ⚙️ 各武器每级伤害/射速/生命/数量参数
- [ ] ⚙️ 敌人血量/伤害/速度（按难度系数 `[0.65,0.85,1.0]` 缩放）

---

## 优先级建议

| 优先级 | 模块 | 说明 |
|--------|------|------|
| P0 | 资源 + TileSet | 一切视觉基础 |
| P0 | 关卡实例化 + 玩家移动 + 子弹射击 | 最小可玩循环 |
| P1 | 敌人 AI 基础 + 受击死亡 | 能打敌人 |
| P1 | 武器 minigun/shotgun/cannon | 3 种核心武器 |
| P2 | 障碍物 + 油桶爆炸 + 拾取物 | 关卡交互完整 |
| P2 | HUD + 商店 UI | 元系统闭环 |
| P3 | 战争迷雾 + 粒子特效 + 全部武器 | 打磨 |
| P3 | 成就/统计 + Boss + 生成器 | 完整内容 |

> 推荐路径：先打通 **P0 最小可玩循环**（玩家移动→射击→敌人受击死亡→关卡结算），再逐层补全。
