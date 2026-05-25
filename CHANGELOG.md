# Changelog

## 0.2.0

- Added graph edge lookup, in/out degree queries, graph transpose, weakly connected components, and strongly connected components.
- Added `Point::new` and `Point::offset` helpers.
- Added grid terrain costs, point enumeration, open-cell enumeration, and grid-to-graph conversion.
- Fixed 8-neighbor grid pathfinding to use a consistent octile cost scale.
- Expanded blackbox tests from 5 to 10 cases.
- Updated the CLI demo to report open cells and component count.

## 0.1.0

- Added weighted graph model and edge APIs.
- Added BFS, Dijkstra, A*, reachability, connected components, and topological sort.
- Added rectangular grid pathfinding with Manhattan and octile heuristics.
- Added blackbox tests and runnable CLI demo.
- Added contest proposal, development report, submission checklist, and CI.
