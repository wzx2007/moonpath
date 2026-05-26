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
pub fn Grid::from_parts(
  width : Int,
  height : Int,
  blocked : Array[Point],
  terrain : Array[CellCost],
) -> Grid {
  let grid = Grid::from_blocked(width, height, blocked)
  for cell in terrain {
    grid.set_cost(cell.point, cell.cost)
  }
  grid
}

///|
pub fn Grid::resized(self : Grid, width : Int, height : Int) -> Grid {
  let grid = Grid::new(width, height)
  for point in self.blocked_points() {
    if grid.contains(point) {
      grid.block(point)
    }
  }
  for cell in self.terrain_cells() {
    if grid.contains(cell.point) {
      grid.set_cost(cell.point, cell.cost)
    }
  }
  grid
}

///|
pub fn Grid::inflated_blocks(self : Grid, radius : Int) -> Grid {
  guard radius >= 0 else {
    abort("block inflation radius must be non-negative")
  }
  let grid = Grid::from_parts(
    self.width,
    self.height,
    self.blocked_points(),
    self.terrain_cells(),
  )
  for point in self.blocked_points() {
    let mut dy = -radius
    while dy <= radius {
      let mut dx = -radius
      while dx <= radius {
        let next = point.offset(dx, dy)
        if grid.contains(next) {
          grid.block(next)
        }
        dx += 1
      }
      dy += 1
    }
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
pub fn Grid::blocked_points(self : Grid) -> Array[Point] {
  self.blocked.to_array()
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
pub fn Grid::clear_cost(self : Grid, point : Point) -> Bool {
  guard self.contains(point) else { abort("cost point is outside grid") }
  guard self.terrain.contains(point) else { return false }
  self.terrain.remove(point)
  true
}

///|
pub fn Grid::clear_cost_rect(
  self : Grid,
  top_left : Point,
  width : Int,
  height : Int,
) -> Int {
  self.assert_rect(top_left, width, height)
  let mut removed = 0
  let mut y = 0
  while y < height {
    let mut x = 0
    while x < width {
      if self.clear_cost(top_left.offset(x, y)) {
        removed += 1
      }
      x += 1
    }
    y += 1
  }
  removed
}

///|
pub fn Grid::terrain_cost(self : Grid, point : Point) -> Int? {
  guard self.contains(point) else { return None }
  Some(self.terrain.get_or_default(point, 1))
}

///|
pub fn Grid::terrain_cells(self : Grid) -> Array[CellCost] {
  let cells : Array[CellCost] = []
  self.terrain.each((point, cost) => cells.push(CellCost::{ point, cost }))
  cells
}

///|
pub fn Grid::line_of_sight(self : Grid, from : Point, to : Point) -> Bool {
  guard self.is_open(from) && self.is_open(to) else { return false }
  let mut x = from.x
  let mut y = from.y
  let dx = (to.x - from.x).abs()
  let dy = (to.y - from.y).abs()
  let step_x = step_toward(from.x, to.x)
  let step_y = step_toward(from.y, to.y)
  let mut err = dx - dy
  while true {
    if !self.is_open(Point::{ x, y }) {
      return false
    }
    if x == to.x && y == to.y {
      return true
    }
    let twice = err * 2
    if twice > -dy {
      err -= dy
      x += step_x
    }
    if twice < dx {
      err += dx
      y += step_y
    }
  }
  true
}

///|
pub fn Grid::smooth_path(self : Grid, nodes : Array[Point]) -> Array[Point] {
  guard nodes.length() > 0 else { return [] }
  guard nodes.length() > 2 else { return nodes.copy() }
  let out : Array[Point] = []
  let mut anchor = 0
  out.push(nodes[0])
  while anchor < nodes.length() - 1 {
    let mut candidate = nodes.length() - 1
    while candidate > anchor + 1 &&
          !self.line_of_sight(nodes[anchor], nodes[candidate]) {
      candidate -= 1
    }
    out.push(nodes[candidate])
    anchor = candidate
  }
  out
}

///|
pub fn Grid::path_cost4(self : Grid, nodes : Array[Point]) -> Int? {
  self.path_cost_by(nodes, point => self.neighbors4(point))
}

///|
pub fn Grid::path_cost8(self : Grid, nodes : Array[Point]) -> Int? {
  self.path_cost_by(nodes, point => self.neighbors8(point))
}

///|
pub fn Grid::path_valid4(self : Grid, nodes : Array[Point]) -> Bool {
  self.path_cost4(nodes) is Some(_)
}

///|
pub fn Grid::path_valid8(self : Grid, nodes : Array[Point]) -> Bool {
  self.path_cost8(nodes) is Some(_)
}

///|
pub fn Grid::reachable_points4(self : Grid, start : Point) -> Array[Point] {
  self.reachable_points_by(start, point => self.neighbors4(point))
}

///|
pub fn Grid::reachable_points8(self : Grid, start : Point) -> Array[Point] {
  self.reachable_points_by(start, point => self.neighbors8(point))
}

///|
pub fn Grid::open_regions4(self : Grid) -> Array[Array[Point]] {
  self.open_regions_by(point => self.neighbors4(point))
}

///|
pub fn Grid::open_regions8(self : Grid) -> Array[Array[Point]] {
  self.open_regions_by(point => self.neighbors8(point))
}

///|
pub fn Grid::component_count4(self : Grid) -> Int {
  self.open_regions4().length()
}

///|
pub fn Grid::component_count8(self : Grid) -> Int {
  self.open_regions8().length()
}

///|
pub fn Grid::is_fully_connected4(self : Grid) -> Bool {
  self.component_count4() <= 1
}

///|
pub fn Grid::is_fully_connected8(self : Grid) -> Bool {
  self.component_count8() <= 1
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
pub fn Grid::bidirectional_astar4(
  self : Grid,
  start : Point,
  goal : Point,
) -> Path[Point]? {
  guard self.is_open(start) && self.is_open(goal) else { return None }
  self.to_graph4().bidirectional_astar(start, goal, manhattan)
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
pub fn Grid::bidirectional_astar8(
  self : Grid,
  start : Point,
  goal : Point,
) -> Path[Point]? {
  guard self.is_open(start) && self.is_open(goal) else { return None }
  self.to_graph8().bidirectional_astar(start, goal, octile)
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

///|
fn Grid::path_cost_by(
  self : Grid,
  nodes : Array[Point],
  neighbors : (Point) -> Array[Edge[Point]],
) -> Int? {
  guard nodes.length() > 0 else { return None }
  guard self.is_open(nodes[0]) else { return None }
  let mut total = 0
  let mut index = 0
  while index + 1 < nodes.length() {
    let from = nodes[index]
    let to = nodes[index + 1]
    guard self.is_open(to) else { return None }
    let mut found = false
    let mut best = 0
    for edge in neighbors(from) {
      if edge.to == to {
        if !found || edge.cost < best {
          found = true
          best = edge.cost
        }
      }
    }
    guard found else { return None }
    total += best
    index += 1
  }
  Some(total)
}

///|
fn Grid::reachable_points_by(
  self : Grid,
  start : Point,
  neighbors : (Point) -> Array[Edge[Point]],
) -> Array[Point] {
  guard self.is_open(start) else { return [] }
  let visited : @hashset.HashSet[Point] = @hashset.HashSet([])
  let queue : Array[Point] = []
  let mut head = 0
  visited.add(start)
  queue.push(start)
  while head < queue.length() {
    let current = queue[head]
    head += 1
    for edge in neighbors(current) {
      if !visited.contains(edge.to) {
        visited.add(edge.to)
        queue.push(edge.to)
      }
    }
  }
  queue
}

///|
fn Grid::open_regions_by(
  self : Grid,
  neighbors : (Point) -> Array[Edge[Point]],
) -> Array[Array[Point]] {
  let seen : @hashset.HashSet[Point] = @hashset.HashSet([])
  let regions : Array[Array[Point]] = []
  for point in self.open_points() {
    if seen.contains(point) {
      continue
    }
    let region = self.reachable_points_by(point, neighbors)
    for item in region {
      seen.add(item)
    }
    regions.push(region)
  }
  regions
}

///|
fn step_toward(from : Int, to : Int) -> Int {
  if from < to {
    1
  } else if from > to {
    -1
  } else {
    0
  }
}
