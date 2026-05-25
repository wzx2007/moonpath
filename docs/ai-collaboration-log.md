# AI 协作记录

## 协作方式

本项目由 Codex 辅助完成赛题解析、项目选题、MoonBit 工程搭建、核心算法实现、测试编写、文档整理、本地验证、GitHub/GitLink 仓库创建和一页 PDF 申报材料生成。

## 主要决策

- 选择 Graph / Pathfinding 工具库方向，匹配赛题推荐清单。
- 采用原创实现，不复制或移植特定开源项目代码。
- 优先实现小而完整的核心 API，确保可构建、可测试、可演示。
- 使用 `shortest_path` 复用 Dijkstra 与 A* 内核。
- 扩展 DFS、bidirectional Dijkstra、path scoring、path existence、weak/strong connected components、graph transpose、single-source distance map、all-pairs distance map、eccentricity、diameter、topological layers、terrain costs、grid Dijkstra、rectangular grid updates、no-corner-cutting pathfinding 和 grid-to-graph，让项目更接近可复用基础库。
- 将必须由参赛者本人完成的账号、报名和 PDF 提交动作单独列入清单。

## 验证

已用 MoonBit 官方 Windows 工具链和本地标准库执行：

```text
moon fmt --check
moon test
moon build
moon run cmd/main
moon info
```

测试结果：18 passed, 0 failed。
