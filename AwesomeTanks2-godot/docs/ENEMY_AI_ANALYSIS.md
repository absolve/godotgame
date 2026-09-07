# 敌方 AI 逻辑分析 & Godot 移植设计（Awesome Tanks 2）

> 目标：拆解 H5 原版（`awesome_tanks_2.js`）敌人 AI 的完整设计，并给出 Godot 重构版
> （`scripts/enemies/*`、`scripts/level/level.gd`）对应的移植/实现方案。
> 行号为源 JS 检索锚点（±几十行误差）；Godot 侧目前为骨架代码，正文给出补全建议。
> 配套：`ORIGINAL_H5_ANALYSIS.md`（整项目结构与模块设计）。

---

## 一、总体设计

H5 敌人不是“一坨 if/else 行为树”，而是**有限状态机 + 每帧感知缓存 + 消息式状态切换**：

```
                   ┌────────────────────────────────────────────┐
  出生 Spawn ──►   │                 Idle(漫游/巡逻)              │
                   │  每帧 patrol(alerted)：检测玩家 + 自动射击     │
                   └───┬──────────┬────────────┬──────────────┬───┘
            看到玩家     │   听到声音   │   受击alert │  玩家超近60px │
    (视线raycast)        │            │            │              │
                   ▼    ▼            ▼            ▼              │
        ┌──FollowPlayer(追击, A*持续)──►(丢失>4s/玩家死亡)→ Idle │
        └──GoToPlayer / GoToSound(赶往记忆点,>10s回Idle)        │
                                                                  │
   任意状态 onFreeze ──► Frozen(叠冰/停火)── onUnfreeze ──► Idle  ◄┘
```

- 敌人本体（坦克）**每帧**做感知数据缓存（到玩家距离/角度、瓦片位置、可见性）；
- 状态机只做“决策”，真正的移动/转向/开火调用在坦克方法上（`patrol / shoot / findPath`）；
- 跨状态事件通过 `states.message("onPlayerInSight"|"onSoundEmitted"|"onFreeze"|"onUnfreeze")` 派发到当前状态；
- 移动用 **Box2D 施加力 + 车身转向 + 限速**（不是瞬移/纯速度赋值）。

---

## 二、H5 状态机解剖（源码对照）

### 2.1 基础设施

| 项 | 说明 |
|---|---|
| `AT.states.State / StateMachine` | 状态基类支持 `extend(name, hooks)`；Machine 维护 `time`（当前状态已持续）并派发消息 |
| hooks 约定 | `enter / exit / update / tileReached / targetReached / pathNeedsUpdate / onFreeze / onUnfreeze / onPlayerInSight / onSoundEmitted`（按需覆写） |
| `window.AT.ai` 导出 | `GoTo / Spawn / Frozen / Idle / GoToSound / GoToPlayer / FollowPlayer` |
| 切换入口 | `states.change(State, args)`；全局消息 `states.message("...")` |

### 2.2 各状态职责与迁移（源码行为整理）

**Idle（默认巡逻）**
- `enter`：记下当前 tile 为目标；
- 每帧：先 `patrol(alerted)` —— 若“看到玩家”则一边转炮开火一边返回 true → `alertOthers()`（200px 内同伴收到 onPlayerInSight）并切 **FollowPlayer**；
- 否则按 `delay`(1~6s 随机) 在**随机相邻空格**间游走（带微小随机抖动 offset），即无目的地闲逛；
- `onPlayerInSight / onSoundEmitted` → GoToPlayer；`onFreeze` → Frozen。

**GoTo（寻路基类）**
- 向目标 tile 用 **Easystar** 异步寻路（`level.findPath`，缓存 `pathInstanceId`，可 `cancelPath`）；
- 逐格推进：距当前格子中心 <30px 时进下一格；**提前检查未来 5 步是否被占**，被占立即重寻（动态避障）；
- 移动：对 body `applyForce(单位方向 × mass × 系数)` + `rotate(body, 角度, 4)` 平滑转向；
- `exit`：取消未完成的寻路实例。

**GoToSound / GoToPlayer（赶往记忆点）**
- 目标 = 声音坐标 / 玩家**当前 tile 快照**；
- `update`：若玩家死亡或状态停留 ≥10s → 回 Idle；途中 `patrol(false)` 一旦看到玩家 → **FollowPlayer**；
- 到达目标(tileReached) → Idle（没发现就放弃）。

