# Awesome Tanks 2（H5 原版）代码结构与模块设计分析

> 分析对象：`E:\AwesomeTanks.github.io-main\2\awesome_tanks_2.js`（约 1.7MB、单个 JS 文件）
> 配套资源：`2/images/*`（game/menu/levels 等图集 + JSON）、`2/fonts/gunplay.ttf`、`2/sounds/*.mp3`（45 个）
> 本文用途：为 Godot 重构版（`E:\godotgame\AwesomeTanks2-godot`）提供模块级还原依据；
> 行号为源 JS 的粗略锚点，便于对照检索，并非逐字引用。
> 图例：🟦 模块 ｜ 表格/列表为主要功能点 ｜ 重点分析见「九、坦克配色」。

---

## 〇、整体速览

- **引擎栈**：Phaser 2.x（封装 PIXI WebGL/Canvas）+ Box2D 物理（代码内置 `box2d` 闭包）+ Easystar 网格寻路。
- **代码组织**：整份游戏由若干 IIFE「模块闭包」按顺序拼成，靠 `window.AT.*` 命名空间互相引用，
  全局只有 `AT` 一个根命名空间。
- **运行流程**：`Site lock(防站) → Loading(加载+解码进度) → 主菜单 → Upgrades 中枢 → 进入 Level 战斗 → 结算/返回`；
  关卡数据为 15 张 ASCII 字符串地图（`AT.LEVELS`）。
- **坐标基准**：所有 UI 按 **600×600 设计坐标系** 摆放，窗口用 `min(w/600, h/600)` 等比缩放（菜单/关内一致）。

```
window.AT
├─ SETTINGS   全局数值表（难度/价格/弹药/每级参数数组…）
├─ common     通用工具（按钮/弹窗/金额/受击色/tint 闪烁/碰撞组/加权选择…）
├─ profile    存档与进度（localStorage: AWESOME-TANKS-2）
├─ audio      音频总线（BGM 3 首 / SFX 42 个、循环音、开关）
├─ states     AI 状态机 + 各状态
├─ ai         敌人决策相关（预警/视线/警报…）
├─ explosions / Fire / bonus / Lifebar / Fog…
├─ LEVELS     15 张 ASCII 关卡数据
├─ weapon     10 种武器（Minigun…Mines）+ 弹种
├─ turrets    8 种固定炮塔
├─ tanks/enemies  各类敌人坦克 + Boss + Spawner + Player（内联于 Level 侧）
├─ gui        界面组件与全部对话框（HUD 部件、BaseAlert 家族、StatsAlert…）
└─ menu       菜单状态（Lock/Loading/Title/Upgrades 等）
```

---

## 一、工程与资源组织

| 项 | 说明 |
|---|---|
| 主入口 | `2/index.html` → 加载 `awesome_tanks_2.js` |
| 角色/战场图集 | `images/game.png + game.json`（约 258+ 帧：tanks/turrets/player/spawners/particles/hud/alerts/buttons/summary…） |
| 菜单图集 | `images/menu/title|upgrades|levels|loading/*`（atlas + json） |
| 整图（无图集） | `menu/upgrades/stats.png / difficulty.png / weapons.png / performance.png / upgrade.png` 等独立图 |
| 帮助图 | `images/menu/help/*`（该仓库仅 touch 版 7 张） |
| 字体 | `Gunplay`（`fonts/gunplay.ttf`），Phaser Text 用 `font:"Gunplay"` 指定 |
| 音频 | `sounds/*.mp3` 45 个（3 BGM：menu/game/congratulations + 42 SFX） |
| 着色器 | `scripts/shaders/add_tint.frag / grayscale.frag / inverse_alpha.frag`（加载备用/特效，见第九节） |
| 设备分支 | 加载/帮助资源按 `device.touch` 选 keyboard 版或 touch 版 |

### 主要功能点（加载与启动）

- `Loading` 状态：进度条（`bar_ammo` crop 模拟）→ 解码全部音频 → 进入游戏；
- 全部 atlas 用 `atlasJSONHash` 以“键=帧名”缓存，运行时任意 `loadTexture` 换帧成本低；
- 全局默认渲染 shader 被替换为 `add_tint.frag`（配合精灵 tint 实现受击/闪烁调色）。

---

## 二、代码结构：命名空间导出索引

