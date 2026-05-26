# MoonPath API Reference

This file is a compact index of the public API. See `README.md` for runnable examples and `docs/error-semantics.md` for failure behavior.

## Data Types

- `Edge[N]`: target node plus non-negative edge cost for graph and grid neighbor APIs.
- `Arc[N]`: source, target, and cost record for edge-list import/export.
- `Path[N]`: successful path query with `cost`, ordered `nodes`, and `visited` count.
- `Graph[N]`: mutable directed weighted graph.
- `Point`: integer grid coordinate with `x` and `y`.
- `CellCost`: terrain override for one grid point.
- `Grid`: mutable rectangular grid with blocked cells and terrain costs.

`Edge`, `Arc`, `Path`, `Point`, and `CellCost` derive JSON encode/decode support.

## Graph Construction And Mutation

- `Graph::new()`, `add_node(node)`, `add_edge(from, to, cost)`, `add_undirected_edge(a, b, cost)`.
- `remove_edge(from, to)`, `clear_edges_from(node)`, `remove_node(node)`.
- `from_arcs(arcs)`, `try_from_arcs(arcs)`, `arcs()`.
- `induced_subgraph(keep)`, `reachable_subgraph(start)`.

## Graph Inspection

- `nodes()`, `node_count()`, `edge_count()`, `neighbors(node)`.
- `contains_node(node)`, `contains_edge(from, to)`.
- `out_degree(node)`, `in_degree(node)`.
- `sources()`, `sinks()`, `isolated_nodes()`.
- `transpose()`.
- `total_edge_cost()`, `min_edge_cost()`, `max_edge_cost()`.

## Graph Search And Distances

- `bfs(start, goal)`: unweighted shortest path by edge count.
- `dijkstra(start, goal)`: non-negative shortest path.
- `bidirectional_dijkstra(start, goal)`: two-frontier Dijkstra.
- `astar(start, goal, heuristic)`: A* over graph neighbors.
- `bidirectional_astar(start, goal, heuristic)`: A* from both endpoints.
- `shortest_path(start, goal, neighbors, heuristic)`: generic pathfinding kernel.
- `path_cost(nodes)`: recompute the cheapest edge cost along an explicit node path.
- `distances_from(start)`, `shortest_distance(start, goal)`.
- `shortest_path_tree(start)`: Dijkstra parent tree as arcs.
- `all_pairs_distances()`, `eccentricity(start)`, `diameter()`.
- `bellman_ford_path(nodes, arcs, start, goal)`: shortest path over arbitrary arc costs.
- `bellman_ford_distances(nodes, arcs, start)`: one-source distances over arbitrary arc costs.

## Graph Traversal And Structure

- `reachable(start)`, `has_path(start, goal)`.
- `ancestors(node)`, `descendants(node)`.
- `bfs_tree(start)`.
- `dfs_preorder(start)`, `dfs_postorder(start)`.
- `weakly_connected_components()`, `connected_components()`.
- `strongly_connected_components()`.
- `is_weakly_connected()`, `is_strongly_connected()`.
- `topological_sort()`, `topological_layers()`, `is_acyclic()`.
- `dag_longest_path(start, goal)`, `dag_paths(start, goal)`.

## Graph Serialization

String-node graphs have stable interchange helpers:

- `Graph::to_json()`, `Graph::to_json_string()`.
- `Graph::from_json_string(text)`.
- `Graph::to_text()`, `Graph::from_text(text)`.

The text format is tab-separated and uses JSON strings for node names:

```text
# moonpath graph v1
node    "A"
arc     "A"    "B"    2
```

## Grid Construction And Editing

- `Grid::new(width, height)`.
- `Grid::from_blocked(width, height, blocked)`.
- `Grid::from_parts(width, height, blocked, terrain)`.
- `block(point)`, `unblock(point)`.
- `block_rect(top_left, width, height)`, `unblock_rect(top_left, width, height)`.
- `set_cost(point, cost)`, `set_cost_rect(top_left, width, height, cost)`.
- `clear_cost(point)`, `clear_cost_rect(top_left, width, height)`.
- `resized(width, height)`, `inflated_blocks(radius)`.

## Grid Inspection

- `contains(point)`, `is_blocked(point)`, `is_open(point)`.
- `points()`, `open_points()`, `blocked_points()`, `terrain_cells()`.
- `terrain_cost(point)`.
- `reachable_points4(start)`, `reachable_points8(start)`.
- `open_regions4()`, `open_regions8()`.
- `component_count4()`, `component_count8()`.
- `is_fully_connected4()`, `is_fully_connected8()`.

## Grid Pathfinding

- `neighbors4(point)`, `neighbors8(point)`, `neighbors8_no_corner_cutting(point)`.
- `astar4(start, goal)`, `astar8(start, goal)`.
- `bidirectional_astar4(start, goal)`, `bidirectional_astar8(start, goal)`.
- `astar8_no_corner_cutting(start, goal)`.
- `dijkstra4(start, goal)`, `dijkstra8(start, goal)`.
- `to_graph4()`, `to_graph8()`.
- `path_valid4(nodes)`, `path_valid8(nodes)`.
- `path_cost4(nodes)`, `path_cost8(nodes)`.
- `line_of_sight(a, b)`, `smooth_path(nodes)`.
- `manhattan(a, b)`, `octile(a, b)`.

## Grid Serialization

- `Grid::to_json()`, `Grid::to_json_string()`.
- `Grid::from_json_string(text)`.
- `Grid::to_text()`, `Grid::from_text(text)`.

Grid text is tab-separated:

```text
# moonpath grid v1
grid    4   3
blocked 1   0
terrain 3   1   6
```
