///|
fn main {
  let grid = @moonpath.Grid::from_blocked(6, 4, [
    @moonpath.Point::{ x: 2, y: 0 },
    @moonpath.Point::{ x: 2, y: 1 },
    @moonpath.Point::{ x: 2, y: 2 },
  ])
  let start = @moonpath.Point::{ x: 0, y: 0 }
  let goal = @moonpath.Point::{ x: 5, y: 0 }
  match grid.astar4(start, goal) {
    Some(path) =>
      println(
        "moonpath demo: cost=\{path.cost}, steps=\{path.nodes.length() - 1}, visited=\{path.visited}",
      )
    None => println("moonpath demo: no path")
  }
}
