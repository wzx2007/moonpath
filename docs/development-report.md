# MoonPath 开发报告

## 项目目标

MoonPath 的目标是为 MoonBit 生态补充一个可直接复用的图算法与寻路基础库。项目聚焦明确、接口小、测试可复现，适合作为游戏地图、依赖图、流程图、路由规划和可视化工具的底层组件。

## 已完成内容

- 完成 MoonBit 项目结构和模块元数据。
- 实现 `Edge[N]`、`Path[N]`、`Graph[N]`、`Point`、`Grid` 等核心类型。
- 实现加权图增删建模能力：节点、边、无向边、邻接查询、节点数和边数统计。
- 实现 BFS、Dijkstra、A*、reachable、connected_components、topological_sort。
- 实现 grid 4-neighbor 和 8-neighbor pathfinding。
- 实现 Manhattan 与 Octile 启发函数。
- 实现二叉堆优先队列作为最短路算法内部结构。
- 编写 5 个黑盒测试，覆盖最短路、BFS、拓扑排序、grid A* 和启发函数。
- 增加 CLI demo：`moon run cmd/main`。
- 增加 GitHub Actions CI：格式检查、构建、测试。
- 增加 README、变更记录、赛题要求摘要、申报书和提交清单。

## 验证结果

本地验证环境：

```text
moon 0.1.20260522
moonc v0.9.3
```

已执行：

```powershell
moon fmt
moon test
moon build
moon run cmd/main
moon info
```

结果：

```text
Total tests: 5, passed: 5, failed: 0.
moonpath demo: cost=11, steps=11, visited=21
```

## 工程质量说明

- 公共 API 集中在 `moonpath.mbt`，测试位于 `moonpath_test.mbt`。
- 算法使用非负权重约束，负权重通过 `add_edge` 入口拒绝。
- A* 与 Dijkstra 共用 `shortest_path` 内核，避免重复实现。
- Grid API 复用通用 A* 内核，降低维护成本。
- CI 覆盖格式、构建与测试流程，符合赛题验收要求。

## 已知限制

- 当前图结构以正权/零权图为目标，不支持负权最短路。
- `connected_components` 按当前边方向的可达性分组，更适合无向图通过 `add_undirected_edge` 建模后使用。
- 尚未实现 JSON 序列化和随机图性质测试。

## 后续计划

- 增加 JSON 格式导入导出。
- 增加 weighted terrain grid。
- 增加 bidirectional shortest path。
- 增加 benchmark 和随机性质测试。
- 发布到公开 MoonBit 包生态。
