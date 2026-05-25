///|
pub fn Grid::new(width : Int, height : Int) -> Grid {
  guard width >= 0 && height >= 0 else {
    abort("grid width and height must be non-negative")
  }
  Grid::{
    width,
    height,
    blocked: @hashset.HashSet([]),
    terrain: @hashmap.HashMap([]),
  }
}

///|
pub fn Grid::from_blocked(
  width : Int,
  height : Int,
  blocked : Array[Point],
) -> Grid {
  let grid = Grid::new(width, height)
  for point in blocked {
    grid.block(point)
  }
  grid
}

///|
pub fn Point::new(x : Int, y : Int) -> Point {
  Point::{ x, y }
}

///|
pub fn Point::offset(self : Point, dx : Int, dy : Int) -> Point {
  Point::{ x: self.x + dx, y: self.y + dy }
}

///|
pub fn Grid::contains(self : Grid, point : Point) -> Bool {
  point.x >= 0 && point.x < self.width && point.y >= 0 && point.y < self.height
}

///|
pub fn Grid::is_blocked(self : Grid, point : Point) -> Bool {
  self.blocked.contains(point)
}

///|
pub fn Grid::is_open(self : Grid, point : Point) -> Bool {
  self.contains(point) && !self.is_blocked(point)
}

///|
pub fn Grid::points(self : Grid) -> Array[Point] {
  let points : Array[Point] = []
  let mut y = 0
  while y < self.height {
    let mut x = 0
    while x < self.width {
      points.push(Point::{ x, y })
      x += 1
    }
    y += 1
  }
  points
}

///|
pub fn Grid::open_points(self : Grid) -> Array[Point] {
  let points : Array[Point] = []
  for point in self.points() {
    if self.is_open(point) {
      points.push(point)
    }
  }
  points
}

///|
pub fn Grid::block(self : Grid, point : Point) -> Unit {
  guard self.contains(point) else { abort("blocked point is outside grid") }
  self.blocked.add(point)
}

///|
pub fn Grid::unblock(self : Grid, point : Point) -> Unit {
  self.blocked.remove(point)
}

///|
pub fn Grid::block_rect(
  self : Grid,
  top_left : Point,
  width : Int,
  height : Int,
) -> Unit {
  self.assert_rect(top_left, width, height)
  let mut y = 0
  while y < height {
    let mut x = 0
    while x < width {
      self.block(top_left.offset(x, y))
      x += 1
    }
    y += 1
  }
}

///|
pub fn Grid::unblock_rect(
  self : Grid,
  top_left : Point,
  width : Int,
  height : Int,
) -> Unit {
  self.assert_rect(top_left, width, height)
  let mut y = 0
  while y < height {
    let mut x = 0
    while x < width {
      self.unblock(top_left.offset(x, y))
      x += 1
    }
    y += 1
  }
}

///|
pub fn Grid::set_cost(self : Grid, point : Point, cost : Int) -> Unit {
  guard self.contains(point) else { abort("cost point is outside grid") }
  guard cost > 0 else { abort("terrain cost must be positive") }
  self.terrain.set(point, cost)
}

///|
pub fn Grid::set_cost_rect(
  self : Grid,
  top_left : Point,
  width : Int,
  height : Int,
  cost : Int,
) -> Unit {
  self.assert_rect(top_left, width, height)
  let mut y = 0
  while y < height {
    let mut x = 0
    while x < width {
      self.set_cost(top_left.offset(x, y), cost)
      x += 1
    }
    y += 1
  }
}

///|
pub fn Grid::terrain_cost(self : Grid, point : Point) -> Int? {
  guard self.contains(point) else { return None }
  Some(self.terrain.get_or_default(point, 1))
}

///|
pub fn Grid::neighbors4(self : Grid, point : Point) -> Array[Edge[Point]] {
  let out : Array[Edge[Point]] = []
  for
    delta in [
      Point::{ x: 1, y: 0 },
      Point::{ x: -1, y: 0 },
      Point::{ x: 0, y: 1 },
      Point::{ x: 0, y: -1 },
    ] {
    let next = Point::{ x: point.x + delta.x, y: point.y + delta.y }
    if self.is_open(next) {
      out.push(Edge::{ to: next, cost: self.terrain_cost_unchecked(next) })
    }
  }
  out
}

