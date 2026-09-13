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
- [x] ✅ **Shock**：已重做为武器内置持续武器（无子弹）——RayCast2D(主射线找最近命中体) + Area2D(Chain，命中点附近检测敌人/油桶, 半径200) + Beam/Arc1..3(Line2D, 帧图按段长交替+alpha抖动)；首目标+最多3跳、逐跳最近优先+视线校验；见 `scenes/weapons/shock.tscn` / `scripts/weapons/shock.gd`（原 shock_bullet 场景/脚本已删除；tank/obstacle 增加 H5 conducts_current 导电标记）
- [ ] 🔲 **Rockets**：[special_weapons.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/weapons/special_weapons.gd) 追踪 + 烟雾尾迹（L25）+ 范围爆炸（L36）
- [ ] 🔲 **Laser**：[laser_beam.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/weapons/laser_beam.gd) 射线即时命中（骨架已有，需 `laser_loop` 音频 + 视觉）
- [x] ✅ **Railgun**：已改造为武器内置 RayCast2D(WallRay 找墙定长) + Area2D(HitArea 段内命中全部目标) + Line2D(Beam 双帧贴图交替+收缩淡出动画)；见 `scenes/weapons/railgun.tscn` / `scripts/weapons/railgun.gd`（原 pierce_bullet 场景/脚本已删除）
- [ ] 🔲 **Mines**：[mine.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/weapons/mine.gd) 范围伤害（L39）+ 链式

