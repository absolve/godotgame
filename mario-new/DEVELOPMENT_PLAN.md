# Mario New (Godot 4) 开发计划

## 项目概述

基于旧项目 mario1 (Godot 3) 重新实现的 SMB 游戏，使用 Godot 4 引擎。本计划详细规划了迁移和开发的各个阶段、功能模块及技术决策。

---

## 一、旧项目功能模块分析

### 1.1 核心系统

| 模块 | 文件 | 功能描述 |
|------|------|----------|
| 游戏状态管理 | `game.gd` | 全局游戏数据（分数、金币、生命）、信号系统、配置管理 |
| 常量定义 | `constants.gd` | 游戏状态、实体类型、物理参数、图块属性定义 |
| 自定义碰撞检测 | `mapNew.gd` | Rect2 相交检测、左右上下碰撞处理 |

### 1.2 玩家系统 (Mario)

| 状态 | 说明 |
|------|------|
| stand/walk | 站立/行走 |
| jump/fall | 跳跃/下落 |
| crouch | 蹲下（大马里奥） |
| poleSliding | 旗杆滑动 |
| walkingToCastle | 走向城堡 |
| small2big/big2small | 大小变化 |
| big2fire | 获得火力 |
| grabVine/autoGrabVine | 爬藤蔓 |
| swim | 水下游泳 |
| onBoard | 跳板弹跳 |
| pipeIn/pipeOut | 进出水管 |

### 1.3 地图系统

- **关卡数据**：JSON 格式存储，包含地图尺寸、背景类型、音乐、马里奥位置、图块数据
- **图块类型**：brick（砖块）、box（箱子）、pipe（水管）、bg（背景）、collision（碰撞体）
- **动态加载**：敌人和特殊对象根据摄像机位置动态生成
- **迷宫系统**：可扩展的迷宫区域，支持分段加载

### 1.4 敌人系统

| 敌人类型 | 特性 |
|----------|------|
| Goomba | 基础敌人，左右行走 |
| Koopa | 壳状态、滑行、复活 |
| Plant | 水管中弹出 |
| Beetle | 甲壳虫敌人 |
| Bloober | 乌贼，水下敌人 |
| Lakitu | 天上云朵，扔 Spiny |
| HammerBro | 投掷锤子 |
| Bowser | 关底 Boss |
| CheapCheap | 飞鸟 |
| Podoboo | 火焰喷射 |
| BulletBill | 炮弹 |
| FlyingFish | 飞鱼 |

### 1.5 物品系统

| 物品 | 效果 |
|------|------|
| Mushroom | 变大 |
| Fireflower | 获得火力 |
| Star | 无敌 |
| Mushroom1up | 加一条命 |
| Coin | 加金币 |
| BigCoin | 大金币 |

### 1.6 UI系统

- 分数显示 (`score.tscn`)
- 时间倒计时 (`title.tscn`)
- 生命/金币显示
- 暂停菜单 (`pauseLayer.tscn`)
- 设置界面 (`setting.tscn`, `mainSetting.tscn`)

### 1.7 音效系统

- BGM：overworld、underground、castle、star 等
- SFX：跳跃、金币、踩敌人、砖块撞击等

---

## 二、Godot 3 → Godot 4 迁移注意事项

### 2.1 API 变更

| Godot 3 | Godot 4 |
|----------|----------|
| `KinematicBody2D` | `CharacterBody2D` |
| `move_and_slide()` | `move_and_slide()` (参数变化) |
| `set_process_input()` | 直接重写 `_input()` |
| `set_physics_process()` | 直接重写 `_physics_process()` |
| `yield()` | `await` |
| `File` | `FileAccess` |
| `OS.get_system_time_msecs()` | `Time.get_ticks_msec()` |
| `ConfigFile` | `ConfigFile` (API 基本不变) |
| `VisualServer.set_default_clear_color()` | `RenderingServer.set_default_clear_color()` |
| `InputEventKey.scancode` | `InputEventKey.keycode` |

### 2.2 输入系统

- 输入映射配置方式变化，需重新配置 `project.godot` 中的 `[input]` 部分
- `InputMap` API 基本保持一致

### 2.3 动画系统

- AnimationPlayer 使用方式基本不变
- 动画信号 `animation_finished`、`frame_changed` 保持一致

### 2.4 碰撞系统架构决策

**方案 A：保留自定义 Rect2 碰撞系统（推荐）**

- 优势：与原项目行为完全一致，物理响应精确可控
- 实施：复用 mapNew.gd 的碰撞检测逻辑，适配 Godot 4 API

**方案 B：使用 Godot 4 内置物理引擎**

- 优势：利用引擎原生特性，可能更高效
- 风险：需要重新调整碰撞体和物理参数，行为可能不一致

