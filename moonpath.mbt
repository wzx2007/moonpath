///|
/// A weighted directed edge.
pub(all) struct Edge[N] {
  to : N
  cost : Int
} derive(Eq, Debug)

///|
/// A successful shortest-path query.
pub(all) struct Path[N] {
  cost : Int
  nodes : Array[N]
  visited : Int
} derive(Eq, Debug)

///|
/// A mutable directed weighted graph backed by hash maps.
pub(all) struct Graph[N] {
  mut adjacency : @hashmap.HashMap[N, Array[Edge[N]]]
}

///|
/// A grid point for tile-based pathfinding.
pub(all) struct Point {
  x : Int
  y : Int
} derive(Eq, Hash, Debug)

///|
/// A rectangular grid with blocked cells.
pub(all) struct Grid {
  width : Int
  height : Int
  mut blocked : @hashset.HashSet[Point]
  mut terrain : @hashmap.HashMap[Point, Int]
}

///|
priv struct HeapItem[N] {
  node : N
  priority : Int
  seq : Int
}

///|
priv struct DfsFrame[N] {
  node : N
  expanded : Bool
}

///|
priv struct PriorityQueue[N] {
  heap : Array[HeapItem[N]]
  mut next_seq : Int
}

///|
pub fn[N : Hash + Eq] Graph::new() -> Graph[N] {
  Graph::{ adjacency: @hashmap.HashMap([]) }
}

///|
pub fn[N : Hash + Eq] Graph::add_node(self : Graph[N], node : N) -> Unit {
  self.adjacency.get_or_init(node, () => Array::new()) |> ignore
}

///|
pub fn[N : Hash + Eq] Graph::add_edge(
  self : Graph[N],
  from : N,
  to : N,
  cost : Int,
) -> Unit {
  guard cost >= 0 else { abort("edge cost must be non-negative") }
  self.adjacency.get_or_init(from, () => Array::new()).push(Edge::{ to, cost })
  self.add_node(to)
}

///|
pub fn[N : Hash + Eq] Graph::add_undirected_edge(
  self : Graph[N],
  a : N,
  b : N,
  cost : Int,
) -> Unit {
  self.add_edge(a, b, cost)
  self.add_edge(b, a, cost)
}

///|
pub fn[N : Hash + Eq] Graph::neighbors(
  self : Graph[N],
  node : N,
) -> Array[Edge[N]] {
  match self.adjacency.get(node) {
    Some(edges) => edges.copy()
    None => []
  }
}

///|
pub fn[N] Graph::nodes(self : Graph[N]) -> Array[N] {
  self.adjacency.keys().collect()
}

///|
pub fn[N] Graph::node_count(self : Graph[N]) -> Int {
  self.adjacency.length()
}

///|
pub fn[N] Graph::edge_count(self : Graph[N]) -> Int {
  let mut total = 0
  self.adjacency.each((_node, edges) => total += edges.length())
  total
}

///|
pub fn[N : Hash + Eq] Graph::contains_node(self : Graph[N], node : N) -> Bool {
  self.adjacency.contains(node)
}

///|
pub fn[N : Hash + Eq] Graph::contains_edge(
  self : Graph[N],
  from : N,
  to : N,
) -> Bool {
  for edge in self.neighbors(from) {
    if edge.to == to {
      return true
    }
  }
  false
}

///|
pub fn[N : Hash + Eq] Graph::out_degree(self : Graph[N], node : N) -> Int {
  self.neighbors(node).length()
}

///|
pub fn[N : Eq] Graph::in_degree(self : Graph[N], node : N) -> Int {
  let mut count = 0
  self.adjacency.each((_from, edges) => {
    for edge in edges {
      if edge.to == node {
        count += 1
      }
    }
  })
  count
}

