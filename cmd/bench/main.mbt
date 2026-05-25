///|
fn main {
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
        "moonpath bench: nodes=\{graph.node_count()}, edges=\{graph.edge_count()}, open=\{grid.open_points().length()}, components=\{components}, cost=\{path.cost}, steps=\{path.edge_count()}, visited=\{path.visited}",
      )
    None =>
      println(
        "moonpath bench: nodes=\{graph.node_count()}, edges=\{graph.edge_count()}, open=\{grid.open_points().length()}, components=\{components}, no path",
      )
  }
}