**决策**：采用方案 A，保留自定义碰撞系统，确保游戏手感与原项目一致。

---

## 三、开发阶段规划

### Phase 1: 基础框架搭建

**目标**：创建项目结构，配置基础设置，建立核心基础设施

| 任务 | 描述 | 优先级 |
|------|------|--------|
| P1-01 | 创建 Godot 4 项目配置 (`project.godot`) | 高 |
| P1-02 | 设置输入映射（方向键、跳跃、动作） | 高 |
| P1-03 | 创建 Autoload 脚本：Game、Constants、SoundsUtil | 高 |
| P1-04 | 配置渲染设置（像素完美、拉伸模式） | 中 |
| P1-05 | 复制资源文件（图标、音效、字体） | 中 |

### Phase 2: 核心基础类

**目标**：实现游戏的基础类和工具类

| 任务 | 描述 | 优先级 |
|------|------|--------|
| P2-01 | 实现 `Object.gd` 基类（位置、速度、碰撞矩形） | 高 |
| P2-02 | 实现 `Constants.gd` 常量定义 | 高 |
| P2-03 | 实现 `Game.gd` 全局状态管理 | 高 |
| P2-04 | 实现 `SoundsUtil.gd` 音效管理 | 中 |

### Phase 3: 地图系统

**目标**：实现地图加载、渲染和碰撞检测

| 任务 | 描述 | 优先级 |
|------|------|--------|
| P3-01 | 实现地图数据解析（JSON 加载） | 高 |
| P3-02 | 实现自定义碰撞检测系统（Rect2 相交） | 高 |
| P3-03 | 实现图块渲染（brick、box、pipe、bg） | 高 |
| P3-04 | 实现摄像机跟随逻辑 | 高 |
| P3-05 | 实现动态敌人生成 | 中 |
| P3-06 | 实现迷宫系统 | 低 |

### Phase 4: 玩家系统 (Mario)

**目标**：实现马里奥的完整控制逻辑和状态机

| 任务 | 描述 | 优先级 |
|------|------|--------|
| P4-01 | 实现基本移动（站立、行走、跳跃、下落） | 高 |
| P4-02 | 实现大小变化（small2big、big2small） | 高 |
| P4-03 | 实现火力状态（big2fire、发射火球） | 高 |
| P4-04 | 实现无敌状态 | 中 |
| P4-05 | 实现蹲下动作 | 中 |
| P4-06 | 实现水下游泳 | 中 |
| P4-07 | 实现爬藤蔓 | 低 |
| P4-08 | 实现跳板弹跳 | 低 |
| P4-09 | 实现旗杆滑动和城堡入场 | 低 |
| P4-10 | 实现进出水管 | 低 |

### Phase 5: 敌人系统

**目标**：实现各类敌人的 AI 行为

| 任务 | 描述 | 优先级 |
|------|------|--------|
| P5-01 | 实现基础敌人基类 (`Enemy.gd`) | 高 |
| P5-02 | 实现 Goomba | 高 |
| P5-03 | 实现 Koopa（含壳状态、滑行、复活） | 高 |
| P5-04 | 实现 Plant（水管植物） | 中 |
| P5-05 | 实现 Beetle | 中 |
| P5-06 | 实现 Bloober（水下） | 中 |
| P5-07 | 实现 Lakitu 和 Spiny | 低 |
| P5-08 | 实现 HammerBro | 低 |
| P5-09 | 实现 Bowser（关底 Boss） | 低 |
| P5-10 | 实现其他敌人（CheapCheap、Podoboo、BulletBill） | 低 |

### Phase 6: 物品系统

**目标**：实现各类物品及其效果

| 任务 | 描述 | 优先级 |
|------|------|--------|
| P6-01 | 实现物品基类 | 高 |
| P6-02 | 实现蘑菇（变大） | 高 |
| P6-03 | 实现火焰花 | 高 |
| P6-04 | 实现星星（无敌） | 高 |
| P6-05 | 实现 1UP 蘑菇 | 中 |
| P6-06 | 实现金币和大金币 | 中 |
| P6-07 | 实现箱子内容生成 | 高 |

### Phase 7: UI 和游戏流程

**目标**：实现游戏界面和流程控制

| 任务 | 描述 | 优先级 |
|------|------|--------|
| P7-01 | 实现分数显示 | 高 |
| P7-02 | 实现时间倒计时 | 高 |
| P7-03 | 实现生命和金币显示 | 高 |
| P7-04 | 实现暂停菜单 | 中 |
| P7-05 | 实现设置界面 | 中 |
| P7-06 | 实现关卡切换流程 | 高 |
| P7-07 | 实现游戏结束/通关画面 | 中 |

### Phase 8: 测试和优化

**目标**：测试各功能模块，修复 Bug，优化性能

