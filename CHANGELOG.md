# Changelog

## 0.18.0

- Added `Graph::bfs_tree` to export first-discovery traversal tree edges from a start node.
- Expanded blackbox tests from 26 to 27 cases.

## 0.17.0

- Added `Grid::inflated_blocks` to create obstacle-expanded grid copies for clearance-aware pathfinding.
- Expanded blackbox tests from 25 to 26 cases.

## 0.16.0

- Added `Grid::clear_cost` and `Grid::clear_cost_rect` for removing terrain-cost overrides from dynamic maps.
- Updated grid bulk-update examples and complexity notes.

## 0.15.0

- Added `Graph::sources`, `Graph::sinks`, and `Graph::isolated_nodes` for directed graph structure classification.
- Extended graph structure tests and documentation for the new node classification APIs.

## 0.14.0

- Added `Graph::total_edge_cost`, `Graph::min_edge_cost`, and `Graph::max_edge_cost` for weighted graph summaries.
- Expanded blackbox tests from 24 to 25 cases.

## 0.13.0

- Added `Grid::resized` to create expanded or cropped grid copies while preserving in-bounds blocked cells and terrain costs.
- Expanded blackbox tests from 23 to 24 cases.

## 0.12.0

- Added `Graph::remove_edge`, `Graph::clear_edges_from`, and `Graph::remove_node` for dynamic graph updates.
- Expanded blackbox tests from 22 to 23 cases.

## 0.11.0

- Added `Graph::try_from_arcs` for safe all-or-nothing graph construction from external edge lists.
- Expanded blackbox tests from 21 to 22 cases.

## 0.10.0

- Added `Path::node_count` and `Path::edge_count`.
- Added `Grid::path_cost4`, `Grid::path_cost8`, `Grid::path_valid4`, and `Grid::path_valid8` for validating saved or post-processed grid paths.
- Expanded existing tests to cover path metrics and grid path validation.

## 0.9.0

- Added `Grid::line_of_sight` using integer grid ray traversal.
- Added `Grid::smooth_path` to greedily remove unnecessary path waypoints when line of sight is clear.
- Expanded blackbox tests from 20 to 21 cases.

## 0.8.0

- Added `CellCost` for structured grid terrain exports.
- Added `Grid::blocked_points`, `Grid::terrain_cells`, and `Grid::from_parts` for grid export/rebuild workflows.
- Expanded blackbox tests from 19 to 20 cases.

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