**FollowPlayer（主动追击）**
- 目标始终取玩家最新 tile，但**不是每帧重寻**：
  `pathNeedsUpdate` 判定 = 玩家距目标 tile >1 格 / 路径为空 / 前方 5 步被堵，才重新 `findPath`（重寻节流）；
- 每帧若在 `shootRange` 内且视线通畅就开火；否则继续逼近；
- `forgetTime ≥4s`（被遮挡看不到玩家）或玩家死亡 → 回 Idle。

**Frozen（冰冻）**
- `enter`：给坦克加冰覆盖层 `ice.png`(α≈0.85) + 播冰晶粒子 + 武器停火；
- 冰冻中再受冻结消息 → 只补播冰晶；`onUnfreeze` → 回 **Idle**；
- `exit`：移除冰层并播冰晶；冰冻时长由 **Level 全局统一计时**并广播解冻。

**Spawn（从生成器出生）**
- `enter`：短暂白闪(hit=1, hitColor=白)标记生成中的无敌/半出场状态；
- 找生成器周围随机空格并移动过去；`≥0.5s` 若搜索到玩家 → FollowPlayer；到达/超时 5s → Idle；
- `onFreeze`→Frozen；`onPlayerInSight`→GoToPlayer。

**Kamikaze（自爆坦克）**：重写 `patrol` —— 一旦进入 `shootRange` 即自杀，引发大范围爆炸（伤害半径 150、也炸友军）。
**Boss/小怪**：参数不同（血量/射程/加速度），移动逻辑与普通坦克一致；small 体型 `scale 0.7`、血量 1/3。

### 2.3 消息/警戒传播链路

| 触发 | 代码要点 | 效果 |
|---|---|---|
| 敌人**受击** | `alert()`：`_alerted=2.5s` + `alertOthers()`(半径 200) | 自身与同伴进入“警觉”态；警觉态**放宽 120° 视锥**为全向 |
| 敌人**看到玩家**(在 Idle) | `patrol→alertOthers + →FollowPlayer` | 200px 内同伴立刻收到 onPlayerInSight |
| 玩家/武器**开火声** | `level.alertSound(x,y,radius)`（武器 `soundAlertRadius`≈100） | 半径内 `message(onSoundEmitted)` → 去玩家方向 |
| 生成器受击 | 通知自己产出的坦克 `onPlayerInSight` | 抱团反击 |
| 冻结/解冻 | Level `freeze` 全图广播 `message(onFreeze/onUnfreeze)` | 全员切换 Frozen 状态 |
| 火焰(持续燃烧) | 伤害对象 `Fire` 覆盖目标 | 烧毁冰层 → 触发解冻 |

---

## 三、感知与开火（“看到/打中”怎么算）

每帧（坦克 `update`）先更新 `distanceToPlayer / rotationToPlayer / tileX/Y / visible`，供状态机与射击用。

**searchForPlayer(alerted)**（能不能看到玩家）
1. 玩家死亡 → false；
2. 距离 **<60px 无条件视为看到**；
3. 距离 **> sightRange** → 看不到；
4. `!alerted` 时要求**炮塔朝向玩家 ≤120°**（正视锥），警觉后全向；
5. Box2D **raycast(我→玩家)**，过滤 `visibilityFilter`：被墙/障碍/敌人等挡 → 看不到。

**patrol / shoot（巡逻即战斗）**
- 看到玩家：炮塔平滑转向 `rotationToPlayer`，若在 `shootAngle` 内且 **lineOfFireClear** 就 `weapon.startFire()`，否则停火；
- 没看到：炮塔回中停火；
- `lineOfFireClear`：另一条 raycast(我→玩家) 用 `shootingFilter`（可穿透子弹，被墙/障碍挡）。

> 关键点：**“视线”和“开火线”是两条不同过滤条件的射线**；警觉(被击中/同伴报警)会放宽转向视锥。

---

## 四、特殊单位 AI 变体

