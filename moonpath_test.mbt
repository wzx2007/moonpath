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
  assert_eq(path.node_count(), 4)
  assert_eq(path.edge_count(), 3)
}

///|
test "bidirectional dijkstra matches weighted shortest path" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 4)
  graph.add_edge("A", "C", 1)
  graph.add_edge("C", "B", 2)
  graph.add_edge("B", "D", 1)
  graph.add_edge("C", "D", 7)
  guard graph.bidirectional_dijkstra("A", "D") is Some(path) else {
    fail("expected a bidirectional path")
  }
  assert_eq(path.cost, 4)
  assert_true(path.nodes == ["A", "C", "B", "D"])
  assert_true(graph.path_cost(path.nodes) == Some(4))
  assert_true(graph.bidirectional_dijkstra("D", "A") == None)
  guard graph.bidirectional_dijkstra("A", "A") is Some(same) else {
    fail("expected zero-length path")
  }
  assert_eq(same.cost, 0)
  assert_true(same.nodes == ["A"])
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
test "shortest_path_tree exports Dijkstra parent edges" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 5)
  graph.add_edge("A", "C", 2)
  graph.add_edge("C", "B", 1)
  graph.add_edge("B", "D", 4)
  graph.add_node("Z")
  let tree = graph.shortest_path_tree("A")
  assert_eq(tree.length(), 3)
  assert_true(contains_arc(tree, "A", "C", 2))
  assert_true(contains_arc(tree, "C", "B", 1))
  assert_true(contains_arc(tree, "B", "D", 4))
  assert_true(!contains_arc(tree, "A", "B", 5))
  assert_true(graph.shortest_path_tree("missing").length() == 0)
}

///|
test "all pairs distances and graph diameter summarize shortest paths" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 2)
  graph.add_edge("B", "C", 3)
  graph.add_edge("A", "C", 10)
  graph.add_node("D")
  let all = graph.all_pairs_distances()
  guard all.get("A") is Some(from_a) else { fail("expected distances from A") }
  assert_eq(from_a.get_or_default("C", -1), 5)
  assert_true(graph.eccentricity("A") == Some(5))
  assert_true(graph.eccentricity("D") == Some(0))
  assert_true(graph.eccentricity("missing") == None)
  assert_true(graph.diameter() == Some(5))
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
test "dag_longest_path returns weighted critical path" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("start", "A", 2)
  graph.add_edge("start", "B", 1)
  graph.add_edge("A", "C", 3)
  graph.add_edge("B", "C", 10)
  graph.add_edge("C", "done", 1)
  guard graph.dag_longest_path("start", "done") is Some(path) else {
    fail("expected a DAG longest path")
  }
  assert_eq(path.cost, 12)
  assert_true(path.nodes == ["start", "B", "C", "done"])
  assert_eq(path.visited, 5)
  assert_true(graph.dag_longest_path("missing", "done") == None)

  let cyclic = @moonpath.Graph::new()
  cyclic.add_edge("A", "B", 1)
  cyclic.add_edge("B", "A", 1)
  assert_true(cyclic.dag_longest_path("A", "B") == None)
}

///|
test "dag_paths enumerates acyclic workflow alternatives" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("start", "lint", 1)
  graph.add_edge("start", "compile", 2)
  graph.add_edge("lint", "package", 3)
  graph.add_edge("compile", "package", 4)
  graph.add_edge("package", "deploy", 5)
  let paths = graph.dag_paths("start", "deploy")
  assert_eq(paths.length(), 2)
  assert_true(contains_path(paths, ["start", "lint", "package", "deploy"], 9))
  assert_true(
    contains_path(paths, ["start", "compile", "package", "deploy"], 11),
  )
  assert_true(graph.dag_paths("missing", "deploy").length() == 0)

  let cyclic = @moonpath.Graph::new()
  cyclic.add_edge("A", "B", 1)
  cyclic.add_edge("B", "A", 1)
  assert_true(cyclic.dag_paths("A", "B").length() == 0)
}

