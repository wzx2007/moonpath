# MoonPath 项目申报书

## 基本信息

项目名称：MoonPath：MoonBit 图算法与寻路工具库

参赛者：`<填写姓名或队伍名>`

联系方式：`<填写邮箱/手机号>`

GitHub 仓库链接：`https://github.com/<your-github-id>/moonpath`

GitLink 仓库链接：`https://www.gitlink.org.cn/<your-gitlink-id>/moonpath`

项目方向：基础数据结构与算法 / Graph 算法库 / Pathfinding 工具库

是否为原创项目：是。实现参考公开算法思想，不移植特定项目代码。

许可证：Apache-2.0

## 项目简介

MoonPath 计划为 MoonBit 生态提供一个轻量、可复用、可测试的图算法与网格寻路工具库。项目面向游戏地图、机器人/路径规划、流程编排、依赖图分析、可视化工具、编译器中间结构遍历等场景，提供统一的加权图模型、常用遍历算法、最短路算法、A* 搜索和 tile-grid 辅助能力。

MoonBit 生态处于快速建设阶段，通用图算法库和 pathfinding 工具可以作为更高层应用库、游戏/仿真库、IDE/构建工具和数据可视化工具的基础组件。本项目选择小而明确的核心范围，优先保证 API 清晰、行为可复现、测试覆盖和持续集成。

## 核心功能范围

- 提供 `Graph[N]` 加权有向图模型，支持节点、边、无向边、邻接查询、节点数与边数统计。
- 提供 BFS，用于无权最短层数路径。
- 提供 Dijkstra，用于非负权重图最短路径。
- 提供 A*，支持调用方注入启发函数。
- 提供 reachability、connected components、topological sort 等基础图分析能力。
- 提供 `Grid` 和 `Point`，支持 4 邻接和 8 邻接 tile-grid 寻路。
- 提供 Manhattan 与 Octile 启发函数。
- 提供黑盒测试、命令行示例、README、变更记录和 GitHub Actions CI。

## 交付计划

第一阶段：完成项目骨架、MoonBit 工程配置、基础图结构、测试样例和 README。

第二阶段：完成 BFS、Dijkstra、A*、网格寻路、拓扑排序和连通性分析。

第三阶段：补充文档、示例、CI、开发报告和验收清单，公开同步 GitHub 与 GitLink 仓库。

## 最终交付物

- MoonBit 源码。
- 可运行 demo。
- 黑盒测试。
- README 和 API 示例。
- GitHub Actions CI。
- 项目申报书、开发报告、验收清单和提交说明。

## 后续扩展

- JSON 导入导出，便于与可视化前端交换图结构。
- Weighted Grid terrain cost。
- 双向 Dijkstra / 双向 A*。
- 随机图性质测试。
- 发布到 MoonBit 包生态。
