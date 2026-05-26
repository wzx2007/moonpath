# Error Semantics

MoonPath keeps the fast path simple: invalid construction parameters abort when they would break a core invariant, while query-style APIs return `None` or an empty array when the requested result does not exist.

## Aborts

- `Graph::add_edge` and `Graph::add_undirected_edge` abort if `cost < 0`.
- `Graph::from_arcs` aborts if any arc has negative cost because it calls `add_edge`.
- `Grid::new`, `Grid::from_blocked`, `Grid::from_parts`, and `Grid::resized` abort if width or height is negative.
- Grid rectangle APIs abort if rectangle width or height is negative.
- `Grid::set_cost` and `Grid::set_cost_rect` abort if the terrain cost is less than `1`.

These checks protect invariants used by Dijkstra, A*, grid terrain costs, and graph summaries.

## Optional Results

- Path queries return `None` when the start or goal cannot produce a valid route.
- `Grid` pathfinding returns `None` when either endpoint is outside the grid or blocked.
- `Graph::try_from_arcs` returns `None` instead of aborting when an input arc is negative.
- JSON/text import helpers return `None` for parse errors, decode errors, invalid line formats, negative graph costs, negative grid dimensions, or terrain costs below `1`.
- `Graph::path_cost`, `Grid::path_cost4`, and `Grid::path_cost8` return `None` for empty paths or invalid edge steps.
- `topological_sort`, `topological_layers`, and `dag_longest_path` return `None` when a DAG-only operation sees a cycle.
- `dag_paths` returns an empty array for missing endpoints or cyclic graphs.
- `bellman_ford_path` and `bellman_ford_distances` return `None` when a reachable negative cycle makes shortest paths undefined.

## Empty Collections

- Neighbor and traversal APIs return empty arrays for missing starts or nodes with no matching output.
- Component APIs return empty arrays for empty graphs or grids with no open cells.
- `shortest_path_tree` and `bfs_tree` return empty arrays when the start node is absent.

## Negative Weights

The main `Graph[N]` type remains non-negative by design. Use `bellman_ford_path` or `bellman_ford_distances` with raw `Arc[N]` arrays when negative edge support is required.
