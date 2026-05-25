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
  guard graph.dijkstra("A", "D") is Some(path) else { fail("expected a path") }
  assert_eq(path.cost, 4)
  assert_true(path.nodes == ["A", "C", "B", "D"])
}
```

```mbt nocheck
///|
test "grid terrain example" {
  let grid = @moonpath.Grid::new(3, 3)
  grid.set_cost(@moonpath.Point::new(1, 0), 5)
  guard grid.astar8(@moonpath.Point::new(0, 0), @moonpath.Point::new(2, 2))
    is Some(path) else {
    fail("expected a path")
  }
  assert_eq(path.cost, 28)
}
```

See `README.md` and `docs/` for installation, usage, contest materials, and the
submission checklist.