| 导出 | 行号(约) | 职责 |
|---|---|---|
| `AT.SETTINGS` | 20008 | 难度/武器价格/弹药上限/每级参数数组（ARMOR/SPEED/TURRET/VIEW…、各武器 rate/life/damage/spawnCount） |
| `AT.common` | 20228 | `button / closeButton / flashElement / calculateHitColor / formatMoney / formatNumber / rotate / clampVector / create2DArray / weightedChoice / debounceCalls / padTileFrame` + `TEAMS`、`COLLISION_GROUPS` |
| `AT.profile` | 20353 | 存档读写（`current` 动态代理）、统计/成就/经济、getter/setter |
| `AT.audio` | 20479 | 音乐/音效播放、循环音管理、开关与静音 |
| `AT.states` | 20538 | AI 状态机 `StateMachine` 与状态类 |
| `AT.ai` | 20713 | 敌人寻路/视线/预警逻辑挂载 |
| `AT.Lifebar` | 20745 | 敌人/炮塔头顶血条 |
| `AT.explosions` | 20941 | 爆炸特效类（Explosion 等） |
| `AT.bonus` | 21046 | 拾取物（coin/health/ammo/freeze/bomb…） |
| 障碍物/桶/箱 | 21118~21340 | bricks/wood/crate/barrel/gate 及其受击/爆炸/掉落逻辑 |
| `AT.LEVELS` | 21341 | 15 关 ASCII 地图 + 主题名 |
| `AT.weapon` | 21754 | 10 种武器 + 子弹/激光/火箭/地雷实现 |
| `AT.turrets` | 21956 | 8 种固定炮塔（Minigun/Shotgun/Cannon/Rockets/Laser/Ricochet/Railgun/Flamethrower） |
| 敌人坦克族 | ~21971~22174 | 各类型 EnemyTank + Boss（贴图/血量/射程/参数在类内定义） |
| `AT.Spawner` | 22301 | 7 种生成器（进度条+受损换图） |
| Player | 22367+ | 玩家坦克（性能档位+武器数组由 profile 驱动） |
| `AT.gui` | 22690~23142 | HUD 部件 + 全部 Alert/通知 |
| `AT.menu` | 23146+ | 各菜单状态与关卡按钮 |

> 除 `AT.gui`/`AT.menu` 外，其余多为“闭包内导出对象”，同一源的代码与数据常相邻，便于按模块移植。

---

## 三、数据与持久化：`profile` / `SETTINGS`

- **默认存档**：`achievements(9)`、`stats(8)`、`game{ sound/music/help 开关、difficulty、levels 解锁、points[15]、money、speed/turret/sight/armor、各武器 Level+Ammo }`；
- 存 `localStorage["AWESOME-TANKS-2"]`，读取时做**增量合并**（老档补新字段，不覆盖进度）；
- 统计：tanks/turrets/spawners/walls/coins/barrels/crates destroyed、moneyEarned；
- 成就：9 项计数型成就（hunter/destroyer/…），达成后发 `Achievements` 通知（奖章滑入队列展示）；
- 经济：`addMoney/spend`（收入同时累计 moneyEarned）；关卡星级=最高分 points 数组。
- Godot 对位：`game.gd`(profile) + `settings.gd`(SETTINGS)。

---

## 四、通用工具 `AT.common`

- **按钮工厂** `button/closeButton`：统一 9 态帧（normal/hover/down…）+ 播放按键音；
- **闪烁** `flashElement`：把精灵 tint 从黑渐变回白（250ms），用于金额/卡片/血条反馈；
- **受击色** `calculateHitColor`：按武器/对象返回受击染色；
- **金额** `formatMoney/formatNumber`：`$1.5m/$123k` 等压缩格式；
- **交互辅助**：`debounceCalls`（敌人搜索节流）、`weightedChoice`（掉落/生成随机）、二维数组、瓦片坐标换算工具。

---

## 五、音频 `AT.audio`

- 播放/停止一次性音效，循环音（laser/flame/shock/ricochet）引用计数式管理；
- 3 首 BGM 场景切换：`music_menu / music_game / music_congratulations`；
- `sound/music` 开关写回存档；暂停时对游戏音做静音处理。

---

## 六、菜单/界面模块（`AT.menu` + `AT.gui` 对话框族）

