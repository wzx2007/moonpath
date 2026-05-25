# MoonPath

MoonPath is a MoonBit graph algorithms and pathfinding library. It targets reusable infrastructure for MoonBit ecosystem projects: game maps, routing tools, compiler passes, dependency planning, workflow engines, visualization tools, and any code that needs graph traversal.

This repository is prepared for the `MoonBit 开源生态项目贡献赛` track. The current implementation includes a usable core, tests, a runnable demo, CI configuration, and contest submission materials under `docs/`.

## Features

- Directed weighted graph with explicit nodes and edges.
- Edge-list export and reconstruction with `Arc[N]`, plus node-filtered induced subgraphs.
- Safe all-or-nothing graph construction from external edge lists with `try_from_arcs`.
- BFS and DFS traversal helpers for directed graphs.
- Dijkstra and bidirectional Dijkstra shortest paths for non-negative weighted graphs, plus explicit path scoring, one-source distance maps, and all-pairs distance maps.
- Path result helpers for node and edge counts.
- A* search with custom heuristic functions.
- Reachability, path existence, weak/strong connected components, connectivity predicates, graph transpose, degree queries, graph eccentricity/diameter, topological sort, acyclicity checks, and topological layers.
- Rectangular grid helpers with blocked cells, terrain costs, rectangular bulk updates, 4-neighbor, 8-neighbor, no-corner-cutting 8-neighbor pathfinding, and heuristic-free Dijkstra variants.
- Grid export/rebuild helpers for blocked cells and terrain overrides.
- Grid line-of-sight checks and greedy path smoothing for reducing unnecessary waypoints.
- Grid path validation and path cost recomputation for 4-neighbor and 8-neighbor paths.
- Grid-to-graph conversion for users who want to reuse graph algorithms on tile maps.
- Blackbox tests covering graph search, cycle detection, graph structure, DAG layers, DFS, all-pairs distances, connectivity, grid routing, terrain costs, corner cutting, and heuristic determinism.

## Install

Install MoonBit from the official site, then run:

```powershell
moon update
moon build
moon test
```

This repository was verified with:

```text
moon 0.1.20260522
moonc v0.9.3
```

## Usage

```moonbit
test "dijkstra demo" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 4)
  graph.add_edge("A", "C", 1)
  graph.add_edge("C", "B", 2)
  graph.add_edge("B", "D", 1)
  guard graph.bidirectional_dijkstra("A", "D") is Some(path) else {
    fail("expected a path")
  }
  assert_eq(path.cost, 4)
  assert_true(path.nodes == ["A", "C", "B", "D"])
  assert_true(graph.path_cost(path.nodes) == Some(4))
}
```

Grid pathfinding:

```moonbit
test "grid demo" {
  let grid = @moonpath.Grid::from_blocked(
    5,
    4,
    [@moonpath.Point::{ x: 1, y: 0 }, @moonpath.Point::{ x: 1, y: 1 }],
  )
  let start = @moonpath.Point::{ x: 0, y: 0 }
  let goal = @moonpath.Point::{ x: 4, y: 0 }
  assert_true(grid.astar4(start, goal) is Some(_))
}
```

Weighted terrain and 8-direction pathfinding:

```moonbit
test "weighted grid demo" {
  let grid = @moonpath.Grid::new(3, 3)
  let rough = @moonpath.Point::new(1, 0)
  grid.set_cost(rough, 5)
  guard grid.dijkstra8(@moonpath.Point::new(0, 0), @moonpath.Point::new(2, 2)) is Some(path) else {
    fail("expected a path")
  }
  assert_eq(path.cost, 28)
}
```

Graph analysis:

```moonbit
test "component demo" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 1)
  graph.add_edge("B", "A", 1)
  graph.add_edge("B", "C", 1)
  assert_eq(graph.weakly_connected_components().length(), 1)
  assert_eq(graph.strongly_connected_components().length(), 2)
}
```

Distance maps and DAG layers:

```moonbit
test "analysis demo" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("parse", "compile", 2)
  graph.add_edge("parse", "lint", 1)
  graph.add_edge("compile", "package", 3)
  let distances = graph.distances_from("parse")
  assert_eq(distances.get_or_default("package", -1), 5)
  assert_true(graph.topological_layers() is Some(_))
}
```

