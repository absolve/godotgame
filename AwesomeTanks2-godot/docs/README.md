# Awesome Tanks 2 (Godot 重构) — 文档索引

> 本文档目录集中存放项目的 H5 原版分析与开发计划，方便统一查看。
> 以下三个文档均以“H5 源码 → 设计要点 → Godot 移植方式”的思路编写。

## 文档列表

| 文档 | 内容概要 |
|---|---|
| [ENEMY_AI_ANALYSIS.md](ENEMY_AI_ANALYSIS.md) | H5 敌人 AI 逻辑分析（状态机/感知/警戒链/出生/冰冻）+ Godot 移植设计（现有骨架补全方案） |
| [ORIGINAL_H5_ANALYSIS.md](ORIGINAL_H5_ANALYSIS.md) | H5 原版代码结构与各模块设计总览：资源/命名空间/存档/菜单/关卡/武器/坦克配色；**坦克炮塔、子弹弹道、数值升级** 设计及 Godot 实现方式 |
| [REMAINING_FEATURES.md](REMAINING_FEATURES.md) | 项目剩余功能清单与优先级（P0~P3），按系统模块跟踪待办 |

## 快速导航

- 想**了解原版整体怎么组织** → `ORIGINAL_H5_ANALYSIS.md`
- 想**实现敌人 AI** → 先看 `ENEMY_AI_ANALYSIS.md`
- 想知道**当前还差哪些功能/下一步做啥** → `REMAINING_FEATURES.md`
- 细读某一块（炮塔/子弹/数值/配色）→ `ORIGINAL_H5_ANALYSIS.md` 第 9、11、12、13 节

## 约定

- 文档中的 H5 源码行号为检索锚点（±几十行误差），正式移植以关键字检索源码为准；
- 建议使用支持 UTF-8 的 Markdown 阅读器（Typora / VS Code / Obsidian 等）。