| 界面 | 主要功能点 |
|---|---|
| 主菜单 Title | LOGO+坦克展示、Play/About、音乐音效开关、CreditsAlert |
| Upgrades 中枢 | 顶部金钱(动画计数)、Sound/Music；双页 Tab：**Weapons**（10 武器卡：图标/等级灯/弹药条/价格、单击弹购买升级框、长按补弹）、**Performance**（armor/sight/turret/speed Gauge 卡）；底部 MENU/STATS/DIFFICULTY/PLAY；关卡进度按钮组 |
| StatsAlert | 8 行统计数字 + 生涯金币 + 9 成就奖章（悬停/点击显示说明气泡） |
| DifficultyAlert | 简单/中等/困难三选（选择即存档） |
| BuyUpgradeAlert | 未拥有=BUY；已拥有=UPGRADE+等级灯+弹药条/REFILL（长按）；价格/MINIGUN 特殊 |
| HelpAlert(Alt) | 帮助整图 + 继续按钮（首次进关 moving/weapons/mines 引导复用同一组件） |
| CreditsAlert | 鸣谢图 |
| 顶部成就通知 | 奖章从右上滑入队列轮播 |
| 关卡按钮组 | 15 关：解锁/锁定/最高分(星级)状态，点击直接进关 |

---

## 七、关卡运行（Level 状态）

- **地图**：ASCII 字符串解析为 Tile 枚举 + 逐格实例化（草/雪/沙漠地板、墙体随机 3 帧、secret 墙）；Box2D 墙圈 + frictionJoint 限制玩家；
- **进入顺序**：默认暂停 → 首次进关先播 keyboard/touch 帮助（看完才 `showFightMessage`）→ “FIGHT!” 飞入横幅 → 正式开战；已购武器但未看的武器/地雷帮助按 flag 插入同一链路；
- **输入**：WASD 移动、鼠标瞄准、左键连发、滚轮/数字 1-9/Q/E 切武器、R 布雷、P/Esc 暂停；触屏双摇杆+自动瞄准；
- **界面按钮**：菜单(放弃确认 YES/NO)、帮助(图册)、暂停(继续)、音乐/音效；
- **结算**：胜利 header_complete（4.5s 后自动继续）、失败 header_failed + CONTINUE；中间弹出收益金额；
- **过程反馈**：金币收集滑出 profit 小窗、相机震动/跟随、迷雾跟随揭开、freeze 全场结冰。

---

## 八、战斗子模块设计要点

### HUD 与战内小部件
- 底栏背景图；血瓶=empty+健康条(crop 106×p)+frame 三段图叠；10 个武器槽：图标 normal/`_active` 帧切换当前武器、右侧 7×31 弹药细条按 `ammo/maxAmmo` 缩放；Vial/Weapon/Icon/CheckboxIcon 均为独立小类复用；
- 顶部金钱→战斗内为 profit 弹出（H5 战斗中无常驻金钱显示）。

### 武器系统 `AT.weapon`（10 种，5 级参数表）
| 武器 | 主要设计 |
|---|---|
| Minigun | 无限弹药，基准参数 |
| Shotgun | 多弹丸散射（spawnCount/spread） |
| Ricochet | 按住蓄力、碰墙反弹（loop 音） |
| Flamethrower | 火焰粒子+持续燃烧（flame_loop） |
| Cannon | 高伤+溅射爆炸 |
| Shock | 闪电链多目标（shock_loop） |
| Rockets | 尾烟+跟踪目标 |
| Laser | 射线即时命中（laser_loop） |
| Railgun | 穿透型长程弹 |
| Mines | R 布雷、只伤敌、可再拾回计数 |

- 每个武器：`rate/life/damage/spawnCount` 逐级数组；弹药有限武器带 `ammo/maxAmmo`，空弹自动切回 minigun；
- 子弹分普通/激光/火箭/火焰/闪电等类，统一受击回调、命中火花与警报半径（敌人能“听见”枪声）。

### 敌人体系与 AI
- **9 类坦克**（minigun…kamikaze）+ **Boss 变体**；**8 类固定炮塔**；**7 类生成器**（进度条、受损换帧）；
- AI：巡逻(Idle) → 听到声音去调查 → 视野内追击 → 近距离循路逼近；冰冻状态、自爆类、Boss 高血量；
- 头顶 Lifebar；受击 tint 闪烁；死亡：灰色消失粒子 + 掉落物加权选择；
- 参数随**难度系数**与关卡 index 动态放大（血量/射速/移速/视距）。