| 单位 | AI 设计 |
|---|---|
| 普通坦克×9 | 状态机全功能；按类设定 speedMax/acceleration/turretSpeed/sightRange/shootRange/shootAngle + 武器 |
| Boss×7 | 同状态机，更高血量/参数（有独立贴图），部分行为差异 |
| Kamikaze | 见上：近身自爆 |
| 固定炮塔×8 | 无移动：每帧对准玩家 + line-of-fire 判断开火（简化巡逻，不参与寻路） |
| 生成器×7 | 固定：计时(1+random s)，同时存活 <4、累计 <6 时随机类型产坦克(池不重复)，出生即进 **Spawn** 状态；半血换 `_damaged` 帧 + 冒烟；死亡按“已产量”掉更多金币 |

参数缩放：`difficulty` 乘血量等，`level.index` 增加速度/射速/射程，small 型 1/3。

---

## 五、Godot 移植设计（现状骨架 → 补全方案）

### 5.1 现有骨架对照

| Godot 文件 | class | 现状 |
|---|---|---|
| `scripts/enemies/ai_machine.gd` | `ATAIMachine`/`ATAIState` | 状态机外壳齐（change/update/消息），StateIdle/GoToPlayer/Follow/Frozen 仅桩 |
| `scripts/enemies/enemy.gd` | `ATEnemy extends ATTank` | 挂 machine；`alert_others/on_alerted/on_player_in_sight` 有雏形，`patrol()` 未实现 |
| `scripts/enemies/spawner.gd` | `ATSpawner` | 计时/上限外壳，`_try_spawn()` TODO |
| `scripts/enemies/turret_enemy.gd` | `ATTurretEnemy` | 朝玩家转向雏形，`_has_line_of_sight()` TODO |
| `scripts/level/level.gd` | Level(根) | 已含瓦片/occupancy/坐标；需补 声音广播、冻结广播、寻路服务 |

### 5.2 状态机实现（与 H5 语义一一对应）

```text
ATAIState(内嵌类)  hook：enter/exit/update/on_player_in_sight/on_sound_emitted/on_freeze/on_unfreeze
StateIdle        漫游：随机邻格目标 + delay；update 先 try patrol → 报警链 & FollowPlayer
StateGoTo        寻路基类（path 缓存、tileReached 提前看前 N 步、动态重寻）
StateGoToSound   目标=声音点，>10s 回 Idle，途中看到→FollowPlayer
StateGoToPlayer  目标=玩家快照 tile，同上
StateFollowPlayer 重寻节流 + forget 计时(4s)回 Idle
StateFrozen      ice 覆盖/停火，解冻→Idle
StateSpawn       出生移动/白闪，>5s→Idle，见玩家→FollowPlayer
```

实现建议：
- `ATAIMachine` 加 `message(hook, args)`（现状是逐 hook 转发，可保留）；
- 状态间用 `owner`（坦克）调共享方法，避免状态内写业务；
- `machine.time` 已存在，正好做 5s/10s/4s 计时。

### 5.3 感知/射击层（放到 ATEnemy，供状态调用）

- 每物理帧缓存：`player_distance / angle_to_player / tile_x / tile_y`（复用 level 的 px_to_tile/occupancy）；
- `can_see_player(relaxed_fov: bool)`：
  1. `player == null or !alive` → false
  2. 距离 < 60 → true；距离 > sight_range → false
  3. `!relaxed_fov` 且炮塔与玩家夹角 > 60°（120°锥）→ false
  4. `PhysicsDirectSpaceState2D.intersect_ray(from,to, mask=墙|障碍|敌)` → 无遮挡才 true
- `line_of_fire_clear()`：第二条射线（mask=墙|障碍|敌），可穿过子弹；
- `patrol(relaxed) → bool`：能看见则转炮 + `shoot()`（夹角≤shoot_angle 且射界清）并返回 true；
- `_alerted` 计时器 + `alert_others()`（半径 200，发 `on_player_in_sight`）——已具备雏形；
- 建议把射线探测**节流**（如每 3 帧或 0.05~0.1s 一次，H5 用 debounce 思路），避免每帧 10+ 敌人全量 raycast。

### 5.4 寻路层（二选一）

方案 A（贴合 H5，改动小）：保留 level 网格
- 由 `level.gd` 提供 `find_path(from_tile, to_tile) -> Array[Vector2i]`（A*/BFS on `tiles`+occupancy，可参考 H5 Easystar）；
- `StateGoTo` 缓存路径，目标 tile 前看 N 步被占/玩家移远再重寻；
- 路径每帧转目标方向，移动交给 `ATTank.move` / `move_and_slide`，用 `speed_max/acceleration` 平滑。