///|
test "dfs traversal and path existence inspect directed reachability" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 1)
  graph.add_edge("A", "C", 1)
  graph.add_edge("B", "D", 1)
  graph.add_edge("C", "E", 1)
  let preorder = graph.dfs_preorder("A")
  let postorder = graph.dfs_postorder("A")
  assert_true(preorder[0] == "A")
  assert_eq(preorder.length(), 5)
  assert_eq(postorder.length(), 5)
  assert_true(contains(preorder, "D"))
  assert_true(contains(postorder, "A"))
  assert_true(graph.has_path("A", "E"))
  assert_true(!graph.has_path("E", "A"))
}

///|
test "ancestors and descendants inspect dependency direction" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("parse", "compile", 1)
  graph.add_edge("compile", "package", 1)
  graph.add_edge("lint", "package", 1)
  graph.add_edge("package", "deploy", 1)
  let ancestors = graph.ancestors("package")
  let descendants = graph.descendants("compile")
  assert_true(contains(ancestors, "parse"))
  assert_true(contains(ancestors, "compile"))
  assert_true(contains(ancestors, "lint"))
  assert_true(!contains(ancestors, "package"))
  assert_true(contains(descendants, "package"))
  assert_true(contains(descendants, "deploy"))
  assert_true(!contains(descendants, "compile"))
  assert_true(graph.ancestors("missing").length() == 0)
  assert_true(graph.descendants("missing").length() == 0)
}

///|
test "bfs_tree exports first-discovery traversal edges" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 1)
  graph.add_edge("A", "C", 2)
  graph.add_edge("B", "D", 3)
  graph.add_edge("C", "D", 4)
  graph.add_edge("C", "E", 5)
  let tree = graph.bfs_tree("A")
  assert_eq(tree.length(), 4)
  assert_true(contains_arc(tree, "A", "B", 1))
  assert_true(contains_arc(tree, "A", "C", 2))
  assert_true(contains_arc(tree, "B", "D", 3))
  assert_true(contains_arc(tree, "C", "E", 5))
  assert_true(!contains_arc(tree, "C", "D", 4))
  assert_true(graph.bfs_tree("missing").length() == 0)
}

///|
test "reachable_subgraph keeps only nodes reachable from start" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 1)
  graph.add_edge("B", "C", 2)
  graph.add_edge("X", "Y", 3)
  graph.add_node("Z")
  let subgraph = graph.reachable_subgraph("A")
  assert_eq(subgraph.node_count(), 3)
  assert_eq(subgraph.edge_count(), 2)
  assert_true(subgraph.contains_node("A"))
  assert_true(subgraph.contains_edge("A", "B"))
  assert_true(!subgraph.contains_node("X"))
  assert_eq(graph.reachable_subgraph("missing").node_count(), 0)
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
test "grid dijkstra matches astar costs without heuristics" {
  let grid = @moonpath.Grid::new(4, 4)
  grid.block_rect(@moonpath.Point::new(1, 0), 1, 2)
  grid.set_cost(@moonpath.Point::new(2, 2), 5)
  let start = @moonpath.Point::new(0, 0)
  let goal = @moonpath.Point::new(3, 3)
  guard grid.astar4(start, goal) is Some(astar4) else {
    fail("expected astar4 path")
  }
  guard grid.dijkstra4(start, goal) is Some(dijkstra4) else {
    fail("expected dijkstra4 path")
  }
  guard grid.dijkstra8(start, goal) is Some(dijkstra8) else {
    fail("expected dijkstra8 path")
  }
  assert_eq(dijkstra4.cost, astar4.cost)
  assert_true(dijkstra8.cost <= dijkstra4.cost * 10)
  assert_true(grid.path_valid4(dijkstra4.nodes))
  assert_true(grid.path_cost4(dijkstra4.nodes) == Some(dijkstra4.cost))
  assert_true(grid.path_valid8(dijkstra8.nodes))
  assert_true(grid.path_cost8(dijkstra8.nodes) == Some(dijkstra8.cost))
  assert_true(!grid.path_valid4([start, goal]))
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
  graph.add_node("D")
  assert_true(graph.contains_edge("A", "B"))
  assert_true(!graph.contains_edge("B", "A"))
  assert_eq(graph.out_degree("A"), 2)
  assert_eq(graph.in_degree("A"), 1)
  assert_true(contains(graph.sources(), "D"))
  assert_true(contains(graph.sinks(), "B"))
  assert_true(contains(graph.sinks(), "D"))
  assert_true(graph.isolated_nodes() == ["D"])
  let reversed = graph.transpose()
  assert_true(reversed.contains_edge("B", "A"))
  assert_true(reversed.contains_edge("C", "A"))
  assert_true(reversed.contains_edge("A", "C"))
}