### 物体、奖励与特效
- 砖墙 2 级血、木箱、**油桶连锁爆炸**、木箱掉落拾取、门(GATE)、secret 墙；
- 拾取：金币/医疗/各武器弹药/冻结/炸弹；
- 粒子：爆炸、烟、火花、冰块、木板碎片、消失、星星、金币喷射；相机震动、hole、受击闪白等。

---

## 九、坦克颜色是着色器还是直接图片？（重点分析）

### 结论

**主要是“直接图片”，颜色是美术预烘焙在各图集帧里的；运行时没有用着色器做队伍/类型换色。**
着色器/运行时 tint 只用于**瞬时受击与状态反馈**，不参与“谁是谁的颜色”。

### 证据链（对照 `awesome_tanks_2.js` 与 `game.json` 帧表）

1. **每种单位都有整套独立美术帧**（`images/game.json` 键名即可证明）：
   - 玩家：`game/player/body_0.png、body_1.png` + 每种武器的炮塔帧 `game/player/minigun.png … shock.png`（11 帧）；
   - 敌人坦克：每类一套 `game/tanks/<type>_body_0/1.png` + `<type>.png`，另有 `kamikaze` 与 7 种 `*_boss.png`（34 帧）；
   - 炮塔/生成器：`game/turrets/<type>[_base].png`、`game/spawners/<id>.png`（受损换 `_damaged.png`）。
2. **两帧 body 是履带走带动画，不是颜色变体**：
   `animations.add("move", ["…_body_0.png","…_body_1.png"], 20, true)`（坦克 L21972、玩家 L22369 同款）——在跑动时 20fps 两帧循环，色相不变。
3. **武器切换只换“炮塔图”，不重绘车体**：
   玩家 turretSprite 单独 sprite，切武器时把炮塔帧换成 `game/player/<weapon>.png`；敌人各类型自出生即固定全套（含 turret 帧 `game/tanks/<type>.png`）。
4. **Boss/大小变体也是图**：boss 独立帧；`small` 小怪直接 `scale .7`，不做换色。
5. **运行时“变色”全部是特效，且不改身份色**：
   - 受击闪：`flashElement` 把 `tint` 从黑渐变回白（`r(16777215, hit)` 公式 + tween，L20100-20115）；
   - 渲染层默认 shader 被替换成 `add_tint.frag`（配合 PIXI tint 实现调色效果，L23198 附近）；
   - 冰冻：不是改色，而是在坦克上叠一张半透明 `game/ice.png` overlay（alpha .85 + 随机旋转）；
   - `grayscale.frag / inverse_alpha.frag` 仅被预加载，未发现用于角色上色的主路径（多为死亡灰化/禁用态预留）。
6. 难度/等级只改**数值**（血量/射速/移速…），不改贴图或色相。

| 维度 | 实现方式 |
|---|---|
| 队伍/类型身份颜色（玩家绿、敌人按类型各异色、Boss 配色） | ✅ 图集直接图片 |
| 移动/受损表现（履带动画、炮塔受损） | ✅ 直接图片/换帧 |
| 受击闪光 | tint 渐变（黑→白，add_tint 默认 shader） |
| 冰冻状态 | 叠加 ice.png 覆盖图 |
| 生成器进度/受损 | 换帧（progress_0..3、*_damaged.png） |

### Godot 移植建议
- 无需为坦克做“调色板 shader”：直接沿用 `sprites/game/tanks|player/*` 帧即可；
- 受击闪烁可用 `modulate`/自写 add_tint 着色器；死亡灰化可用已备好的 `grayscale.gdshader`；
- 履带动画 = 2 帧序列播放；切武器=换炮塔贴图，与现在 player/tank 骨架一致。

---

## 十、与 Godot 重构版模块映射

