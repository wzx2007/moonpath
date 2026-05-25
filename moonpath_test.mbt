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
test "distances_from computes all reachable weighted costs" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 5)
  graph.add_edge("A", "C", 2)
  graph.add_edge("C", "B", 1)
  graph.add_edge("B", "D", 4)
  graph.add_node("Z")
  let distances = graph.distances_from("A")
  assert_eq(distances.get_or_default("A", -1), 0)
  assert_eq(distances.get_or_default("B", -1), 3)
  assert_eq(distances.get_or_default("D", -1), 7)
  assert_true(distances.get("Z") == None)
  assert_true(graph.shortest_distance("A", "D") == Some(7))
}

///|
test "topological layers group independent work" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("parse", "lint", 1)
  graph.add_edge("parse", "compile", 1)
  graph.add_edge("lint", "package", 1)
  graph.add_edge("compile", "package", 1)
  guard graph.topological_layers() is Some(layers) else {
    fail("dag should have layers")
  }
  assert_true(graph.is_acyclic())
  assert_eq(layers.length(), 3)
  assert_true(contains(layers[0], "parse"))
  assert_true(contains(layers[1], "lint"))
  assert_true(contains(layers[1], "compile"))
  assert_true(contains(layers[2], "package"))

  let cyclic = @moonpath.Graph::new()
  cyclic.add_edge("a", "b", 1)
  cyclic.add_edge("b", "a", 1)
  assert_true(!cyclic.is_acyclic())
  assert_true(cyclic.topological_layers() == None)
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

///|
test "graph degree and transpose expose directed structure" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 3)
  graph.add_edge("A", "C", 5)
  graph.add_edge("C", "A", 2)
  assert_true(graph.contains_edge("A", "B"))
  assert_true(!graph.contains_edge("B", "A"))
  assert_eq(graph.out_degree("A"), 2)
  assert_eq(graph.in_degree("A"), 1)
  let reversed = graph.transpose()
  assert_true(reversed.contains_edge("B", "A"))
  assert_true(reversed.contains_edge("C", "A"))
  assert_true(reversed.contains_edge("A", "C"))
}

///|
test "weak and strong components differ on directed graphs" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 1)
  graph.add_edge("B", "A", 1)
  graph.add_edge("B", "C", 1)
  graph.add_edge("D", "E", 1)
  graph.add_edge("E", "D", 1)
  let weak = graph.weakly_connected_components()
  assert_eq(weak.length(), 2)
  let strong = graph.strongly_connected_components()
  let mut pairs = 0
  let mut singles = 0
  for component in strong {
    if component.length() == 2 {
      pairs += 1
    }
    if component.length() == 1 {
      singles += 1
    }
  }
  assert_eq(pairs, 2)
  assert_eq(singles, 1)
}

///|
test "grid supports terrain costs and point helpers" {
  let grid = @moonpath.Grid::new(3, 2)
  let start = @moonpath.Point::new(0, 0)
  let rough = start.offset(1, 0)
  grid.set_cost(rough, 5)
  assert_true(grid.terrain_cost(rough) == Some(5))
  assert_eq(grid.points().length(), 6)
  let neighbors = grid.neighbors4(start)
  let mut rough_cost = 0
  for edge in neighbors {
    if edge.to == rough {
      rough_cost = edge.cost
    }
  }
  assert_eq(rough_cost, 5)
}

///|
test "grid astar8 uses consistent octile scale" {
  let grid = @moonpath.Grid::new(3, 3)
  let start = @moonpath.Point::new(0, 0)
  let goal = @moonpath.Point::new(2, 2)
  guard grid.astar8(start, goal) is Some(path) else {
    fail("expected a diagonal path")
  }
  assert_eq(path.cost, 28)
  assert_true(path.nodes[0] == start)
  assert_true(path.nodes[path.nodes.length() - 1] == goal)
}

///|
test "grid astar8 can prevent corner cutting" {
  let grid = @moonpath.Grid::new(2, 2)
  let start = @moonpath.Point::new(0, 0)
  let goal = @moonpath.Point::new(1, 1)
  grid.block(@moonpath.Point::new(1, 0))
  grid.block(@moonpath.Point::new(0, 1))
  assert_true(grid.astar8(start, goal) is Some(_))
  assert_true(grid.neighbors8_no_corner_cutting(start).length() == 0)
  assert_true(grid.astar8_no_corner_cutting(start, goal) == None)
}

///|
test "grid converts open cells into graph edges" {
  let grid = @moonpath.Grid::new(2, 2)
  grid.block(@moonpath.Point::new(1, 0))
  let graph = grid.to_graph4()
  assert_eq(graph.node_count(), 3)
  assert_eq(graph.edge_count(), 4)
  assert_true(!graph.contains_node(@moonpath.Point::new(1, 0)))
}

///|
fn[N : Eq] contains(items : Array[N], value : N) -> Bool {
  for item in items {
    if item == value {
      return true
    }
  }
  false
}