///|
test "graph mutation removes edges and nodes" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 1)
  graph.add_edge("A", "B", 2)
  graph.add_edge("A", "C", 3)
  graph.add_edge("C", "A", 4)
  assert_eq(graph.remove_edge("A", "B"), 2)
  assert_true(!graph.contains_edge("A", "B"))
  assert_eq(graph.out_degree("A"), 1)
  assert_eq(graph.clear_edges_from("A"), 1)
  assert_eq(graph.out_degree("A"), 0)
  assert_true(graph.remove_node("C"))
  assert_true(!graph.contains_node("C"))
  assert_true(!graph.contains_edge("C", "A"))
  assert_true(!graph.remove_node("missing"))
}

///|
test "graph edge cost summaries inspect weighted data" {
  let graph = @moonpath.Graph::new()
  assert_eq(graph.total_edge_cost(), 0)
  assert_true(graph.min_edge_cost() == None)
  assert_true(graph.max_edge_cost() == None)
  graph.add_edge("A", "B", 5)
  graph.add_edge("B", "C", 2)
  graph.add_edge("C", "D", 9)
  assert_eq(graph.total_edge_cost(), 16)
  assert_true(graph.min_edge_cost() == Some(2))
  assert_true(graph.max_edge_cost() == Some(9))
}

///|
test "graph arcs and induced subgraphs support export workflows" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 2)
  graph.add_edge("B", "C", 3)
  graph.add_edge("A", "C", 10)
  graph.add_node("D")
  let arcs = graph.arcs()
  assert_eq(arcs.length(), 3)
  let rebuilt = @moonpath.Graph::from_arcs(arcs)
  assert_eq(rebuilt.edge_count(), 3)
  assert_true(rebuilt.path_cost(["A", "B", "C"]) == Some(5))

  let subgraph = graph.induced_subgraph(node => node != "C")
  assert_true(subgraph.contains_node("A"))
  assert_true(subgraph.contains_node("B"))
  assert_true(subgraph.contains_node("D"))
  assert_true(subgraph.contains_edge("A", "B"))
  assert_true(!subgraph.contains_node("C"))
  assert_true(!subgraph.contains_edge("A", "C"))
}