All-pairs distances and graph summary:

```moonbit
test "summary demo" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 2)
  graph.add_edge("B", "C", 3)
  let all = graph.all_pairs_distances()
  guard all.get("A") is Some(from_a) else { fail("missing A") }
  assert_eq(from_a.get_or_default("C", -1), 5)
  assert_true(graph.has_path("A", "C"))
  assert_true(graph.diameter() == Some(5))
}
```

Edge-list workflows:

```moonbit
test "edge list demo" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 2)
  graph.add_edge("B", "C", 3)
  let rebuilt = @moonpath.Graph::from_arcs(graph.arcs())
  assert_true(rebuilt.path_cost(["A", "B", "C"]) == Some(5))
  let subgraph = graph.induced_subgraph(node => node != "C")
  assert_true(!subgraph.contains_node("C"))
}
```

Safe graph construction:

```moonbit
test "safe build demo" {
  let arcs = [
    @moonpath.Arc::{ from: "A", to: "B", cost: 2 },
    @moonpath.Arc::{ from: "B", to: "C", cost: 3 },
  ]
  assert_true(@moonpath.Graph::try_from_arcs(arcs) is Some(_))
}
```

Bulk grid updates:

```moonbit
test "bulk grid demo" {
  let grid = @moonpath.Grid::new(5, 4)
  grid.block_rect(@moonpath.Point::new(1, 1), 3, 2)
  grid.unblock_rect(@moonpath.Point::new(2, 1), 1, 2)
  grid.set_cost_rect(@moonpath.Point::new(0, 0), 2, 2, 4)
  let rebuilt = @moonpath.Grid::from_parts(
    5,
    4,
    grid.blocked_points(),
    grid.terrain_cells(),
  )
  assert_true(rebuilt.terrain_cost(@moonpath.Point::new(1, 1)) == Some(4))
}
```

Path smoothing:

```moonbit
test "smooth path demo" {
  let grid = @moonpath.Grid::new(5, 5)
  let start = @moonpath.Point::new(0, 0)
  let goal = @moonpath.Point::new(4, 4)
  let jagged = [start, @moonpath.Point::new(1, 0), @moonpath.Point::new(4, 3), goal]
  assert_true(grid.line_of_sight(start, goal))
  assert_true(grid.smooth_path(jagged) == [start, goal])
}
```

Path validation:

```moonbit
test "grid path validation demo" {
  let grid = @moonpath.Grid::new(3, 3)
  guard grid.dijkstra4(@moonpath.Point::new(0, 0), @moonpath.Point::new(2, 2))
    is Some(path) else {
    fail("expected a path")
  }
  assert_eq(path.edge_count(), path.nodes.length() - 1)
  assert_true(grid.path_valid4(path.nodes))
  assert_true(grid.path_cost4(path.nodes) == Some(path.cost))
}
```

Run the CLI demo:

```powershell
moon run cmd/main
```

Expected output:

```text
moonpath demo: cost=14, steps=11, visited=21, open=21, components=1
```

## Repository Layout

- `types.mbt`: public data types.
- `graph_core.mbt`: graph construction, edge queries, degree queries, and transpose.
- `graph_search.mbt`: BFS, Dijkstra, bidirectional Dijkstra, A*, path scoring, and distance summaries.
- `graph_traversal.mbt`: reachability, path existence, and DFS traversal.
- `graph_components.mbt`: weak/strong components, connectivity predicates, and DAG helpers.
- `grid.mbt`: grid construction, terrain, rectangular updates, grid neighbors, and grid pathfinding.
- `moonpath.mbt`: package-level entry point.
- `moonpath_test.mbt`: blackbox behavior tests.
- `cmd/main`: runnable example.
- `.github/workflows/ci.yml`: CI for format, build, and tests.
- `docs/project-proposal.md`: one-page contest proposal draft.
- `docs/development-report.md`: completion report draft.
- `docs/submission-checklist.md`: GitHub/GitLink submission checklist.
- `docs/competition-requirements.md`: extracted requirements from the contest page.

## Roadmap

- Add bidirectional A*.
- Add graph serialization for JSON interchange.
- Add property tests for randomized graph invariants.
- Add benchmarks for dense graphs, sparse graphs, and large tile maps.
- Publish the package after the public repository is pushed.

## License

Apache-2.0.