方案 B（更 Godot 原生）：`NavigationRegion2D` + `NavigationAgent2D`
- 静态墙烘进 navmesh；动态障碍（对象/敌人）用 `set_navigation_map` 避让较麻烦，
  建议**障碍格子在 A*/path 前做二次检查**，混用最简单。

> 推荐先 **方案 A**（与 H5 一致、可控、无需编辑期烘焙），后续需要再平滑到 B。

### 5.5 移动与开火（对齐现有 tank 骨架）

- 每帧取下一个路径点方向 → `velocity = dir * speed`，`rotate_turret(aim, delta)`（已有）平滑指向玩家；
- 开火直接调 `weapon.start_fire()/stop_fire()`（已有）；
- 出生/死亡/冰封的视觉 hook：在 ATEnemy 加 `spawn_ice/remove_ice`（复用 `sprites/game/ice.png` 或粒子）；
- 死亡：调 level 的 爆炸/烟/金币/统计（level 已预留 on_enemy_killed）。

### 5.6 Level 侧全局服务（挂在根脚本，状态/敌人只调用）

| 服务 | 说明 |
|---|---|
| `alert_sound(pos, radius)` | 广播“开火声”（枪响半径来自武器）→ 敌人 machine.on_sound_emitted |
| 冻结管理 | `freeze_enemies(duration)` 已有：全局计时 → 到点广播 `on_unfreeze` |
| `find_path / is_tile_free / occupy_tile` | 已并入 level.gd（原 tile_map 合并），供寻路与出生用 |
| `get_random_free_tile_around(x,y)` | Spawn 状态出生点（需补） |
| 敌人注册表 | 维护 `enemies`，供 alert_others/广播/结算遍历（已有数组） |

### 5.7 参数与类型表（建议落 settings.gd 或每类脚本）

```
ATEnemy 子类化：9 种 Tank + Boss + Kamikaze（覆盖 patrol），
参数：health(=基础×DIFFICULTIES×small系数)、speed_max、acceleration、turret_speed、
      sight_range、shoot_range、shoot_angle、weapon、points
Spawner：spawn_types 池/间隔/存活上限/累计上限(6)、spawner_type
```

### 5.8 建议落地顺序

- [ ] ATEnemy：缓存每帧感知数据 + `can_see_player/line_of_fire_clear/shoot`
- [ ] level：`alert_sound`、`get_random_free_tile_around`、`find_path`
- [ ] ai_machine：StateIdle/StateFollowPlayer/StateFrozen 完整逻辑（Spawn/GoToSound/GoToPlayer 随后）
- [ ] turret_enemy：改用 5.3 的两射线法；spawner：池 + Spawn 状态出生
- [ ] Kamikaze/Boss 参数与行为覆写；数值按难度表接入

---

## 六、关键源码锚点

| 内容 | H5 行号(约) | Godot 文件 |
|---|---|---|
| states 基类/StateMachine 导出 | 20538~20541 | `scripts/enemies/ai_machine.gd` |
| AI 状态定义(Idle/Frozen/Spawn/GoToSound/GoToPlayer/FollowPlayer) | 20548~20720 | 同上（状态类待补全） |
| 坦克感知/巡逻/射击（searchForPlayer/patrol/shoot） | 22184~22224 | `scripts/enemies/enemy.gd` |
| 坦克 update（缓存距离/瓦片/受伤闪/死亡） | 22225~22237 | `scripts/tank/tank.gd` + enemy.gd |
| alert/alertOthers/受击 | 22186~22194 | enemy.gd |
| 枪声警报 alertSound | ~23844 | level.gd（待补） |
| 冻结广播/解冻 | ~23832~23844 | level.gd |
| 生成器(池/进度/半血换帧/掉落) | 22301~22360 | `scripts/enemies/spawner.gd` |
| 固定炮塔 | 21772~21966 | `scripts/enemies/turret_enemy.gd` |
| 出生 AI 状态（白闪/找空格/超时） | 20589~20616 | ai_machine.gd(StateSpawn 待加) |

---

> 移植总原则：**决策（状态机）与执行（感知/移动/射击）分离**；事件用 machine 消息而不是到处轮询；
> 视线与开火各一条可独立过滤的射线；寻路结果缓存并按需重算；所有视觉反馈（冰/闪/死亡粒子）由单位与 Level 协作完成，AI 本身只关心“去哪、打不打”。
