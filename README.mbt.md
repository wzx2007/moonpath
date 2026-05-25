# MoonPath

MoonPath is a MoonBit graph algorithms and pathfinding library prepared for the
MoonBit open-source ecosystem contribution contest.

```mbt nocheck
///|
test "shortest path example" {
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

```mbt nocheck
///|
test "path smoothing example" {
  let grid = @moonpath.Grid::new(5, 5)
  let start = @moonpath.Point::new(0, 0)
  let goal = @moonpath.Point::new(4, 4)
  let jagged = [
    start,
    @moonpath.Point::new(1, 0),
    @moonpath.Point::new(4, 3),
    goal,
  ]
  assert_true(grid.line_of_sight(start, goal))
  assert_true(grid.smooth_path(jagged) == [start, goal])
}
```

```mbt nocheck
///|
test "edge list workflow example" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 2)
  graph.add_edge("B", "C", 3)
  let rebuilt = @moonpath.Graph::from_arcs(graph.arcs())
  assert_true(rebuilt.path_cost(["A", "B", "C"]) == Some(5))
  let subgraph = graph.induced_subgraph(node => node != "C")
  assert_true(!subgraph.contains_node("C"))
}
```

```mbt nocheck
///|
test "all pairs summary example" {
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

```mbt nocheck
///|
test "distance and dag layer example" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("parse", "lint", 1)
  graph.add_edge("parse", "compile", 2)
  graph.add_edge("compile", "package", 3)
  let distances = graph.distances_from("parse")
  assert_eq(distances.get_or_default("package", -1), 5)
  assert_true(graph.topological_layers() is Some(_))
}
```

```mbt nocheck
///|
test "bulk grid example" {
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

```mbt nocheck
///|
test "grid terrain example" {
  let grid = @moonpath.Grid::new(3, 3)
  grid.set_cost(@moonpath.Point::new(1, 0), 5)
  guard grid.dijkstra8(@moonpath.Point::new(0, 0), @moonpath.Point::new(2, 2))
    is Some(path) else {
    fail("expected a path")
  }
  assert_eq(path.cost, 28)
}
```

```mbt nocheck
///|
test "no corner cutting example" {
  let grid = @moonpath.Grid::new(2, 2)
  grid.block(@moonpath.Point::new(1, 0))
  grid.block(@moonpath.Point::new(0, 1))
  assert_true(
    grid.astar8_no_corner_cutting(
      @moonpath.Point::new(0, 0),
      @moonpath.Point::new(1, 1),
    ) ==
    None,
  )
}
```

See `README.md` and `docs/` for installation, usage, contest materials, and the
submission checklist.