///|
pub fn[N : Hash + Eq] Graph::transpose(self : Graph[N]) -> Graph[N] {
  let reversed = Graph::new()
  for node in self.nodes() {
    reversed.add_node(node)
  }
  self.adjacency.each((from, edges) => {
    for edge in edges {
      reversed.add_edge(edge.to, from, edge.cost)
    }
  })
  reversed
}

///|
pub fn[N : Hash + Eq] Graph::bfs(
  self : Graph[N],
  start : N,
  goal : N,
) -> Path[N]? {
  let visited : @hashset.HashSet[N] = @hashset.HashSet([])
  let parents : @hashmap.HashMap[N, N] = @hashmap.HashMap([])
  let queue : Array[N] = []
  let mut head = 0
  visited.add(start)
  queue.push(start)
  while head < queue.length() {
    let current = queue[head]
    head += 1
    if current == goal {
      return Some(Path::{
        cost: path_edge_count(parents, start, goal),
        nodes: reconstruct_path(parents, start, goal),
        visited: visited.length(),
      })
    }
    for edge in self.neighbors(current) {
      if !visited.contains(edge.to) {
        visited.add(edge.to)
        parents.set(edge.to, current)
        queue.push(edge.to)
      }
    }
  }
  None
}

///|
pub fn[N : Hash + Eq] Graph::dijkstra(
  self : Graph[N],
  start : N,
  goal : N,
) -> Path[N]? {
  shortest_path(start, goal, node => self.neighbors(node), (_a, _b) => 0)
}

///|
pub fn[N : Hash + Eq] Graph::bidirectional_dijkstra(
  self : Graph[N],
  start : N,
  goal : N,
) -> Path[N]? {
  if start == goal {
    return Some(Path::{ cost: 0, nodes: [start], visited: 1 })
  }
  let reversed = self.transpose()
  let forward = PriorityQueue::new()
  let backward = PriorityQueue::new()
  let dist_forward : @hashmap.HashMap[N, Int] = @hashmap.HashMap([])
  let dist_backward : @hashmap.HashMap[N, Int] = @hashmap.HashMap([])
  let parents_forward : @hashmap.HashMap[N, N] = @hashmap.HashMap([])
  let parents_backward : @hashmap.HashMap[N, N] = @hashmap.HashMap([])
  let closed_forward : @hashset.HashSet[N] = @hashset.HashSet([])
  let closed_backward : @hashset.HashSet[N] = @hashset.HashSet([])
  let mut best : Int? = None
  let mut meeting : N? = None
  forward.push(start, 0)
  backward.push(goal, 0)
  dist_forward.set(start, 0)
  dist_backward.set(goal, 0)

  while true {
    let mut progressed = false
    match forward.pop_min() {
      Some(item) => {
        progressed = true
        let current = item.node
        if !closed_forward.contains(current) {
          closed_forward.add(current)
          let current_cost = dist_forward.get_or_default(current, 0)
          match dist_backward.get(current) {
            Some(other_cost) => {
              let candidate = current_cost + other_cost
              match best {
                Some(existing) =>
                  if candidate < existing {
                    best = Some(candidate)
                    meeting = Some(current)
                  }
                None => {
                  best = Some(candidate)
                  meeting = Some(current)
                }
              }
            }
            None => ()
          }
          for edge in self.neighbors(current) {
            let next_cost = current_cost + edge.cost
            match dist_forward.get(edge.to) {
              Some(existing) =>
                if next_cost < existing {
                  dist_forward.set(edge.to, next_cost)
                  parents_forward.set(edge.to, current)
                  forward.push(edge.to, next_cost)
                }
              None => {
                dist_forward.set(edge.to, next_cost)
                parents_forward.set(edge.to, current)
                forward.push(edge.to, next_cost)
              }
            }
          }
        }
      }
      None => ()
    }
    match backward.pop_min() {
      Some(item) => {
        progressed = true
        let current = item.node
        if !closed_backward.contains(current) {
          closed_backward.add(current)
          let current_cost = dist_backward.get_or_default(current, 0)
          match dist_forward.get(current) {
            Some(other_cost) => {
              let candidate = current_cost + other_cost
              match best {
                Some(existing) =>
                  if candidate < existing {
                    best = Some(candidate)
                    meeting = Some(current)
                  }
                None => {
                  best = Some(candidate)
                  meeting = Some(current)
                }
              }
            }
            None => ()
          }
          for edge in reversed.neighbors(current) {
            let next_cost = current_cost + edge.cost
            match dist_backward.get(edge.to) {
              Some(existing) =>
                if next_cost < existing {
                  dist_backward.set(edge.to, next_cost)
                  parents_backward.set(edge.to, current)
                  backward.push(edge.to, next_cost)
                }
              None => {
                dist_backward.set(edge.to, next_cost)
                parents_backward.set(edge.to, current)
                backward.push(edge.to, next_cost)
              }
            }
          }
        }
      }
      None => ()
    }
    if !progressed {
      break
    }
  }

  match (best, meeting) {
    (Some(cost), Some(mid)) =>
      Some(Path::{
        cost,
        nodes: reconstruct_bidirectional_path(
          parents_forward, parents_backward, start, mid, goal,
        ),
        visited: closed_forward.length() + closed_backward.length(),
      })
    _ => None
  }
}

