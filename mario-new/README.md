# Mario New

基于 Godot 4 引擎重新实现的超级马里奥兄弟 (SMB) 游戏。

## 🎮 项目概述

本项目是基于旧项目 [mario1](file:///f:/godotgame/mario1)（Godot 3）的 Godot 4 重制版，旨在利用新版引擎特性，同时保持原有的游戏手感和玩法体验。

## 🛠️ 技术栈

- **引擎**: Godot 4.7 (GL Compatibility)
- **语言**: GDScript
- **渲染**: Direct3D 12 (Windows)
- **物理**: Jolt Physics (3D) / 自定义 2D 碰撞检测

## 📁 项目结构

```
mario-new/
├── project.godot              # 项目配置文件
├── icon.svg                   # 项目图标
├── .editorconfig              # 编辑器配置
├── .gitignore                 # Git 忽略规则
├── DEVELOPMENT_PLAN.md        # 开发计划文档
├── default_bus_layout.tres    # 音频总线布局
├── autoload/                  # 自动加载脚本（全局单例）
│   ├── game.gd                # 游戏全局状态管理
│   └── gameType.gd            # 游戏类型和常量定义
├── font/                      # 字体资源
│   └── Fixedsys500c.ttf       # 固定宽度字体
├── scene/                     # 场景文件
│   ├── object.tscn            # 基础对象场景
│   ├── static.tscn            # 静态对象场景
│   └── welcome.tscn           # 欢迎界面场景
├── script/                    # 游戏脚本
│   ├── object.gd              # 基础对象类（CharacterBody2D）
│   └── welcome.gd             # 欢迎界面逻辑
├── sound/                     # 音效资源
│   └── blockbreak.ogg         # 砖块破坏音效
└── sprite/                    # 精灵资源
    └── active_option.png      # 选项激活图标
```

## ✅ 已完成

### 基础框架
- [x] 项目配置 (`project.godot`) - Godot 4.7，640x480 视口，GL Compatibility 渲染
- [x] 输入映射配置（p1_left, p1_right, p1_up, p1_down, p1_action, p1_jump）
- [x] Autoload 脚本配置
- [x] 音频总线布局

### 核心类
- [x] `gameType.gd` - 游戏常量和类型定义（敌人类型、物品类型、方向常量、分数列表）
- [x] `object.gd` - 基础对象类，继承自 `CharacterBody2D`，包含类型、状态、方向等属性

### 资源准备
- [x] 字体资源导入 (`Fixedsys500c.ttf`)
- [x] 音效资源导入 (`blockbreak.ogg`)
- [x] 精灵资源导入 (`active_option.png`)

### 场景结构
- [x] 基础场景创建（object.tscn, static.tscn, welcome.tscn）

## 🔄 进行中

- [ ] `game.gd` - 全局游戏状态管理（待实现）

## ❌ 未完成

### 地图系统
- [ ] 地图数据解析（JSON 加载）
- [ ] 自定义碰撞检测系统
- [ ] 图块渲染（砖块、箱子、水管、背景）
- [ ] 摄像机跟随逻辑
- [ ] 动态敌人生成
- [ ] 迷宫系统

### 玩家系统 (Mario)
- [ ] 基本移动（站立、行走、跳跃、下落）
- [ ] 大小变化（small2big、big2small）
- [ ] 火力状态（big2fire、发射火球）
- [ ] 无敌状态
- [ ] 蹲下动作
- [ ] 水下游泳
- [ ] 爬藤蔓
- [ ] 跳板弹跳
- [ ] 旗杆滑动和城堡入场
- [ ] 进出水管

### 敌人系统
- [ ] 敌人基类
- [ ] Goomba
- [ ] Koopa（壳状态、滑行、复活）
- [ ] Plant（水管植物）
- [ ] Beetle
- [ ] Bloober（水下）
- [ ] Lakitu 和 Spiny
- [ ] HammerBro
- [ ] Bowser（关底 Boss）
- [ ] 其他敌人

### 物品系统
- [ ] 物品基类
- [ ] 蘑菇（变大）
- [ ] 火焰花
- [ ] 星星（无敌）
- [ ] 1UP 蘑菇
- [ ] 金币和大金币
- [ ] 箱子内容生成

### UI 和游戏流程
- [ ] 分数显示
- [ ] 时间倒计时
- [ ] 生命和金币显示
- [ ] 暂停菜单
- [ ] 设置界面
- [ ] 关卡切换流程
- [ ] 游戏结束/通关画面

### 音效系统
- [ ] 音效管理器
- [ ] BGM 播放
- [ ] 各类 SFX

## 📝 开发计划

详细的开发计划请参考 [DEVELOPMENT_PLAN.md](file:///f:/godotgame/mario-new/DEVELOPMENT_PLAN.md)

## 🚀 运行项目

1. 使用 Godot 4.7 或更高版本打开项目
2. 运行 `welcome.tscn` 场景启动游戏

## 📜 许可证

本项目仅供学习和参考使用。