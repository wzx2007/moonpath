///|
fn main {
  run_grid_bench()
  run_sparse_dag_bench()
  run_dense_graph_bench()
}

///|
fn run_grid_bench() -> Unit {
  let grid = @moonpath.Grid::new(30, 20)
  let mut y = 0
  while y < 20 {
    if y != 10 {
      grid.block(@moonpath.Point::new(10, y))
    }
    y += 1
  }
  grid.block_rect(@moonpath.Point::new(20, 3), 1, 12)
  grid.unblock(@moonpath.Point::new(20, 8))
  grid.unblock(@moonpath.Point::new(20, 14))
  grid.set_cost_rect(@moonpath.Point::new(14, 5), 4, 6, 3)

  let start = @moonpath.Point::new(0, 0)
  let goal = @moonpath.Point::new(29, 19)
  let graph = grid.to_graph4()
  let components = graph.weakly_connected_components().length()
  match grid.dijkstra4(start, goal) {
    Some(path) =>
      println(
        "moonpath bench grid: nodes=\{graph.node_count()}, edges=\{graph.edge_count()}, open=\{grid.open_points().length()}, components=\{components}, cost=\{path.cost}, steps=\{path.edge_count()}, visited=\{path.visited}",
      )
    None =>
      println(
        "moonpath bench grid: nodes=\{graph.node_count()}, edges=\{graph.edge_count()}, open=\{grid.open_points().length()}, components=\{components}, no path",
      )
  }
}

///|
fn run_sparse_dag_bench() -> Unit {
  let graph = @moonpath.Graph::new()
  let mut node = 0
  while node < 80 {
    graph.add_node(node)
    node += 1
  }
  let mut from = 0
  while from < 79 {
    graph.add_edge(from, from + 1, 1)
    if from + 4 < 80 {
      graph.add_edge(from, from + 4, 2)
    }
    if from + 9 < 80 {
      graph.add_edge(from, from + 9, 3)
    }
    from += 1
  }
  let layers = match graph.topological_layers() {
    Some(value) => value.length()
    None => 0
  }
  match graph.dag_longest_path(0, 79) {
    Some(path) =>
      println(
        "moonpath bench sparse-dag: nodes=\{graph.node_count()}, edges=\{graph.edge_count()}, layers=\{layers}, critical=\{path.cost}, steps=\{path.edge_count()}",
      )
    None =>
      println(
        "moonpath bench sparse-dag: nodes=\{graph.node_count()}, edges=\{graph.edge_count()}, layers=\{layers}, no path",
      )
  }
}

///|
fn run_dense_graph_bench() -> Unit {
  let graph = @moonpath.Graph::new()
  let mut node = 0
  while node < 36 {
    graph.add_node(node)
    node += 1
  }
  let mut from = 0
  while from < 36 {
    let mut step = 1
    while step <= 6 {
      graph.add_edge(from, (from + step) % 36, step)
      step += 1
    }
    from += 1
  }
  let distances = graph.distances_from(0)
  let tree = graph.shortest_path_tree(0)
  println(
    "moonpath bench dense: nodes=\{graph.node_count()}, edges=\{graph.edge_count()}, reachable=\{distances.length()}, tree=\{tree.length()}, diameter=\{graph.diameter().unwrap()}",
  )
}
