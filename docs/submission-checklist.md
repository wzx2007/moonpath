# 提交清单

## 已完成

- MoonBit 主语言实现。
- 源码结构清晰。
- README 包含目标、安装、使用、示例。
- 黑盒测试可运行，当前 22 个测试全部通过。
- CLI demo 可运行。
- CI 配置已提供，并在 GitHub Actions 通过。
- 开发报告已提供。
- 一页项目申报书 PDF 已提供。
- 赛题要求摘要已提供。

## 本地验证命令

```powershell
$env:MOON_HOME="<MoonBit 安装目录>"
$env:PATH="$env:MOON_HOME\bin;$env:PATH"
moon update
moon fmt --check
moon build
moon test
moon run cmd/main
moon info
```

当前验证输出：

```text
Total tests: 22, passed: 22, failed: 0.
moonpath demo: cost=14, steps=11, visited=21, open=21, components=1
```

## 参赛者提交前必须确认

- `docs/project-proposal.md` 中的姓名、联系方式和仓库链接。
- `moon.mod` 中的 `repository`。
- GitHub 仓库描述、Topics、许可证。
- GitLink 仓库内容同步状态。
- 一页 PDF 中的姓名、联系方式、GitHub 链接和 GitLink 链接。

## 线上提交步骤

1. GitHub 仓库地址：`https://github.com/wzx2007/moonpath`。
2. GitLink 仓库地址：`https://www.gitlink.org.cn/w1tness/moonpath`。
3. 按赛事群/CCF 要求提交报名信息和申报问卷。
4. 上传桌面 `MoonBit` 文件夹中的 `MoonPath_项目申报书_一页版.pdf`。
5. 保持真实开发记录，补足 10-20 次有效 commits。

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
- add tests
- add CLI demo
- add README
- add CI
- add contest docs

## 验收风险

- GitHub 与 GitLink 已公开；最终提交前仍需确认两侧内容同步正常。
- 当前代码规模已从最小 MVP 扩展为可用基础库，但距离赛题提到的 4-10k 有效 MoonBit 代码行数仍需继续扩展更多算法、测试和示例。
