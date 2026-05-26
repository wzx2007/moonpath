# 提交清单

## 已完成

- MoonBit 主语言实现。
- 源码结构清晰。
- README 包含目标、安装、使用、示例。
- 黑盒测试可运行，当前 40 个测试全部通过。
- CLI demo 可运行。
- CI 配置已提供，并在 GitHub Actions 通过。
- 开发报告已提供。
- 最终提交说明已提供。
- 一页项目申报书 PDF 已提供。
- 赛题要求摘要已提供。
- `v0.30.1` 版本标签和 GitHub Release 已创建。

## 本地验证命令

```powershell
$env:MOON_HOME="<MoonBit 安装目录>"
$env:PATH="$env:MOON_HOME\bin;$env:PATH"
moon update
moon fmt --check
moon build
moon test
moon run cmd/main
moon run cmd/bench
moon info
```

当前验证输出：

```text
Total tests: 40, passed: 40, failed: 0.
moonpath demo: cost=14, steps=11, visited=21, open=21, components=1
moonpath bench grid: nodes=571, edges=2122, open=571, components=1, cost=48, steps=48, visited=567
moonpath bench sparse-dag: nodes=80, edges=226, layers=80, critical=79, steps=79
moonpath bench dense: nodes=36, edges=216, reachable=36, tree=35, diameter=35
moonpath bench timing: [...]
```

## 参赛者提交前必须确认

- `docs/project-proposal.md` 中的姓名、联系方式和仓库链接。
- `moon.mod` 中的 `repository`。
- GitHub 仓库描述、Topics、许可证和 `v0.30.1` Release。
- GitLink 仓库内容同步状态和 `v0.30.1` 标签。
- 一页 PDF 中的姓名、联系方式、GitHub 链接和 GitLink 链接。

## 线上提交步骤

1. GitHub 仓库地址：`https://github.com/wzx2007/moonpath`。
2. GitLink 仓库地址：`https://www.gitlink.org.cn/w1tness/moonpath`。
3. GitHub Release：`https://github.com/wzx2007/moonpath/releases/tag/v0.30.1`。
4. 按赛事群/CCF 要求提交报名信息和申报问卷。
5. 上传桌面 `MoonBit` 文件夹中的 `MoonPath_项目申报书_一页版.pdf`，并附 `docs/final-submission.md` 摘要内容。
6. 提交记录已保留真实开发过程，可作为项目持续完善证明。

## 建议提交历史

不要使用空提交。建议按真实工作拆分：

- scaffold MoonBit module
- add graph model
- add weighted edges
- add priority queue
- add Dijkstra
- add A*
- add BFS
- add grid pathfinding
- add topology/reachability helpers
- add connected component analysis
- add weighted terrain and grid-to-graph conversion
- add graph distance maps and DAG layers
- add no-corner-cutting grid pathfinding
- add DFS traversal and path existence helpers
- add all-pairs distances, eccentricity, and diameter
- add rectangular grid bulk updates
- add bidirectional Dijkstra and explicit path scoring
- add grid Dijkstra variants
- add edge-list export/rebuild and induced subgraphs
- add grid blocked/terrain export and rebuild
- add grid line-of-sight and path smoothing
- add safe graph build from external arc lists
- add dynamic graph mutation APIs
- add grid resizing
- add weighted graph summaries
- add tests
- add CLI demo
- add README
- add CI
- add contest docs

## 验收风险

- GitHub 与 GitLink 已公开并同步；最终仍需在赛事提交页面人工确认链接可访问。
- 代码、测试、文档和 Release 已完成；剩余风险主要来自赛事表单填写、附件上传和平台页面人工确认。