| H5 模块 | Godot 对位 |
|---|---|
| `AT.SETTINGS` | `scripts/autoload/settings.gd` |
| `AT.profile` | `scripts/autoload/game.gd`（save.json，user://） |
| `AT.audio` | `scripts/autoload/audio.gd` |
| `AT.LEVELS` | `data/levels.gd` + `scripts/level/*` |
| 关卡/战斗 | `scenes/Level.tscn` + `scripts/level/level.gd`（含合并后的瓦片解析/静态墙） |
| 武器 | `scripts/weapons/*`（weapon/bullet/special_weapons/laser_beam/mine） |
| 敌人 | `scripts/enemies/*`（ai_machine/enemy/spawner/turret_enemy） |
| GUI/HUD/Alert | `scenes/hud/*` + `scripts/ui/*`（health_vial/weapon_slot/pause/abandon/help/summary） |
| 菜单/中枢 | `scenes/Title|Upgrades|LevelSelect.tscn` + `scripts/menu/*` |
| 着色器 | `shaders/*.gdshader` |

---

## 十一、坦克炮塔设计（H5 ↔ Godot）

### H5 侧设计

- **结构**：坦克本体是 Phaser.Sprite（车体 `body_0/1` 两帧履带动画），**炮塔是挂在车体上的独立子 Sprite** `turretSprite`（玩家在 `AT.Tank` 内、敌人在各自 Tank 类内各自持有）。
- **贴图/锚点**：玩家切武器 → `turretSprite.loadTexture("game.png","game/player/<weapon>.png")`；敌人每种类型自出生固定炮塔帧 `game/tanks/<type>.png`。每种炮塔图有自己的锚点/偏移（源码逐个 `anchor.set(...)`，如 minigun `(10/35,.5)`、cannon `(.4,.5)`、laser `.5,.5`、flamethrower `(24/53,.5)`）。
- **转动**：`rotate(sprite, 目标角, 转速)` 每帧平滑逼近；敌人由 AI 每帧转炮对玩家；玩家由鼠标角驱动，`turretSpeed` 为各类型参数；敌人射击还要求“炮管朝向玩家的夹角 ≤ shootAngle”。
- **后坐力（recoil）**：武器开火把 `tank.recoil` 顶到更大值；每帧炮塔沿 -rotation 反向平移 `recoil`，随后 `recoil -= 0.3` 衰减回零 —— 视觉后坐（不是物理）。
- **炮口（muzzle）**：`getTurretPosition(offset)` = 车体中心 + `(cos,sin)*offset`，弹从该点生成，offset = 武器的 `spawnDistance`（约 15~27px，各武器不同）。
- **换武器反馈**：`turretSprite.scale` 由 `.5 → 1` Elastic 弹性动画 + `weapon_change.mp3`。
- 自动瞄准（可选）：对视野内最近敌人自动转炮（`autoAimFilter` 只排除子弹）。

### Godot 实现方式（现状 + 补全点）

| 环节 | Godot 现状 | 需补全 |
|---|---|---|
| 车体/炮塔分离 | `tank.gd` 已有 `$BodySprite/$TurretSprite` 与 `rotate_turret()` | 玩家换武器时切换 `game/player/<weapon>` 贴图帧 |
| 平滑转炮 | `rotate_turret(angle, delta)`（角速度= turret_speed 度/秒） | 敌人侧由 AI 调目标角（见 ENEMY_AI_ANALYSIS） |
| 后坐力 | `tank.gd` 已实现 `_recoil` 衰减 + 炮塔 position 反推 | 武器开火（`shot` 信号）应写入 `recoil = max`，数值按武器表 |
| 炮口/生成点 | `get_turret_position(offset)` 已有；`weapon.gd._spawn_bullet` 在 `spawn_distance` 处生成 | 各武器 `spawn_distance` 按 H5 配置（15~27） |
| 换武器动画/音 | `change_weapon()` 已切换 weapon | 加 scale .5→1 弹性 Tween 与音效 |

---

## 十二、子弹/弹道设计（H5 ↔ Godot）

### H5 侧设计

**武器基类（21390）**：一个“产生子弹的池 Group”。可配置项即弹道语义：
`team/id/ammo(默认∞)/maxAmmo/damage/rate/life/spawnDistance/spawnCount/spread/velocity/frameName/bulletClass/hitColor/soundAlertRadius/onShot/onOutOfAmmo`，内部 `_fire/fireDelay` 控制连发节奏。

**各弹种设计（类内覆盖配置/行为）**