### 通用完善
- [ ] 🔲 [bullet.gd](file:///f:/AwesomeTanks.github.io-main/AwesomeTanks2-godot/scripts/weapons/bullet.gd) 命中火花粒子 + 警报音（L53）
- [ ] 🔲 各武器的 `hit_color`（受击染色）配置
- [ ] ⚙️ 各武器 5 级升级的参数变化（射速/伤害/数量）— 需从原项目逐级提取

---

## 六、敌人 AI（节点状态机基础版已接入）

框架：`scripts/fsm/state.gd` + `scripts/fsm/state_machine.gd`（场景 `scenes/fsm/state_machine.tscn`）
敌人状态：`scripts/enemies/states/`（基类 `enemy_state.gd` 提供 `can_see_player()/aim_at_player()/fire()/navigate_to()/move_towards()` 等工具）
寻路：`scripts/level/pathfinder.gd`（`ATPathfinder`，Godot 内置 `AStarGrid2D` 包装；由 `Level` 持有，见下）

**已接入**（`scenes/Enemy.tscn` 里挂了 `StateMachine`，子节点为 4 个状态，初始 `Idle`）：

| 状态 | 行为 |
|---|---|
| `Idle` | 原地巡视炮塔（每 2s 转 90°，H5 patrol）；看见玩家 → GoToPlayer |
| `GoToSound` | 寻路走向声音点，到达/超时回 Idle；途中看见玩家 → GoToPlayer |
| `GoToPlayer` | 寻路追到 `keep_distance` 停下；炮塔瞄准、对准+视线通畅即开火；丢失视线 2.5s → Idle |
| `Frozen` | 完全静止（不移动/不开火/不转向）；`unfreeze()` → Idle |

事件入口（`enemy.gd`）：`on_alerted(pos)` → GoToSound（追击/冰冻中忽略）、`on_player_in_sight()` → GoToPlayer、`freeze()/unfreeze()` → Frozen/Idle（`Level.freeze_enemies()` 已补上对所有敌人调用 `freeze()` + 冰冻/解冻音效）。

### 寻路（`ATPathfinder` + `ATEnemy.navigate_to`）

不照搬 H5 的 Easystar，直接用引擎能力：`AStarGrid2D` 就是"2D 网格 A\*"，包装层只做三件事——
按关卡瓦片尺寸初始化网格、把不可通行格标 solid、世界坐标 ↔ 格子坐标换算。

- **Level 侧**：`_ready()` 里 `parse() → _setup_pathfinder() → _spawn_objects()`；`pathfinder` 为公开成员，
  另提供 `find_path()/is_line_walkable()` 便捷方法。
  - 静态墙/秘密墙：建网格时标 solid；
  - 可破坏障碍物（木箱/砖墙/油桶/木板/门）：生成时标 solid，接 `ATObstacle.destroyed` → 摧毁后**解除**（炸开后路径重新打通）；
  - 固定单位（炮塔/生成器）：占格标 solid，接 `killed` → 被摧毁后解除（移动坦克不标 solid，避免互相堵路抖动）。
- **敌人侧**：`ATEnemy.navigate_to(target)`
  1. 直线（格子级 Bresenham）可走 → 直接朝目标推进（快路径，手感自然，不跑 A\*）；
  2. 被挡住 → `find_path()` 取路径并 `smooth_path()` 拉直（string pulling），按 `repath_interval = 0.45s` 重算，逐路径点跟随（`waypoint_reach = 14px`）；
  3. 目标不可达（玩家在还没炸开的砖墙房间里）→ 用 `AStarGrid2D.get_id_path(..., allow_partial_path = true)` 拿到"最接近目标的可达格"的部分路径，一路推进到墙边而不是原地发呆；
  4. 起/终点格被占（单位压在障碍格上）→ 自动退到邻近可走格。
  5. `level == null` 或没有 pathfinder（测试用假关卡）→ 退化为直线推进，不报错。

- [x] ✅ 炮塔/生成器暂不跑这套移动 AI（各自 `_ready` 里 `ai.enabled = false`，炮塔 `move_speed = 0`）
- [x] ✅ 校验：初始 Idle→巡视转动→见玩家 GoToPlayer→贴近开火→失去目标回 Idle→听声 GoToSound（朝声音移动）→冰冻静止→解冻回 Idle；真实关卡（含 Boss/炮塔/生成器）运行无报错
- [x] ✅ 寻路校验：网格逻辑单测（绕墙 A\*、平滑不穿墙、目标为墙退化、越界/同格返回空）+ 物理推进实测（敌人绕过竖墙走下方缺口抵达目标约 40px）+ 15 张关卡全部建网格并与瓦片表零误差 + 打掉障碍物该格重新可通行
- [ ] 🔲 炮塔专属状态（原地 Attack/Patrol，配合 `shoot_angle` 与 90° 巡视）
- [ ] 🔲 声音系统：开火/碰撞产生声音圆并调用 `alert_others()`（现在只有接口，需在开火点接上）
- [ ] 🔲 警戒链调用点：同伴开枪/玩家被发现时广播给半径内敌人
- [ ] 🔲 复杂行为加到状态里：保持掩体、预判射击、命中后退避、Boss 专属行为
- [ ] 🔲 单位间避让（现在只把固定单位当障碍；移动单位之间仍可能互相顶住）
- [ ] 🔲 死亡单位清理（坦克 `_kill()` 只置 `alive=false` 并移除占格标记，尸体节点仍在场景里挡路）
- [ ] 🔲 冰冻视觉（冰壳贴图/解冻特效）
- [ ] 🔲 Kamikaze 自爆（贴近玩家 50px 内自爆：半径 150、伤害 1000）
- [ ] 🔲 旧的 `scripts/enemies/ai_machine.gd`（对象式状态机）已被节点状态机取代，可删除

---

## 七、敌人类型（**已全部创建；重复类型已合并为形态场景**）

基类：`scenes/Enemy.tscn`（`tank.tscn` + `scripts/enemies/enemy.gd`，另加 `BaseSprite` 供炮塔底座）
- 敌人基本参数都在 `ATEnemy` 的导出属性里：`enemy_id / tank_key / max_health / points / move_speed / turret_speed / view_angle / view_distance / shoot_angle / shoot_range / alert_radius / is_boss`
- 坦克/Boss 的车体与炮塔贴图写在各独立场景的 `SpriteFrames` 上（车体两帧 `move` 动画，可扩展更多帧）
- 武器 = `scenes/weapons/*.tscn` 作为**子节点实例**（独立场景）或运行时实例化（形态场景），并在其中覆盖 CPU 专用参数；`ATEnemy._collect_weapons()` 自动收集并注入 `tank`/`team`

共 **18 个场景**（`scenes/enemies/`），承载 **31 种敌人类型**：

| 类别 | 组织方式 | 场景数 |
|---|---|---|
| 移动坦克 9 种 | 各自独立场景：`EnemyMinigun / Shotgun / Cannon / Rockets / Ricochet / Laser / Railgun / Flamethrower / Kamikaze` | 9 |
| Boss 7 种 | 各自独立场景：`BossShotgun / Cannon / Rockets / Laser / Ricochet / Railgun / Flamethrower`（boss_body + `*_boss` 炮塔，`is_boss=true`） | 7 |
| 固定炮塔 8 种 | **合并为 1 个形态场景** `TurretEnemy.tscn`（底座+炮塔两 Sprite），类型数据在 `ATEnemyTypes.TURRETS`，生成时 `apply_type()` 应用 | 1 |
| 生成器 7 种 | **合并为 1 个形态场景** `Spawner.tscn`，类型数据在 `ATEnemyTypes.SPAWNERS`，生成时 `apply_kind()` 应用（贴图 `spawners/<kind>.png`、血量、分数、6 只产出表） | 1 |

- [x] ✅ 数值取自 H5（坦克 L21975-22065 / 炮塔 L21775-21861 / Boss L22067-22145 / 生成器 L22299-22362），基准 `level.index=0, difficulty=1.0`
- [x] ✅ 类型数据表：`scripts/enemies/enemy_types.gd`（`TURRETS` / `TILE_TURRET` / `SPAWNERS` / `TILE_SPAWNER` + 形态场景路径）
- [x] ✅ Level 接入：坦克/Boss 走 `ENEMY_NAMES`（tile→独立场景），炮塔/生成器走形态场景 + `apply_type/apply_kind`；统一登记 `enemies[] / enemies_alive` 并接 `killed`
- [x] ✅ 校验：16 个独立场景 + 8 种炮塔 + 7 种生成器逐个通过；15 个正式关卡实生成敌人数 == 地图敌人瓦片数
- [x] ✅ Kamikaze 无武器（H5 `weapon=null`），保留 `shoot_range=50` 供后续自爆逻辑
- [ ] 🔲 `patrol()` / 开火 / 自爆等行为（等状态机接入）
- [ ] 🔲 难度与关卡缩放：H5 敌人血量乘 `difficulty`、速度乘 `level.index`，当前是基准值，未按关缩放
- [ ] 🔲 生成器 `_try_spawn()`：在附近空格实例化 `spawn_types` 里的敌人（H5 每只随机抽取并移除，共 6 只）；半血换 `_damaged` 贴图
- [ ] 🔲 Boss 差异：友伤 1/3 减免、死亡镜头抖动/掉币；RocketsBoss 在 H5 中继承普通坦克（无减免）
- 备注：H5 里 `RicochetBoss` 实际挂了霰弹武器类（疑似原项目笔误），本项目按其名称使用 `ricochet` 武器（反弹弹）；`RicochetTank` 复用 `railgun_body`、`KamikazeTank` 复用 `laser_body`（图集无专用帧）

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

## 十、战争迷雾（逐格黑雾瓦片版）

文件：
- `scripts/level/fog.gd` / `scenes/level/fog.tscn` —— 黑雾管理器（按地图创建瓦片 + 视野射线）
- `scripts/level/fog_tile.gd` / `scenes/level/fog_tile.tscn` —— 单个黑雾瓦片（Area2D + 黑色贴图 + 放大判定区）
- `sprites/game/fog_tile.png.tres`（项目内既有贴图，atlas region 12×12 纯黑实心块）——由 `scenes/level/fog_tile.tscn` 的 Sprite 引用，并按 tile 尺寸放大（52/12 ≈ 4.333 倍）正好铺满一格；瓦片数量 = 地图格数（每格 1 个 Area2D），不做 12px 细分

- [x] ✅ 地图加载时按地图尺寸逐格创建黑雾瓦片（铺满整图，z=100 盖住地图与单位）
- [x] ✅ 玩家按炮塔方向发射视野射线：射线与 **墙/障碍** 和 **黑雾瓦片** 碰撞
  - 命中黑雾 → 该瓦片播放“放大+淡出+随机旋转”消失动画后释放，射线继续推进
  - 命中墙/障碍 → 射线终止（墙后、箱子后的黑雾保留）
- [x] ✅ 玩家脚下周围一圈黑雾清除（保证能看到自己），随移动持续更新
- [x] ✅ 判定区放大（`fog.tscn` 的 `tile_collision_scale`，默认 1.8 → 93.6px）：
  射线不必贴近本格就能提前清雾；上限约 3.0（外扩 < 1 格墙厚，否则会穿墙误清）
- [x] ✅ 真实关卡集成验证：11×18 地图 → 198 个瓦片（每格 1 个 Area2D），出生即清 20+ 格
- 待办：敌人开火/受击时暴露自己（`ATFog.reveal_at_world(pos, r)` 已留接口）

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