///|
pub fn[N : Hash + Eq] Graph::astar(
  self : Graph[N],
  start : N,
  goal : N,
  heuristic : (N, N) -> Int,
) -> Path[N]? {
  shortest_path(start, goal, node => self.neighbors(node), heuristic)
}

///|
pub fn[N : Hash + Eq] Graph::path_cost(
  self : Graph[N],
  nodes : Array[N],
) -> Int? {
  guard nodes.length() > 0 else { return None }
  let mut total = 0
  let mut index = 0
  while index + 1 < nodes.length() {
    let from = nodes[index]
    let to = nodes[index + 1]
    let mut found = false
    let mut best = 0
    for edge in self.neighbors(from) {
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
pub fn[N : Hash + Eq] Graph::distances_from(
  self : Graph[N],
  start : N,
) -> @hashmap.HashMap[N, Int] {
  let frontier = PriorityQueue::new()
  let dist : @hashmap.HashMap[N, Int] = @hashmap.HashMap([])
  let visited : @hashset.HashSet[N] = @hashset.HashSet([])
  frontier.push(start, 0)
  dist.set(start, 0)
  while frontier.pop_min() is Some(item) {
    let current = item.node
    if visited.contains(current) {
      continue
    }
    visited.add(current)
    let current_cost = dist.get_or_default(current, 0)
    for edge in self.neighbors(current) {
      let next_cost = current_cost + edge.cost
      match dist.get(edge.to) {
        Some(existing) =>
          if next_cost < existing {
            dist.set(edge.to, next_cost)
            frontier.push(edge.to, next_cost)
          }
        None => {
          dist.set(edge.to, next_cost)
          frontier.push(edge.to, next_cost)
        }
      }
    }
  }
  dist
}

///|
pub fn[N : Hash + Eq] Graph::shortest_distance(
  self : Graph[N],
  start : N,
  goal : N,
) -> Int? {
  self.distances_from(start).get(goal)
}

///|
pub fn[N : Hash + Eq] Graph::all_pairs_distances(
  self : Graph[N],
) -> @hashmap.HashMap[N, @hashmap.HashMap[N, Int]] {
  let out : @hashmap.HashMap[N, @hashmap.HashMap[N, Int]] = @hashmap.HashMap([])
  for node in self.nodes() {
    out.set(node, self.distances_from(node))
  }
  out
}

///|
pub fn[N : Hash + Eq] Graph::eccentricity(self : Graph[N], start : N) -> Int? {
  guard self.contains_node(start) else { return None }
  let distances = self.distances_from(start)
  let mut best = 0
  distances.each((_node, cost) => if cost > best { best = cost })
  Some(best)
}

///|
pub fn[N : Hash + Eq] Graph::diameter(self : Graph[N]) -> Int? {
  guard self.node_count() > 0 else { return None }
  let mut best = 0
  for node in self.nodes() {
    match self.eccentricity(node) {
      Some(value) => if value > best { best = value }
      None => ()
    }
  }
  Some(best)
}

///|
pub fn[N : Hash + Eq] Graph::reachable(self : Graph[N], start : N) -> Array[N] {
  let visited : @hashset.HashSet[N] = @hashset.HashSet([])
  let queue : Array[N] = []
  let mut head = 0
  visited.add(start)
  queue.push(start)
  while head < queue.length() {
    let current = queue[head]
    head += 1
    for edge in self.neighbors(current) {
      if !visited.contains(edge.to) {
        visited.add(edge.to)
        queue.push(edge.to)
      }
    }
  }
  visited.to_array()
}

///|
pub fn[N : Hash + Eq] Graph::has_path(
  self : Graph[N],
  start : N,
  goal : N,
) -> Bool {
  for node in self.reachable(start) {
    if node == goal {
      return true
    }
  }
  false
}

///|
pub fn[N : Hash + Eq] Graph::dfs_preorder(
  self : Graph[N],
  start : N,
) -> Array[N] {
  let visited : @hashset.HashSet[N] = @hashset.HashSet([])
  let stack : Array[N] = [start]
  let order : Array[N] = []
  while stack.length() > 0 {
    let current = stack.unsafe_pop()
    if visited.contains(current) {
      continue
    }
    visited.add(current)
    order.push(current)
    for edge in self.neighbors(current).rev() {
      if !visited.contains(edge.to) {
        stack.push(edge.to)
      }
    }
  }
  order
}

///|
pub fn[N : Hash + Eq] Graph::dfs_postorder(
  self : Graph[N],
  start : N,
) -> Array[N] {
  let visited : @hashset.HashSet[N] = @hashset.HashSet([])
  let stack : Array[DfsFrame[N]] = [DfsFrame::{ node: start, expanded: false }]
  let order : Array[N] = []
  while stack.length() > 0 {
    let frame = stack.unsafe_pop()
    if frame.expanded {
      order.push(frame.node)
      continue
    }
    if visited.contains(frame.node) {
      continue
    }
    visited.add(frame.node)
    stack.push(DfsFrame::{ node: frame.node, expanded: true })
    for edge in self.neighbors(frame.node).rev() {
      if !visited.contains(edge.to) {
        stack.push(DfsFrame::{ node: edge.to, expanded: false })
      }
    }
  }
  order
}

///|
pub fn[N : Hash + Eq] Graph::connected_components(
  self : Graph[N],
) -> Array[Array[N]] {
  self.weakly_connected_components()
}

///|
pub fn[N : Hash + Eq] Graph::weakly_connected_components(
  self : Graph[N],
) -> Array[Array[N]] {
  let undirected = Graph::new()
  for node in self.nodes() {
    undirected.add_node(node)
  }
  self.adjacency.each((from, edges) => {
    for edge in edges {
      undirected.add_undirected_edge(from, edge.to, edge.cost)
    }
  })
  let seen : @hashset.HashSet[N] = @hashset.HashSet([])
  let components : Array[Array[N]] = []
  for node in undirected.nodes() {
    if !seen.contains(node) {
      let component = undirected.reachable(node)
      for item in component {
        seen.add(item)
      }
      components.push(component)
    }
  }
  components
}

///|
pub fn[N : Hash + Eq] Graph::is_weakly_connected(self : Graph[N]) -> Bool {
  self.weakly_connected_components().length() <= 1
}

///|
pub fn[N : Hash + Eq] Graph::strongly_connected_components(
  self : Graph[N],
) -> Array[Array[N]] {
  let reversed = self.transpose()
  let assigned : @hashset.HashSet[N] = @hashset.HashSet([])
  let components : Array[Array[N]] = []
  for node in self.nodes() {
    if !assigned.contains(node) {
      let backward : @hashset.HashSet[N] = @hashset.HashSet([])
      for item in reversed.reachable(node) {
        backward.add(item)
      }
      let component : Array[N] = []
      for item in self.reachable(node) {
        if backward.contains(item) && !assigned.contains(item) {
          assigned.add(item)
          component.push(item)
        }
      }
      components.push(component)
    }
  }
  components
}

///|
pub fn[N : Hash + Eq] Graph::is_strongly_connected(self : Graph[N]) -> Bool {
  self.strongly_connected_components().length() <= 1
}

///|
pub fn[N : Hash + Eq] Graph::topological_sort(self : Graph[N]) -> Array[N]? {
  let indegree : @hashmap.HashMap[N, Int] = @hashmap.HashMap([])
  for node in self.nodes() {
    indegree.set(node, 0)
  }
  self.adjacency.each((_node, edges) => {
    for edge in edges {
      indegree.update_or_default(edge.to, 1, value => value + 1)
    }
  })
  let queue : Array[N] = []
  indegree.each((node, degree) => if degree == 0 { queue.push(node) })
  let order : Array[N] = []
  let mut head = 0
  while head < queue.length() {
    let node = queue[head]
    head += 1
    order.push(node)
    for edge in self.neighbors(node) {
      let next_degree = indegree.get_or_default(edge.to, 0) - 1
      indegree.set(edge.to, next_degree)
      if next_degree == 0 {
        queue.push(edge.to)
      }
    }
  }
  if order.length() == indegree.length() {
    Some(order)
  } else {
    None
  }
}

///|
pub fn[N : Hash + Eq] Graph::topological_layers(
  self : Graph[N],
) -> Array[Array[N]]? {
  let indegree : @hashmap.HashMap[N, Int] = @hashmap.HashMap([])
  for node in self.nodes() {
    indegree.set(node, 0)
  }
  self.adjacency.each((_node, edges) => {
    for edge in edges {
      indegree.update_or_default(edge.to, 1, value => value + 1)
    }
  })
  let mut frontier : Array[N] = []
  indegree.each((node, degree) => if degree == 0 { frontier.push(node) })
  let layers : Array[Array[N]] = []
  let mut processed = 0
  while frontier.length() > 0 {
    let layer = frontier
    let next : Array[N] = []
    for node in layer {
      processed += 1
      for edge in self.neighbors(node) {
        let next_degree = indegree.get_or_default(edge.to, 0) - 1
        indegree.set(edge.to, next_degree)
        if next_degree == 0 {
          next.push(edge.to)
        }
      }
    }
    layers.push(layer)
    frontier = next
  }
  if processed == indegree.length() {
    Some(layers)
  } else {
    None
  }
}

///|
pub fn[N : Hash + Eq] Graph::is_acyclic(self : Graph[N]) -> Bool {
  self.topological_sort() is Some(_)
}

///|
pub fn[N : Hash + Eq] shortest_path(
  start : N,
  goal : N,
  neighbors : (N) -> Array[Edge[N]],
  heuristic : (N, N) -> Int,
) -> Path[N]? {
  let frontier = PriorityQueue::new()
  let dist : @hashmap.HashMap[N, Int] = @hashmap.HashMap([])
  let parents : @hashmap.HashMap[N, N] = @hashmap.HashMap([])
  let visited : @hashset.HashSet[N] = @hashset.HashSet([])
  frontier.push(start, heuristic(start, goal))
  dist.set(start, 0)
  while frontier.pop_min() is Some(item) {
    let current = item.node
    if visited.contains(current) {
      continue
    }
    visited.add(current)
    if current == goal {
      return Some(Path::{
        cost: dist.get_or_default(current, 0),
        nodes: reconstruct_path(parents, start, goal),
        visited: visited.length(),
      })
    }
    let current_cost = dist.get_or_default(current, 0)
    for edge in neighbors(current) {
      let next_cost = current_cost + edge.cost
      match dist.get(edge.to) {
        Some(existing) =>
          if next_cost < existing {
            dist.set(edge.to, next_cost)
            parents.set(edge.to, current)
            frontier.push(edge.to, next_cost + heuristic(edge.to, goal))
          }
        None => {
          dist.set(edge.to, next_cost)
          parents.set(edge.to, current)
          frontier.push(edge.to, next_cost + heuristic(edge.to, goal))
        }
      }
    }
  }
  None
}

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
fn[N : Hash + Eq] reconstruct_path(
  parents : @hashmap.HashMap[N, N],
  start : N,
  goal : N,
) -> Array[N] {
  let path : Array[N] = []
  let mut current = goal
  path.push(current)
  while current != start {
    match parents.get(current) {
      Some(parent) => {
        current = parent
        path.push(current)
      }
      None => break
    }
  }
  path.rev()
}

///|
fn[N : Hash + Eq] reconstruct_bidirectional_path(
  parents_forward : @hashmap.HashMap[N, N],
  parents_backward : @hashmap.HashMap[N, N],
  start : N,
  meeting : N,
  goal : N,
) -> Array[N] {
  let path = reconstruct_path(parents_forward, start, meeting)
  let mut current = meeting
  while current != goal {
    match parents_backward.get(current) {
      Some(next) => {
        current = next
        path.push(current)
      }
      None => break
    }
  }
  path
}

///|
fn[N : Hash + Eq] path_edge_count(
  parents : @hashmap.HashMap[N, N],
  start : N,
  goal : N,
) -> Int {
  let mut current = goal
  let mut count = 0
  while current != start {
    match parents.get(current) {
      Some(parent) => {
        current = parent
        count += 1
      }
      None => return count
    }
  }
  count
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
fn[N] PriorityQueue::new() -> PriorityQueue[N] {
  PriorityQueue::{ heap: [], next_seq: 0 }
}

///|
fn[N] PriorityQueue::push(
  self : PriorityQueue[N],
  node : N,
  priority : Int,
) -> Unit {
  self.heap.push(HeapItem::{ node, priority, seq: self.next_seq })
  self.next_seq += 1
  self.sift_up(self.heap.length() - 1)
}

///|
fn[N] PriorityQueue::pop_min(self : PriorityQueue[N]) -> HeapItem[N]? {
  guard self.heap.length() > 0 else { return None }
  let first = self.heap[0]
  let last = self.heap.unsafe_pop()
  if self.heap.length() > 0 {
    self.heap[0] = last
    self.sift_down(0)
  }
  Some(first)
}

///|
fn[N] PriorityQueue::sift_up(self : PriorityQueue[N], index : Int) -> Unit {
  let mut child = index
  while child > 0 {
    let parent = (child - 1) / 2
    if heap_less(self.heap[child], self.heap[parent]) {
      self.swap(child, parent)
      child = parent
    } else {
      break
    }
  }
}

///|
fn[N] PriorityQueue::sift_down(self : PriorityQueue[N], index : Int) -> Unit {
  let mut parent = index
  while true {
    let left = parent * 2 + 1
    let right = left + 1
    let mut best = parent
    if left < self.heap.length() && heap_less(self.heap[left], self.heap[best]) {
      best = left
    }
    if right < self.heap.length() &&
      heap_less(self.heap[right], self.heap[best]) {
      best = right
    }
    if best == parent {
      break
    }
    self.swap(parent, best)
    parent = best
  }
}

///|
fn[N] PriorityQueue::swap(self : PriorityQueue[N], a : Int, b : Int) -> Unit {
  let tmp = self.heap[a]
  self.heap[a] = self.heap[b]
  self.heap[b] = tmp
}

///|
fn[N] heap_less(a : HeapItem[N], b : HeapItem[N]) -> Bool {
  a.priority < b.priority || (a.priority == b.priority && a.seq < b.seq)
}