| 任务 | 描述 | 优先级 |
|------|------|--------|
| P8-01 | 测试基础移动和碰撞 | 高 |
| P8-02 | 测试敌人行为 | 高 |
| P8-03 | 测试物品效果 | 高 |
| P8-04 | 测试关卡切换 | 中 |
| P8-05 | 性能优化（对象池、渲染优化） | 中 |
| P8-06 | 音效测试和调整 | 低 |

---

## 四、目录结构规划

```
mario_new/
├── project.godot              # 项目配置
├── icon.png                   # 图标
├── fonts/                     # 字体资源
├── icon/                      # 图块图标
├── sprites/                   # 精灵资源
├── sounds/                    # 音效资源
├── levels/                    # 关卡数据
│   ├── 1-1.json
│   ├── 1-2.json
│   └── ...
├── scenes/                    # 场景文件
│   ├── mario.tscn
│   ├── goomba.tscn
│   ├── koopa.tscn
│   ├── brick.tscn
│   ├── box.tscn
│   ├── pipe.tscn
│   ├── bg.tscn
│   ├── map.tscn
│   ├── score.tscn
│   ├── pause_layer.tscn
│   └── ...
└── scripts/                   # 脚本文件
    ├── constants.gd           # 常量定义
    ├── game.gd               # 全局游戏状态
    ├── object.gd             # 基础对象类
    ├── mario.gd              # 马里奥逻辑
    ├── enemy.gd              # 敌人基类
    ├── goomba.gd             # Goomba
    ├── koopa.gd              # Koopa
    ├── map.gd                # 地图系统
    ├── brick.gd              # 砖块
    ├── box.gd                # 箱子
    ├── item.gd               # 物品基类
    ├── mushroom.gd           # 蘑菇
    ├── fireflower.gd         # 火焰花
    ├── sounds_util.gd        # 音效管理
    └── ...
```

---

## 五、关键技术实现要点

### 5.1 碰撞检测系统

保留原项目的自定义 Rect2 碰撞检测方案：

1. 使用 `Rect2.intersects()` 判断碰撞
2. 分离 X/Y 轴碰撞检测，分别处理左右和上下碰撞
3. 通过 `leftCollide()`、`rightCollide()`、`floorCollide()`、`ceilcollide()` 方法处理不同方向的碰撞响应
4. 优化：只检测屏幕范围内的对象，减少计算量

### 5.2 状态机模式

采用状态机模式管理马里奥和敌人的行为：

- 使用枚举常量定义状态
- 在 `_physics_process()` 中根据当前状态调用对应处理方法
- 状态切换通过条件判断触发

### 5.3 动态资源加载

- 图块图标在游戏启动时通过 `Constants.loadIcon()` 动态加载
- 关卡数据通过 JSON 文件异步加载
- 敌人和特殊对象根据摄像机位置动态生成和销毁

### 5.4 对象池优化

为频繁创建和销毁的对象（如火焰球、气泡、砖块碎片）实现对象池，减少内存分配开销。

---

## 六、开发建议

1. **从简单到复杂**：先实现基础移动和碰撞，再逐步添加复杂功能
2. **测试驱动**：每个模块完成后立即测试，确保行为符合预期
3. **保持一致性**：尽量保持与原项目相同的物理参数和游戏手感
4. **代码复用**：对于逻辑相同的部分，提取基类或工具函数
5. **文档注释**：关键逻辑添加必要注释，便于后续维护

---

## 七、里程碑

| 里程碑 | 完成条件 | 预计时间 |
|--------|----------|----------|
| M1 | 项目框架搭建完成，可运行空场景 | 1周 |
| M2 | 地图系统和基础碰撞完成，马里奥可移动 | 2周 |
| M3 | 敌人系统完成，包含 Goomba 和 Koopa | 2周 |
| M4 | 物品系统和关卡流程完成 | 2周 |
| M5 | UI 和音效系统完成 | 1周 |
| M6 | 所有功能测试通过，项目发布 | 1周 |

---

## 八、风险评估

| 风险 | 影响 | 应对策略 |
|------|------|----------|
| 碰撞系统迁移复杂 | 高 | 保留原有的自定义碰撞逻辑，逐步适配 |
| 物理参数需要重新调整 | 中 | 复用原项目参数，微调优化 |
| 音效系统 API 变化 | 低 | 使用 Godot 4 的 AudioStreamPlayer |
| 关卡数据格式兼容性 | 低 | 原 JSON 格式可直接使用 |

---

## 九、参考资料

- [Godot 4 官方文档](https://docs.godotengine.org/en/stable/)
- [Godot 3 → 4 迁移指南](https://docs.godotengine.org/en/stable/tutorials/migration/migration_3_to_4.html)
- 旧项目代码：`f:\godotgame\mario1\`