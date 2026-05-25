# 提交清单

## 已完成

- MoonBit 主语言实现。
- 源码结构清晰。
- README 包含目标、安装、使用、示例。
- 黑盒测试可运行。
- CLI demo 可运行。
- CI 配置已提供。
- 开发报告已提供。
- 项目申报书草稿已提供。
- 赛题要求摘要已提供。

## 本地验证命令

```powershell
$env:MOON_HOME="<MoonBit 安装目录>"
$env:PATH="$env:MOON_HOME\bin;$env:PATH"
moon update
moon fmt
moon build
moon test
moon run cmd/main
moon info
```

## 参赛者提交前必须填写

- `docs/project-proposal.md` 中的联系方式。
- `moon.mod` 中的 `repository`。
- GitHub 仓库描述、Topics、许可证确认。
- GitLink 仓库同步地址。

## 线上提交步骤

1. 在 GitHub 创建公开仓库 `moonpath`。
2. GitHub 仓库地址：`https://github.com/wzx2007/moonpath`。
3. 推送代码：`git push -u origin main`。
4. 在 GitLink 创建同名仓库并从 GitHub 同步，或手动推送到 GitLink remote。
5. 按赛事群/CCF 要求提交报名信息和申报问卷。
6. 将 `docs/project-proposal.md` 导出为一页 PDF 后上传。
7. 保持真实开发记录，补足 10-20 次有效 commits。

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
- add tests
- add CLI demo
- add README
- add CI
- add contest docs

## 验收风险

- GitHub 与 GitLink 已公开；GitLink 为 GitHub 镜像仓库，需在最终提交前确认同步状态正常。
- 当前代码规模是可运行 MVP，距离赛题提到的 4-10k 有效 MoonBit 代码行数仍需要扩展功能、测试和文档示例。
