# MoonPath Complexity Guide

This document summarizes expected complexity and practical use cases for the current MoonPath APIs.

## Graph Construction

| API | Time | Space | Notes |
| --- | --- | --- | --- |
| `Graph::add_node` | O(1) average | O(1) | Hash-map insertion. |
| `Graph::add_edge` | O(1) average | O(1) | Rejects negative costs. |
| `Graph::from_arcs` | O(E) | O(V + E) | Uses `add_edge`; invalid costs abort. |
| `Graph::try_from_arcs` | O(E) | O(V + E) | Validates costs before constructing the graph. |
| `Graph::arcs` | O(V + E) | O(E) | Exports full source-target-cost records. |
| `Graph::induced_subgraph` | O(V + E) | O(V + E) | Applies the predicate to nodes and retained edges. |

## Graph Search

| API | Time | Space | Notes |
| --- | --- | --- | --- |
| `Graph::bfs` | O(V + E) | O(V) | Best for unweighted shallow paths. |
| `Graph::dijkstra` | O((V + E) log V) | O(V) | Uses a binary heap priority queue. |
| `Graph::bidirectional_dijkstra` | O((V + E) log V) worst case | O(V) | Often reduces explored nodes when a path exists between distant endpoints. |
| `Graph::astar` | O((V + E) log V) worst case | O(V) | Faster when the heuristic is admissible and informative. |
| `Graph::bidirectional_astar` | O((V + E) log V) worst case | O(V) | Combines two-frontier search with endpoint heuristics. |
| `Graph::distances_from` | O((V + E) log V) | O(V) | Computes distances from one source to all reachable nodes. |
| `Graph::shortest_path_tree` | O((V + E) log V) | O(V) | Exports Dijkstra parent edges for reachable nodes. |
| `Graph::all_pairs_distances` | O(V * (V + E) log V) | O(V^2) worst case | Runs Dijkstra from every node. |
| `bellman_ford_path` / `bellman_ford_distances` | O(V * E) | O(V) | Supports negative arcs and returns `None` on reachable negative cycles. |
| `Graph::dag_longest_path` | O(V + E) | O(V) | Returns `None` if the graph has a cycle or the goal is unreachable. |
| `Graph::dag_paths` | O(V + E + P * L) | O(P * L) | Enumerates `P` acyclic paths of average length `L`; returns an empty array on cycles. |

## Graph Analysis

| API | Time | Space | Notes |
| --- | --- | --- | --- |
| `Graph::reachable` | O(V + E) | O(V) | Directed reachability. |
| `Graph::ancestors` / `Graph::descendants` | O(V + E) | O(V + E) | Traverses the graph or its transpose and excludes the query node. |
| `Graph::reachable_subgraph` | O(V + E) | O(V + E) | Builds a graph containing only nodes reachable from one start node. |
| `Graph::bfs_tree` | O(V + E) | O(V) | Exports first-discovery BFS tree edges from one start node. |
| `Graph::dfs_preorder` / `Graph::dfs_postorder` | O(V + E) | O(V) | Iterative DFS. |
| `Graph::sources` / `Graph::sinks` / `Graph::isolated_nodes` | O(V + E) | O(V) | Classifies nodes by incoming and outgoing degree. |
| `Graph::weakly_connected_components` | O(V + E) | O(V + E) | Builds an undirected view. |
| `Graph::strongly_connected_components` | O(V + E) | O(V + E) | Kosaraju-style two-pass DFS over the graph and its transpose. |
| `Graph::topological_sort` | O(V + E) | O(V) | Returns `None` on cycles. |
| `Graph::topological_layers` | O(V + E) | O(V) | Groups independent DAG work items. |
| `Graph::diameter` | O(V * (V + E) log V) | O(V) | Uses repeated single-source distances. |

## Grid Pathfinding

Let `N = width * height`.

| API | Time | Space | Notes |
| --- | --- | --- | --- |
| `Grid::points` | O(N) | O(N) | Enumerates every cell. |
| `Grid::open_points` | O(N) | O(N) | Filters blocked cells. |
| `Grid::set_cost` / `Grid::clear_cost` | O(1) average | O(1) | Updates one terrain override. |
| `Grid::set_cost_rect` / `Grid::clear_cost_rect` | O(W * H) | O(1) | Updates terrain overrides across a rectangle. |
| `Grid::inflated_blocks` | O(B * R^2) | O(N) | Expands `B` blocked cells by radius `R` into a copied grid. |
| `Grid::reachable_points4` / `Grid::reachable_points8` | O(N) | O(N) | Flood-fills open cells reachable from one start point. |
| `Grid::open_regions4` / `Grid::open_regions8` | O(N) | O(N) | Finds connected open-cell regions under 4-way or 8-way movement. |
| `Grid::component_count4` / `Grid::component_count8` | O(N) | O(N) | Counts open-cell connected regions. |
| `Grid::is_fully_connected4` / `Grid::is_fully_connected8` | O(N) | O(N) | True when zero or one open-cell region exists. |
| `Grid::neighbors4` / `Grid::neighbors8` | O(1) | O(1) | Checks a fixed number of candidate neighbors. |
| `Grid::astar4` / `Grid::astar8` | O(N log N) worst case | O(N) | Uses Manhattan or Octile heuristics. |
| `Grid::bidirectional_astar4` / `Grid::bidirectional_astar8` | O(N log N) worst case | O(N) | Converts to a graph, then runs bidirectional A*. |
| `Grid::dijkstra4` / `Grid::dijkstra8` | O(N log N) | O(N) | Heuristic-free shortest path. |
| `Grid::to_graph4` / `Grid::to_graph8` | O(N) | O(N) | Converts open cells to graph nodes and adjacency edges. |
| `Grid::line_of_sight` | O(max(dx, dy)) | O(1) | Integer ray traversal. |
| `Grid::smooth_path` | O(P^2 * L) worst case | O(P) | `P` is path length, `L` is max line-of-sight length. |

## Choosing an API

- Use `bfs` when every edge has the same practical cost.
- Use `dijkstra` when weights matter and there is no useful heuristic.
- Use `bidirectional_dijkstra` for point-to-point weighted graph queries where both endpoints are known.
- Use `bidirectional_astar` when the graph has a reliable endpoint heuristic and the route is point-to-point.
- Use `bellman_ford_path` or `bellman_ford_distances` when external edge lists may contain negative costs.
- Use `dag_longest_path` for critical-path analysis on acyclic dependency graphs.
- Use `astar4` or `astar8` for grid maps with a clear geometric heuristic.
- Use `dijkstra4` or `dijkstra8` when terrain costs dominate and heuristic guidance is not useful.
- Use `try_from_arcs` for external or user-provided graph data.
- Use `Graph::from_json_string`, `Graph::from_text`, `Grid::from_json_string`, or `Grid::from_text` for interchange with tools and fixtures.
- Use `inflated_blocks` before grid search when the moving agent needs clearance around blocked cells.
- Use `open_regions4` or `open_regions8` to validate that map areas are connected before running repeated path queries.
- Use `line_of_sight` and `smooth_path` after grid search when consumers prefer fewer waypoints.