| 弹种 | 帧/类 | 关键设计 |
|---|---|---|
| 机枪子弹 | `game/projectiles/minigun.png` | 直线高速(690)，spawnCount=1 |
| 霰弹 | `shotgun.png` | spread=π/5 多弹丸（由升级 spawnCount 决定弹数） |
| 等离子/蓄力 | `plasma.png`(类内可换) | 玩家用 charge 蓄力机制（对应 ricochet 蓄力释放） |
| 加农炮 | `cannon.png` | 高速(900)单发 + 爆炸(radius/damage) |
| 追踪火箭 | bulletClass=Rocket | 锁定 `tank.follow`，尾烟、触墙/命中爆炸；命中/被杀回调 `explodeBullet`；敌方火箭被打偏可触发 dodger 成就 |
| 激光 | bulletClass=**AT.Laser** | 常驻一根光束子对象，射线命中；laser_start/loop 音频、节流重算 |
| 电枪 | bulletClass=**AT.Shock** | 目标数组链式跳跃（击中一个继续找下一个），射线检测 |
| 轨道炮 | `railgun_0.png` 射线 | 每发瞬时 raycast、life 0.15s、穿透多目标 |
| 火焰 | `flame_0.png` 流 | 低速(240)+扩散角 + 点燃 `AT.Fire`(持续灼烧 DPS、也能烧开冰) |
| 地雷 | `mine.png` | 布设式（fireDelay=∞），半径爆炸 |
| 命中处理 | — | 物理回调 → 目标 `onBulletHit(damage,…)`：扣血/受击闪/报警/（火焰）点燃/揭开迷雾；子弹火花粒子+音效 |
| 开火声音/警报 | onShot | 每种武器 `alertSound(x,y,radius)`（minigun 200/cannon 300/laser 100…） |

### Godot 实现方式（现状 + 补全点）

- `weapons/weapon.gd`(ATWeapon) 字段已对齐 H5 武器配置：`ammo/max_ammo/damage/rate/life/velocity/spread/spawn_count/spawn_distance/bullet_frame/bullet_scene/hit_color/sound_alert_radius`；`_shoot()` 在炮口生成子弹并 `bullet.setup(team, damage, velocity, life, hit_color, alert_radius)`；`shot/out_of_ammo` 信号已备。
- 各弹种建议映射到独立场景/脚本：
  | H5 弹种 | Godot |
  |---|---|
  | minigun/shotgun/cannon 直弹 | `scenes/Bullet.tscn` + `weapons/bullet.gd`（速度/方向/伤害由 setup 传入） |
  | ricochet 反弹 | 在 bullet.gd 上覆写碰墙反弹（沿用 frame） |
  | 火箭追踪 | `weapons/special_weapons.gd`（已有骨架：追踪目标 + 范围爆炸 + 尾烟） |
  | 激光 | `weapons/laser_beam.gd`（已有：射线即时命中 + laser_loop 音频） |
  | 闪电链 | 新 Shock 弹（目标查找 + 链式，参考 special 骨架） |
  | 火焰 | 粒子流 + 持续伤害（flame_loop 音已备） |
  | 轨道炮 | 穿射：一帧内按穿透数多次命中 |
  | 地雷 | `weapons/mine.gd`（已有：半径爆炸 + 链式） |
- 命中→目标侧：`ATTank.on_bullet_hit(damage, src_weapon, bullet)` 已存在（扣血/受击闪/死亡），按 H5 语义再加：点燃、报警(alert)、迷雾揭示、命中火花。
- 开火事件：由 weapon `shot` → `Audio`/`level.alert_sound`（敌人听觉输入）。

---

## 十三、数值升级设计（H5 ↔ Godot）

### H5 侧设计

**两套升级体系，互不相干：**

1. **玩家属性性能**（armor/speed/turret/sight，0~5 级，共 6 档）——静态数组按当前档索引取值（L22535）：
   `ARMOR_LEVELS=[700,1260,2100,3220,4900,6300]`
   `TURRET_LEVELS=[4,5,6,7,8,9]`
   `SPEED_LEVELS=[159.84,170.88,3.8*48,192,4.27*48,216]`（含源码表达式）
   `ACCELERATION_LEVELS=[.2,.23,.26,.3,.32,.34]`、`VIEW_ANGLE_LEVELS`、`VIEW_DISTANCE_LEVELS`
