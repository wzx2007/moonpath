# Changelog

## 0.7.0

- Added `Arc[N]` for full source-target-cost edge records.
- Added `Graph::arcs` and `Graph::from_arcs` for edge-list export and reconstruction workflows.
- Added `Graph::induced_subgraph` for node-filtered graph analysis.
- Expanded blackbox tests from 18 to 19 cases.

## 0.6.0

- Split the implementation into focused source files for graph core operations, graph search, graph traversal, graph components, grid utilities, and shared types.
- Reduced the root `moonpath.mbt` file to a package-level entry point so the library is easier to maintain and sync across hosting platforms.

## 0.5.0

- Added `Graph::bidirectional_dijkstra` for shortest-path queries that search from both endpoints.
- Added `Graph::path_cost` to validate and score explicit node paths.
- Added `Grid::dijkstra4` and `Grid::dijkstra8` for heuristic-free grid shortest paths.
- Expanded blackbox tests from 16 to 18 cases.

## 0.4.0

- Added DFS preorder and postorder traversal helpers.
- Added `Graph::has_path`, `Graph::all_pairs_distances`, `Graph::eccentricity`, and `Graph::diameter`.
- Added weak/strong connectivity predicates for quick graph classification.
- Added rectangular bulk grid updates with `block_rect`, `unblock_rect`, and `set_cost_rect`.
- Expanded blackbox tests from 13 to 16 cases.

## 0.3.0

- Added `Graph::distances_from` and `Graph::shortest_distance` for one-source distance analysis.
- Added `Graph::topological_layers` and `Graph::is_acyclic` for dependency scheduling use cases.
- Added `Grid::neighbors8_no_corner_cutting` and `Grid::astar8_no_corner_cutting` for tile maps that disallow diagonal movement through blocked corners.
- Expanded blackbox tests from 10 to 13 cases.
- Updated docs and contest materials to reflect the expanded API surface.

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