///|
pub fn Grid::neighbors8(self : Grid, point : Point) -> Array[Edge[Point]] {
  let out : Array[Edge[Point]] = []
  for
    delta in [
      Point::{ x: 1, y: 0 },
      Point::{ x: -1, y: 0 },
      Point::{ x: 0, y: 1 },
      Point::{ x: 0, y: -1 },
    ] {
    let next = Point::{ x: point.x + delta.x, y: point.y + delta.y }
    if self.is_open(next) {
      out.push(Edge::{ to: next, cost: self.terrain_cost_unchecked(next) * 10 })
    }
  }
  for
    delta in [
      Point::{ x: 1, y: 1 },
      Point::{ x: 1, y: -1 },
      Point::{ x: -1, y: 1 },
      Point::{ x: -1, y: -1 },
    ] {
    let next = Point::{ x: point.x + delta.x, y: point.y + delta.y }
    if self.is_open(next) {
      out.push(Edge::{ to: next, cost: self.terrain_cost_unchecked(next) * 14 })
    }
  }
  out
}

///|
pub fn Grid::neighbors8_no_corner_cutting(
  self : Grid,
  point : Point,
) -> Array[Edge[Point]] {
  let out : Array[Edge[Point]] = []
  for
    delta in [
      Point::{ x: 1, y: 0 },
      Point::{ x: -1, y: 0 },
      Point::{ x: 0, y: 1 },
      Point::{ x: 0, y: -1 },
    ] {
    let next = point.offset(delta.x, delta.y)
    if self.is_open(next) {
      out.push(Edge::{ to: next, cost: self.terrain_cost_unchecked(next) * 10 })
    }
  }
  for
    delta in [
      Point::{ x: 1, y: 1 },
      Point::{ x: 1, y: -1 },
      Point::{ x: -1, y: 1 },
      Point::{ x: -1, y: -1 },
    ] {
    let next = point.offset(delta.x, delta.y)
    let horizontal = point.offset(delta.x, 0)
    let vertical = point.offset(0, delta.y)
    if self.is_open(next) && self.is_open(horizontal) && self.is_open(vertical) {
      out.push(Edge::{ to: next, cost: self.terrain_cost_unchecked(next) * 14 })
    }
  }
  out
}

///|
pub fn Grid::to_graph4(self : Grid) -> Graph[Point] {
  let graph = Graph::new()
  for point in self.open_points() {
    graph.add_node(point)
    for edge in self.neighbors4(point) {
      graph.add_edge(point, edge.to, edge.cost)
    }
  }
  graph
}

///|
pub fn Grid::to_graph8(self : Grid) -> Graph[Point] {
  let graph = Graph::new()
  for point in self.open_points() {
    graph.add_node(point)
    for edge in self.neighbors8(point) {
      graph.add_edge(point, edge.to, edge.cost)
    }
  }
  graph
}

///|
pub fn Grid::astar4(self : Grid, start : Point, goal : Point) -> Path[Point]? {
  guard self.is_open(start) && self.is_open(goal) else { return None }
  shortest_path(start, goal, point => self.neighbors4(point), manhattan)
}

///|
pub fn Grid::dijkstra4(
  self : Grid,
  start : Point,
  goal : Point,
) -> Path[Point]? {
  guard self.is_open(start) && self.is_open(goal) else { return None }
  shortest_path(start, goal, point => self.neighbors4(point), (_a, _b) => 0)
}

///|
pub fn Grid::astar8(self : Grid, start : Point, goal : Point) -> Path[Point]? {
  guard self.is_open(start) && self.is_open(goal) else { return None }
  shortest_path(start, goal, point => self.neighbors8(point), octile)
}

///|
pub fn Grid::dijkstra8(
  self : Grid,
  start : Point,
  goal : Point,
) -> Path[Point]? {
  guard self.is_open(start) && self.is_open(goal) else { return None }
  shortest_path(start, goal, point => self.neighbors8(point), (_a, _b) => 0)
}

///|
pub fn Grid::astar8_no_corner_cutting(
  self : Grid,
  start : Point,
  goal : Point,
) -> Path[Point]? {
  guard self.is_open(start) && self.is_open(goal) else { return None }
  shortest_path(
    start,
    goal,
    point => self.neighbors8_no_corner_cutting(point),
    octile,
  )
}

///|
pub fn manhattan(a : Point, b : Point) -> Int {
  (a.x - b.x).abs() + (a.y - b.y).abs()
}

///|
pub fn octile(a : Point, b : Point) -> Int {
  let dx = (a.x - b.x).abs()
  let dy = (a.y - b.y).abs()
  let diagonal = dx.min(dy)
  let straight = dx.max(dy) - diagonal
  diagonal * 14 + straight * 10
}

///|
fn Grid::terrain_cost_unchecked(self : Grid, point : Point) -> Int {
  self.terrain.get_or_default(point, 1)
}

///|
fn Grid::assert_rect(
  self : Grid,
  top_left : Point,
  width : Int,
  height : Int,
) -> Unit {
  guard width >= 0 && height >= 0 else {
    abort("rectangle width and height must be non-negative")
  }
  guard top_left.x >= 0 &&
    top_left.y >= 0 &&
    top_left.x + width <= self.width &&
    top_left.y + height <= self.height else {
    abort("rectangle is outside grid")
  }
}
