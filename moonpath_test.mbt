///|
test "dijkstra returns lowest weighted path" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 4)
  graph.add_edge("A", "C", 1)
  graph.add_edge("C", "B", 2)
  graph.add_edge("B", "D", 1)
  graph.add_edge("C", "D", 7)
  guard graph.dijkstra("A", "D") is Some(path) else { fail("expected a path") }
  assert_eq(path.cost, 4)
  assert_true(path.nodes == ["A", "C", "B", "D"])
}

///|
test "bfs ignores weights and returns shallow path" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 20)
  graph.add_edge("A", "C", 1)
  graph.add_edge("C", "B", 1)
  guard graph.bfs("A", "B") is Some(path) else { fail("expected a path") }
  assert_eq(path.cost, 1)
  assert_true(path.nodes == ["A", "B"])
}

///|
test "topological sort detects cycles" {
  let dag = @moonpath.Graph::new()
  dag.add_edge("parse", "plan", 1)
  dag.add_edge("plan", "build", 1)
  dag.add_edge("build", "test", 1)
  guard dag.topological_sort() is Some(order) else { fail("dag should sort") }
  assert_eq(order.length(), 4)
  let cyclic = @moonpath.Graph::new()
  cyclic.add_edge("a", "b", 1)
  cyclic.add_edge("b", "a", 1)
  assert_true(cyclic.topological_sort() == None)
}

///|
test "grid astar avoids blocked cells" {
  let grid = @moonpath.Grid::from_blocked(5, 4, [
    @moonpath.Point::{ x: 1, y: 0 },
    @moonpath.Point::{ x: 1, y: 1 },
    @moonpath.Point::{ x: 1, y: 2 },
  ])
  let start = @moonpath.Point::{ x: 0, y: 0 }
  let goal = @moonpath.Point::{ x: 4, y: 0 }
  guard grid.astar4(start, goal) is Some(path) else {
    fail("expected a grid path")
  }
  assert_eq(path.cost, 10)
  assert_true(path.nodes[0] == start)
  assert_true(path.nodes[path.nodes.length() - 1] == goal)
}

///|
test "heuristics are deterministic" {
  let a = @moonpath.Point::{ x: -2, y: 3 }
  let b = @moonpath.Point::{ x: 4, y: -1 }
  assert_eq(@moonpath.manhattan(a, b), 10)
  assert_eq(@moonpath.octile(a, b), 76)
}
