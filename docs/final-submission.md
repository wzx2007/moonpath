# MoonPath 参赛成果提交说明

## 基本信息

- 项目名称：MoonPath：MoonBit 图算法与寻路工具库
- 参赛者：魏泽瑄
- 联系方式：2025213290@bupt.cn / 15911070830
- GitHub：https://github.com/wzx2007/moonpath
- GitLink：https://www.gitlink.org.cn/w1tness/moonpath
- 版本：v0.30.0
- Release：https://github.com/wzx2007/moonpath/releases/tag/v0.30.0
- 许可证：Apache-2.0

## 成果概述

MoonPath 是一个面向 MoonBit 生态的图算法与 tile-grid 寻路基础库，覆盖加权有向图建模、图遍历、最短路、A*、双向搜索、DAG 分析、连通性分析、网格寻路、障碍/terrain 管理、JSON/text 导入导出和 benchmark。项目已经从参赛 MVP 扩展为可复用基础库，具备源码、测试、文档、CI、Release 和双平台同步。

## 核心交付物

- MoonBit 源码：`graph_core.mbt`、`graph_search.mbt`、`graph_traversal.mbt`、`graph_components.mbt`、`grid.mbt`、`serialization.mbt`。
- 公共 API 文档：`docs/api.md`。
- 错误语义说明：`docs/error-semantics.md`。
- 复杂度和 API 选型：`docs/complexity.md`。
- 开发报告：`docs/development-report.md`。
- 提交清单：`docs/submission-checklist.md`。
- 一页项目申报书 PDF：`docs/MoonPath_项目申报书_一页版.pdf`。
- Demo：`cmd/main`。
- Benchmark：`cmd/bench`。
- CI：`.github/workflows/ci.yml`。

## 功能完成情况

| 类别 | 状态 |
| --- | --- |
| JSON/text 导入导出 | 已完成，支持 `Graph[String]` 和 `Grid` |
| 正式 benchmark | 已完成，输出 deterministic summary 和 `moonbitlang/core/bench` timing JSON |
| 生成式性质测试 | 已完成，覆盖 DAG、Grid、transpose、to_graph4、shortest path tree、DAG longest path |
| Bidirectional A* | 已完成，提供 Graph 和 Grid API |
| API 文档 | 已完成，见 `docs/api.md` |
| 错误语义统一 | 已完成，见 `docs/error-semantics.md` |
| Bellman-Ford / 负权支持 | 已完成，提供独立 `bellman_ford_path` / `bellman_ford_distances` |
| 发布准备 | 已完成，版本 `0.30.0`、tag、GitHub Release、Topics、GitLink 同步均已处理 |

## 验证结果

本地最终验证命令：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\verify-moonpath.ps1
cd .\moonpath
moon info
```

验证结果摘要：

```text
Total tests: 40, passed: 40, failed: 0.
moonpath demo: cost=14, steps=11, visited=21, open=21, components=1
moonpath bench grid: nodes=571, edges=2122, open=571, components=1, cost=48, steps=48, visited=567
moonpath bench sparse-dag: nodes=80, edges=226, layers=80, critical=79, steps=79
moonpath bench dense: nodes=36, edges=216, reachable=36, tree=35, diameter=35
moonpath bench timing: [...]
```

GitHub Actions 最新验证已通过。GitHub 与 GitLink 内容已同步，桌面 `MoonBit` 成果目录已同步。

## 提交建议

在赛事表单中优先提交 GitLink 仓库链接，同时附上 GitHub 链接和 Release 链接。附件使用一页 PDF 申报书；项目说明可摘录本文件“成果概述”和“功能完成情况”。
