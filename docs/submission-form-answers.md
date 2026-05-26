# MoonPath 报名表可粘贴内容

## 项目名称

MoonPath：MoonBit 图算法与寻路工具库

## 项目方向

基础数据结构与算法 / Graph 算法库 / Pathfinding 工具库

## 参赛者信息

- 参赛者：魏泽瑄
- 联系方式：2025213290@bupt.cn / 15911070830

## 仓库链接

- GitLink：https://www.gitlink.org.cn/w1tness/moonpath
- GitHub：https://github.com/wzx2007/moonpath
- Release：https://github.com/wzx2007/moonpath/releases/tag/v0.30.1

## 项目简介

MoonPath 是一个面向 MoonBit 生态的图算法与 tile-grid 寻路基础库，覆盖加权有向图建模、图遍历、最短路、A*、双向搜索、DAG 分析、连通性分析、网格寻路、障碍/terrain 管理、JSON/text 导入导出和 benchmark。项目已经从参赛 MVP 扩展为可复用基础库，具备源码、测试、文档、CI、Release 和 GitHub/GitLink 双平台同步。

## 创新点与价值

- 为 MoonBit 生态补充可直接复用的 Graph 与 Pathfinding 基础库。
- 同时覆盖通用图和 tile-grid 场景，便于游戏地图、依赖图、流程编排、路径规划和可视化工具复用。
- 保持非负权图核心 API 的清晰语义，同时通过 Bellman-Ford 支持负权边工作流。
- 提供 JSON/text 导入导出，方便与地图编辑器、可视化前端、评测脚本和外部数据交换。
- 提供 benchmark timing、生成式性质测试、错误语义文档和 CI，突出工程完整性。

## 已实现功能

- `Graph[N]` 加权有向图建模、动态增删、边权摘要、边列表导出/重建、诱导子图和可达子图。
- BFS、DFS、Dijkstra、bidirectional Dijkstra、A*、bidirectional A*、Bellman-Ford。
- DAG topological sort/layers、DAG longest path、DAG path enumeration。
- 单源距离、全点距离、shortest path tree、eccentricity、diameter。
- weak/strong connected components、连通性判定、ancestors/descendants。
- `Grid` blocked cells、terrain costs、矩形批量操作、grid resizing、obstacle inflation。
- 4/8 邻接寻路、禁止穿角寻路、line-of-sight、path smoothing、grid-to-graph。
- `Graph[String]` 和 `Grid` 的 JSON/text 导入导出。
- CLI demo、benchmark、40 个黑盒测试、GitHub Actions CI。

## 验证结果

```text
Total tests: 40, passed: 40, failed: 0.
moonpath demo: cost=14, steps=11, visited=21, open=21, components=1
moonpath bench grid: nodes=571, edges=2122, open=571, components=1, cost=48, steps=48, visited=567
moonpath bench sparse-dag: nodes=80, edges=226, layers=80, critical=79, steps=79
moonpath bench dense: nodes=36, edges=216, reachable=36, tree=35, diameter=35
moonpath bench timing: [...]
```

## 附件建议

- 一页 PDF：`MoonPath_项目申报书_一页版.pdf`
- 最终成果说明：`docs/final-submission.md`
- 开发报告：`docs/development-report.md`
- API 文档：`docs/api.md`
