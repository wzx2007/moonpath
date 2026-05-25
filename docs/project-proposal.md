# MoonPath 项目申报书

## 基本信息

项目名称：MoonPath：MoonBit 图算法与寻路工具库

参赛者：`魏泽瑄`

联系方式：`2025213290@bupt.cn / 15911070830`

GitHub 仓库链接：`https://github.com/wzx2007/moonpath`

GitLink 仓库链接：`https://www.gitlink.org.cn/w1tness/moonpath`

项目方向：基础数据结构与算法 / Graph 算法库 / Pathfinding 工具库

是否为原创项目：是。实现参考公开算法思想，不移植特定项目代码。

许可证：Apache-2.0

## 项目简介

MoonPath 面向 MoonBit 生态提供轻量、可复用、可测试的图算法与网格寻路基础库。项目服务于游戏地图、机器人/路径规划、流程编排、依赖图分析、可视化工具和编译器中间结构遍历等场景，提供统一的加权图模型、常用遍历算法、最短路算法、A* 搜索、DAG 分层分析、图摘要指标和 tile-grid 辅助能力。

MoonBit 生态仍在快速建设阶段，Graph 与 Pathfinding 属于赛题推荐方向，也是大量上层工具的公共底座。本项目采用原创 MoonBit 实现，优先保证 API 清晰、行为可复现、测试覆盖和持续集成，后续可扩展到 JSON 图格式、双向寻路、随机性质测试和性能基准。

## 核心功能范围

- 提供 `Graph[N]` 加权有向图模型，支持节点、边、无向边、邻接查询、边存在查询、入度/出度、节点数与边数统计。
- 提供 BFS 与 DFS，用于无权层次路径、深度遍历和图结构探索。
- 提供 Dijkstra、单源距离表和全点距离表，用于非负权重图最短路径与批量距离查询。
- 提供 A*，支持调用方注入启发函数。
- 提供 reachability、path existence、weakly connected components、strongly connected components、graph transpose、topological sort、topological layers、acyclic checks、eccentricity 和 diameter。
- 提供 `Grid` 和 `Point`，支持 blocked cells、terrain costs、rectangular bulk updates、4 邻接、8 邻接和禁止穿角的 8 邻接 tile-grid 寻路。
- 提供 grid-to-graph 转换，让网格地图复用通用图算法。
- 提供 Manhattan 与 Octile 启发函数。
- 提供黑盒测试、命令行示例、README、变更记录和 GitHub Actions CI。

## 交付计划

第一阶段：完成项目骨架、MoonBit 工程配置、基础图结构、测试样例和 README。

第二阶段：完成 BFS、DFS、Dijkstra、A*、网格寻路、拓扑排序、拓扑分层、单源/全点距离表、连通性分析和强/弱连通分量。

第三阶段：补充 weighted terrain、rectangular grid updates、no-corner-cutting pathfinding、grid-to-graph、文档、示例、CI、开发报告和验收清单，公开同步 GitHub 与 GitLink 仓库。

## 最终交付物

- MoonBit 源码。
- 可运行 demo。
- 黑盒测试。
- README 和 API 示例。
- GitHub Actions CI。
- 一页项目申报书 PDF、开发报告、验收清单和提交说明。

## 后续扩展

- JSON 导入导出，便于与可视化前端交换图结构。
- 双向 Dijkstra / 双向 A*。
- 随机图性质测试。
- 性能 benchmark。
- 发布到 MoonBit 包生态。