///|
test "try_from_arcs rejects invalid bulk input without aborting" {
  let good = [
    @moonpath.Arc::{ from: "A", to: "B", cost: 1 },
    @moonpath.Arc::{ from: "B", to: "C", cost: 2 },
  ]
  guard @moonpath.Graph::try_from_arcs(good) is Some(graph) else {
    fail("expected graph from valid arcs")
  }
  assert_eq(graph.edge_count(), 2)
  assert_true(graph.path_cost(["A", "B", "C"]) == Some(3))

  let bad = [
    @moonpath.Arc::{ from: "A", to: "B", cost: 1 },
    @moonpath.Arc::{ from: "B", to: "C", cost: -1 },
  ]
  guard @moonpath.Graph::try_from_arcs(bad) is None else {
    fail("invalid arcs should not build a graph")
  }
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
  assert_true(!graph.is_weakly_connected())
  assert_true(!graph.is_strongly_connected())

  let connected = @moonpath.Graph::new()
  connected.add_edge("A", "B", 1)
  connected.add_edge("B", "A", 1)
  connected.add_edge("B", "C", 1)
  connected.add_edge("C", "B", 1)
  assert_true(connected.is_weakly_connected())
  assert_true(connected.is_strongly_connected())
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
test "grid rectangle helpers update blocked cells and terrain costs" {
  let grid = @moonpath.Grid::new(5, 4)
  grid.block_rect(@moonpath.Point::new(1, 1), 3, 2)
  assert_eq(grid.open_points().length(), 14)
  assert_true(grid.is_blocked(@moonpath.Point::new(2, 2)))
  grid.unblock_rect(@moonpath.Point::new(2, 1), 1, 2)
  assert_true(grid.is_open(@moonpath.Point::new(2, 2)))
  assert_eq(grid.open_points().length(), 16)
  grid.set_cost_rect(@moonpath.Point::new(0, 0), 2, 2, 4)
  assert_true(grid.terrain_cost(@moonpath.Point::new(1, 1)) == Some(4))
  assert_true(grid.clear_cost(@moonpath.Point::new(1, 1)))
  assert_true(!grid.clear_cost(@moonpath.Point::new(1, 1)))
  assert_true(grid.terrain_cost(@moonpath.Point::new(1, 1)) == Some(1))
  assert_eq(grid.clear_cost_rect(@moonpath.Point::new(0, 0), 2, 1), 2)
  assert_eq(grid.terrain_cells().length(), 1)
}

///|
test "grid exports and rebuilds blocked and terrain cells" {
  let grid = @moonpath.Grid::new(4, 3)
  grid.block_rect(@moonpath.Point::new(1, 0), 1, 2)
  grid.set_cost_rect(@moonpath.Point::new(2, 1), 2, 2, 6)
  let rebuilt = @moonpath.Grid::from_parts(
    4,
    3,
    grid.blocked_points(),
    grid.terrain_cells(),
  )
  assert_true(rebuilt.is_blocked(@moonpath.Point::new(1, 0)))
  assert_true(rebuilt.is_blocked(@moonpath.Point::new(1, 1)))
  assert_eq(rebuilt.blocked_points().length(), 2)
  assert_eq(rebuilt.terrain_cells().length(), 4)
  assert_true(rebuilt.terrain_cost(@moonpath.Point::new(3, 2)) == Some(6))
}

///|
test "grid resized preserves in-bounds blocked and terrain cells" {
  let grid = @moonpath.Grid::new(4, 4)
  grid.block(@moonpath.Point::new(1, 1))
  grid.block(@moonpath.Point::new(3, 3))
  grid.set_cost(@moonpath.Point::new(2, 2), 7)
  grid.set_cost(@moonpath.Point::new(3, 3), 9)
  let smaller = grid.resized(3, 3)
  assert_eq(smaller.points().length(), 9)
  assert_true(smaller.is_blocked(@moonpath.Point::new(1, 1)))
  assert_true(!smaller.contains(@moonpath.Point::new(3, 3)))
  assert_true(smaller.terrain_cost(@moonpath.Point::new(2, 2)) == Some(7))
  assert_eq(smaller.terrain_cells().length(), 1)

  let larger = smaller.resized(5, 5)
  assert_eq(larger.points().length(), 25)
  assert_true(larger.is_blocked(@moonpath.Point::new(1, 1)))
  assert_true(larger.terrain_cost(@moonpath.Point::new(2, 2)) == Some(7))
}

///|
test "grid inflated_blocks expands obstacle clearance" {
  let grid = @moonpath.Grid::new(5, 5)
  grid.block(@moonpath.Point::new(2, 2))
  grid.set_cost(@moonpath.Point::new(4, 4), 6)
  let inflated = grid.inflated_blocks(1)
  assert_eq(inflated.blocked_points().length(), 9)
  assert_true(inflated.is_blocked(@moonpath.Point::new(1, 1)))
  assert_true(inflated.is_blocked(@moonpath.Point::new(3, 3)))
  assert_true(!inflated.is_blocked(@moonpath.Point::new(0, 0)))
  assert_true(inflated.terrain_cost(@moonpath.Point::new(4, 4)) == Some(6))

  let unchanged = grid.inflated_blocks(0)
  assert_eq(unchanged.blocked_points().length(), 1)
  assert_true(unchanged.is_blocked(@moonpath.Point::new(2, 2)))
}

///|
test "grid smooth_path removes unnecessary waypoints" {
  let grid = @moonpath.Grid::new(5, 5)
  let start = @moonpath.Point::new(0, 0)
  let goal = @moonpath.Point::new(4, 4)
  let jagged = [
    start,
    @moonpath.Point::new(1, 0),
    @moonpath.Point::new(2, 0),
    @moonpath.Point::new(3, 1),
    @moonpath.Point::new(4, 2),
    @moonpath.Point::new(4, 3),
    goal,
  ]
  assert_true(grid.line_of_sight(start, goal))
  assert_true(grid.smooth_path(jagged) == [start, goal])

  grid.block(@moonpath.Point::new(2, 2))
  assert_true(!grid.line_of_sight(start, goal))
  let smoothed = grid.smooth_path(jagged)
  assert_true(smoothed.length() > 2)
  assert_true(smoothed[0] == start)
  assert_true(smoothed[smoothed.length() - 1] == goal)
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
test "grid reachability and open regions distinguish 4 and 8 neighbors" {
  let grid = @moonpath.Grid::new(2, 2)
  let start = @moonpath.Point::new(0, 0)
  let diagonal = @moonpath.Point::new(1, 1)
  grid.block(@moonpath.Point::new(1, 0))
  grid.block(@moonpath.Point::new(0, 1))
  assert_eq(grid.reachable_points4(start).length(), 1)
  assert_eq(grid.reachable_points8(start).length(), 2)
  assert_true(contains(grid.reachable_points8(start), diagonal))
  assert_eq(grid.open_regions4().length(), 2)
  assert_eq(grid.open_regions8().length(), 1)
  assert_eq(grid.component_count4(), 2)
  assert_eq(grid.component_count8(), 1)
  assert_true(!grid.is_fully_connected4())
  assert_true(grid.is_fully_connected8())
  assert_true(grid.reachable_points4(@moonpath.Point::new(1, 0)).length() == 0)

  let empty = @moonpath.Grid::new(1, 1)
  empty.block(@moonpath.Point::new(0, 0))
  assert_eq(empty.component_count4(), 0)
  assert_true(empty.is_fully_connected4())
}

///|
test "generated DAG invariants stay consistent" {
  let graph = @moonpath.Graph::new()
  let mut node = 0
  while node < 10 {
    graph.add_node(node)
    node += 1
  }
  let mut from = 0
  while from < 9 {
    graph.add_edge(from, from + 1, 1)
    if from + 2 < 10 {
      graph.add_edge(from, from + 2, 2)
    }
    from += 1
  }
  assert_true(graph.is_acyclic())
  assert_eq(graph.node_count(), 10)
  assert_eq(graph.edge_count(), 17)
  assert_true(graph.sources() == [0])
  assert_true(graph.sinks() == [9])
  guard graph.topological_sort() is Some(order) else {
    fail("generated DAG should sort")
  }
  assert_eq(order.length(), graph.node_count())
  guard graph.dag_longest_path(0, 9) is Some(path) else {
    fail("expected a generated DAG path")
  }
  assert_eq(path.cost, 9)
  assert_true(graph.path_cost(path.nodes) == Some(path.cost))

  let reversed = graph.transpose()
  assert_eq(reversed.node_count(), graph.node_count())
  assert_eq(reversed.edge_count(), graph.edge_count())
  for arc in graph.arcs() {
    assert_true(reversed.contains_edge(arc.to, arc.from))
  }
}

///|
test "grid export rebuild and inflation invariants stay consistent" {
  let grid = @moonpath.Grid::new(6, 5)
  grid.block_rect(@moonpath.Point::new(2, 1), 2, 2)
  grid.set_cost_rect(@moonpath.Point::new(0, 0), 3, 1, 4)
  let rebuilt = @moonpath.Grid::from_parts(
    6,
    5,
    grid.blocked_points(),
    grid.terrain_cells(),
  )
  assert_eq(rebuilt.points().length(), 30)
  assert_eq(rebuilt.blocked_points().length(), grid.blocked_points().length())
  assert_eq(
    rebuilt.open_points().length() + rebuilt.blocked_points().length(),
    30,
  )
  assert_true(rebuilt.terrain_cost(@moonpath.Point::new(1, 0)) == Some(4))

  let inflated = rebuilt.inflated_blocks(1)
  assert_true(
    inflated.blocked_points().length() >= rebuilt.blocked_points().length(),
  )
  assert_eq(inflated.points().length(), rebuilt.points().length())
  assert_true(inflated.terrain_cost(@moonpath.Point::new(1, 0)) == Some(4))
  let graph4 = rebuilt.to_graph4()
  assert_eq(graph4.node_count(), rebuilt.open_points().length())
  for arc in graph4.arcs() {
    assert_true(rebuilt.is_open(arc.from))
    assert_true(rebuilt.is_open(arc.to))
  }
}

///|
test "graph serializes through JSON and text formats" {
  let graph = @moonpath.Graph::new()
  graph.add_node("isolated")
  graph.add_edge("A", "B", 2)
  graph.add_edge("B", "C", 3)
  graph.add_edge("A", "C", 9)
  let json = graph.to_json_string()
  guard @moonpath.Graph::from_json_string(json) is Some(from_json) else {
    fail("expected graph JSON round trip")
  }
  assert_eq(from_json.node_count(), graph.node_count())
  assert_eq(from_json.edge_count(), graph.edge_count())
  assert_true(from_json.contains_node("isolated"))
  assert_true(from_json.path_cost(["A", "B", "C"]) == Some(5))

  let text = graph.to_text()
  guard @moonpath.Graph::from_text(text) is Some(from_text) else {
    fail("expected graph text round trip")
  }
  assert_eq(from_text.node_count(), graph.node_count())
  assert_eq(from_text.edge_count(), graph.edge_count())
  assert_true(from_text.path_cost(["A", "B", "C"]) == Some(5))
  assert_true(@moonpath.Graph::from_text("arc\t\"A\"\t\"B\"\t-1\n") is None)
}

///|
test "grid serializes through JSON and text formats" {
  let grid = @moonpath.Grid::new(4, 3)
  grid.block(@moonpath.Point::new(1, 0))
  grid.block(@moonpath.Point::new(2, 2))
  grid.set_cost(@moonpath.Point::new(3, 1), 6)
  let json = grid.to_json_string()
  guard @moonpath.Grid::from_json_string(json) is Some(from_json) else {
    fail("expected grid JSON round trip")
  }
  assert_eq(from_json.blocked_points().length(), 2)
  assert_true(from_json.is_blocked(@moonpath.Point::new(1, 0)))
  assert_true(from_json.terrain_cost(@moonpath.Point::new(3, 1)) == Some(6))

  let text = grid.to_text()
  guard @moonpath.Grid::from_text(text) is Some(from_text) else {
    fail("expected grid text round trip")
  }
  assert_eq(from_text.points().length(), grid.points().length())
  assert_true(from_text.is_blocked(@moonpath.Point::new(2, 2)))
  assert_true(from_text.terrain_cost(@moonpath.Point::new(3, 1)) == Some(6))
  assert_true(@moonpath.Grid::from_text("blocked\t0\t0\n") is None)
  assert_true(@moonpath.Grid::from_text("grid\t-1\t2\n") is None)
  assert_true(
    @moonpath.Grid::from_text("grid\t2\t2\nterrain\t1\t1\t0\n") is None,
  )
}

///|
test "bidirectional A* matches shortest path on graphs and grids" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("S", "A", 2)
  graph.add_edge("A", "T", 2)
  graph.add_edge("S", "B", 5)
  graph.add_edge("B", "T", 1)
  guard graph.bidirectional_astar("S", "T", (_a, _b) => 0) is Some(path) else {
    fail("expected bidirectional A* graph path")
  }
  assert_eq(path.cost, 4)
  guard graph.dijkstra("S", "T") is Some(expected) else {
    fail("expected dijkstra graph path")
  }
  assert_eq(path.cost, expected.cost)

  let grid = @moonpath.Grid::new(5, 4)
  grid.block_rect(@moonpath.Point::new(2, 0), 1, 3)
  let start = @moonpath.Point::new(0, 0)
  let goal = @moonpath.Point::new(4, 0)
  guard grid.bidirectional_astar4(start, goal) is Some(grid_path) else {
    fail("expected bidirectional A* grid path")
  }
  assert_true(grid.path_valid4(grid_path.nodes))
  assert_true(grid.path_cost4(grid_path.nodes) == Some(grid_path.cost))
}

///|
test "bellman-ford supports negative edges and rejects reachable negative cycles" {
  let nodes = ["S", "A", "B", "T"]
  let arcs = [
    @moonpath.Arc::{ from: "S", to: "A", cost: 4 },
    @moonpath.Arc::{ from: "A", to: "B", cost: -6 },
    @moonpath.Arc::{ from: "B", to: "T", cost: 3 },
    @moonpath.Arc::{ from: "S", to: "T", cost: 10 },
  ]
  guard @moonpath.bellman_ford_path(nodes, arcs, "S", "T") is Some(path) else {
    fail("expected negative-edge path")
  }
  assert_eq(path.cost, 1)
  assert_true(path.nodes == ["S", "A", "B", "T"])
  guard @moonpath.bellman_ford_distances(nodes, arcs, "S") is Some(dist) else {
    fail("expected negative-edge distances")
  }
  assert_eq(dist.get_or_default("T", 999), 1)

  let bad = [
    @moonpath.Arc::{ from: "S", to: "A", cost: 1 },
    @moonpath.Arc::{ from: "A", to: "B", cost: -3 },
    @moonpath.Arc::{ from: "B", to: "A", cost: 1 },
    @moonpath.Arc::{ from: "B", to: "T", cost: 1 },
  ]
  assert_true(@moonpath.bellman_ford_path(nodes, bad, "S", "T") is None)
  assert_true(@moonpath.bellman_ford_distances(nodes, bad, "S") is None)
}

///|
test "generated graph and grid property checks cover core invariants" {
  let mut size = 5
  while size <= 14 {
    let graph = make_generated_dag(size, size * 11)
    let twice = graph.transpose().transpose()
    assert_eq(twice.node_count(), graph.node_count())
    assert_eq(twice.edge_count(), graph.edge_count())
    for arc in graph.arcs() {
      assert_true(twice.contains_edge(arc.from, arc.to))
    }
    let tree = graph.shortest_path_tree(0)
    let reachable = graph.distances_from(0).length()
    assert_true(tree.length() <= reachable - 1)
    guard graph.dag_longest_path(0, size - 1) is Some(path) else {
      fail("expected generated DAG path")
    }
    assert_true(path.nodes[0] == 0)
    assert_true(path.nodes[path.nodes.length() - 1] == size - 1)
    assert_true(graph.path_cost(path.nodes) == Some(path.cost))
    size += 3
  }

  let mut seed = 0
  while seed < 6 {
    let grid = make_generated_grid(6 + seed, 5 + seed, seed)
    let graph4 = grid.to_graph4()
    assert_eq(graph4.node_count(), grid.open_points().length())
    let twice = graph4.transpose().transpose()
    assert_eq(twice.node_count(), graph4.node_count())
    assert_eq(twice.edge_count(), graph4.edge_count())
    let start = @moonpath.Point::new(0, 0)
    if grid.is_open(start) {
      let reachable = graph4.distances_from(start).length()
      let tree = graph4.shortest_path_tree(start)
      assert_true(tree.length() <= reachable - 1)
    }
    seed += 1
  }
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

///|
fn make_generated_dag(size : Int, salt : Int) -> @moonpath.Graph[Int] {
  let graph = @moonpath.Graph::new()
  let mut node = 0
  while node < size {
    graph.add_node(node)
    node += 1
  }
  let mut from = 0
  while from + 1 < size {
    graph.add_edge(from, from + 1, 1)
    let mut to = from + 2
    while to < size {
      if (from * 31 + to * 17 + salt) % 4 == 0 {
        graph.add_edge(from, to, to - from + 1)
      }
      to += 1
    }
    from += 1
  }
  graph
}

///|
fn make_generated_grid(width : Int, height : Int, salt : Int) -> @moonpath.Grid {
  let grid = @moonpath.Grid::new(width, height)
  let mut y = 0
  while y < height {
    let mut x = 0
    while x < width {
      let point = @moonpath.Point::new(x, y)
      if !(x == 0 && y == 0) &&
        !(x == width - 1 && y == height - 1) &&
        (x * 19 + y * 23 + salt) % 7 == 0 {
        grid.block(point)
      } else if (x * 13 + y * 11 + salt) % 5 == 0 {
        grid.set_cost(point, 2 + (x + y + salt) % 4)
      }
      x += 1
    }
    y += 1
  }
  grid
}

///|
fn[N : Eq] contains_arc(
  arcs : Array[@moonpath.Arc[N]],
  from : N,
  to : N,
  cost : Int,
) -> Bool {
  for arc in arcs {
    if arc.from == from && arc.to == to && arc.cost == cost {
      return true
    }
  }
  false
}

///|
fn[N : Eq] contains_path(
  paths : Array[@moonpath.Path[N]],
  nodes : Array[N],
  cost : Int,
) -> Bool {
  for path in paths {
    if path.cost == cost && path.nodes == nodes {
      return true
    }
  }
  false
}