2. **武器等级**（-1 未购买 → 0~5 级）：每武器一个**长度 6 的每级参数数组**（L22513~22534 等），玩家按 `game.<key>Level` 取值：
   - minigun：射速 `[60/7,10,12,15,20,20]`、弹存活 `[8/30,10.3/30,.42,.5,.5,.5]s`、伤害 `[4,4,4,4,4,5]`（源码含“每 X 帧一发”式表达式，速率/间隔以源码为准）；
   - shotgun：弹丸数 `[4,5,6,8,9,10]`、射速/存活/单弹伤害各有数组；
   - 其余武器同理（cannon 伤害 `[457…1017]`、rockets/laser/railgun/flamethrower/shock/mines 均有对应 rate/life/damage/spawnCount 组）。

**购买/升级/弹药经济（SETTINGS 20031~20070 + 存档）**
- `PRICES[key]`：长度 6 = [购买价, 升1…升5]；UI 用 `PRICES[level+1]`，5 级显示 `MAX`；
- 购买：level -1→0 并**把弹药填满 `AMMO_LIMITS[key]`**；升级：level+1；
- 弹药：`AMMO_PRICES[key]/AMMO_AMOUNT[key]`（一次补 N 发）上限 `AMMO_LIMITS[key]`；minigun 无限弹无此 UI；
- 存档外还受 **难度系数与关卡序号缩放**的只有敌人数值（血量/射速/移速…），玩家数值与难度无关。

### Godot 实现方式（现状 + 补全点）

| 项 | Godot 现状 | 待补 |
|---|---|---|
| 性能 6 档 | `settings.gd` 的 `ARMOR/SPEED/ACCELERATION/TURRET/VIEW_*_LEVELS`（数值已与 H5 逐位一致，注释标了源行号） | — |
| 价格/弹药 | `settings.gd` 的 `PRICES / AMMO_LIMITS / AMMO_PRICES / AMMO_AMOUNT` 已按 H5 移植 | — |
| 武器每级参数 | 仅类字段有默认值 | 在 `settings.gd` 增 `WEAPON_STATS[weaponKey] = {rate[],life[],damage[],spawn_count[],velocity,spread…}`，索引=武器等级 0..5 |
| 存取/应用 | `game.gd` 的 level/ammo getter/setter + `player.gd._setup_weapons` 入口 | 读档后按表创建武器实例并填参数（含“购买时弹药填满”） |
| 升级 UI | `weapon_card/weapon_upgrade_alert` 已实现 MAX/等级灯/价格/补弹 | 购买/升级后**重建/刷新对应武器实例参数**（含弹药） |

> 索引约定（与 H5 一致）：性能数组 `[level]`；武器参数数组 `[level]`（0=初始，5=满级）；`PRICES[level+1]`=下一级花费；弹药按 `AMMO_LIMITS` 封顶。

---

## 附：主要源码锚点（快速定位用）

| 内容 | 行号（约） |
|---|---|
| AT.SETTINGS / common / profile / audio | 20008 / 20228 / 20353 / 20479 |
| 数值难度/成就/存档默认 | 20010~20350 |
| 受击 tint 闪烁公式与 tween | 20100~20115 |
| AT.states / AT.ai | 20538 / 20713 |
| Lifebar | 20745~20766 |
| AT.LEVELS（15 关 ASCII） | 21341~21356 |
| AT.weapon 导出 | 21754~21768 |
| 炮塔类（8 种） | 21776~21966 |
| 敌人坦克帧常量（body_0/1 两帧动画） | 22166~22174 |
| Spawner | 22301~22362 |
| Player（玩家坦克，性能档位数组引用） | 22367~22480+ |
| gui 部件（Vial/Weapon slot/Icon/Checkbox） | 22890~23031 |
| 对话框（BaseAlert/Pause/Abandon/Summary/Stats/Help/BuyUpgrade） | 22719~23093 |
| 战内 HUD（fight/profit/底部栏） | 23094~23142 |
| menu 状态（Lock/Loading…） | 23146~23200 |
| 价格/弹药上限表 PRICES/AMMO_* | 20031~20070 |
| 武器基类/各武器弹种配置 | 21390~21431 |
| 火箭/激光/电枪等弹道行为 | 21570~21750 |
| 敌人坦克类参数与开火（patrol/shoot/recoil） | 22184~22270 |
| 玩家每级武器参数数组（rate/life/damage…） | 22513~22534 |
| 玩家性能 6 档数组 + 自动瞄准/换枪/后坐/炮塔 | 22535~22643 |

> 说明：文中行号为手工检索锚点，可能有 ± 数十行误差；正式移植请以源码关键字检索为准。
