# MoonPath 开发报告

## 项目目标

MoonPath 的目标是为 MoonBit 生态补充一个可直接复用的图算法与寻路基础库。项目聚焦游戏地图、依赖图、流程图、路由规划、编译器中间结构遍历和可视化工具等常见场景，提供清晰、可测试、可持续扩展的 API。

## 已完成内容

- 完成 MoonBit 项目结构、模块元数据、许可证、README、CI 和命令行示例。
- 实现 `Edge[N]`、`Path[N]`、`Graph[N]`、`Point`、`Grid` 等核心类型。
- 实现加权有向图建模能力：节点、边、无向边、邻接查询、边存在查询、入度/出度、节点数和边数统计。
- 实现 BFS、DFS preorder/postorder、Dijkstra、A*、single-source distance map、all-pairs distance map、shortest-distance query、path-existence query、reachable、graph eccentricity 和 graph diameter。
- 实现 topological sort、topological layers、acyclic checks、弱连通分量、强连通分量、弱/强连通判定和图转置。
- 实现 grid 4-neighbor、8-neighbor 与 no-corner-cutting 8-neighbor pathfinding，并修正 8 邻接 A* 的 octile 成本尺度。
- 实现 grid blocked cells、terrain costs、point enumeration、open cell enumeration、rectangular bulk updates 和 grid-to-graph 转换。
- 实现二叉堆优先队列作为最短路算法内部结构。
- 编写 16 个黑盒测试，覆盖最短路、单源/全点距离、BFS、DFS、拓扑排序、拓扑分层、图结构分析、强/弱连通分量、连通判定、grid A*、terrain costs、rectangular updates、corner cutting、grid-to-graph 和启发函数。
- 增加项目申报书、验收清单、AI 协作记录和比赛需求摘要。

## 验证结果

本地验证环境：

```text
moon 0.1.20260522
moonc v0.9.3
```

已执行：

```powershell
moon fmt --check
moon test
moon build
moon run cmd/main
moon info
```

结果：

```text
Total tests: 16, passed: 16, failed: 0.
moonpath demo: cost=14, steps=11, visited=21, open=21, components=1
```

## 工程质量说明

- 公共 API 集中在 `moonpath.mbt`，黑盒测试位于 `moonpath_test.mbt`。
- 图最短路使用非负权重约束，负权重通过 `add_edge` 入口拒绝。
- A* 与 Dijkstra 共用 `shortest_path` 内核，避免重复实现。
- Grid API 复用通用 A* 内核，并可转换为 `Graph[Point]` 继续使用图算法。
- CI 覆盖格式检查、构建和测试流程，符合公开仓库和持续集成要求。

## 已知限制

- 当前不支持负权最短路；如需支持可补充 Bellman-Ford 并调整权重约束。
- 当前 JSON 导入导出尚未实现。
- 随机性质测试和性能基准尚未加入。

## 后续计划

- 增加 JSON 格式导入导出。
- 增加 bidirectional Dijkstra / bidirectional A*。
- 增加随机图性质测试和基础 benchmark。
- 扩展示例，覆盖游戏地图、依赖分析和流程编排场景。
