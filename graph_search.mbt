///|
priv struct HeapItem[N] {
  node : N
  priority : Int
  seq : Int
}

///|
priv struct PriorityQueue[N] {
  heap : Array[HeapItem[N]]
  mut next_seq : Int
}

///|
priv struct DagPathFrame[N] {
  node : N
  nodes : Array[N]
  cost : Int
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
pub fn[N] Path::node_count(self : Path[N]) -> Int {
  self.nodes.length()
}

///|
pub fn[N] Path::edge_count(self : Path[N]) -> Int {
  if self.nodes.length() == 0 {
    0
  } else {
    self.nodes.length() - 1
  }
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
pub fn[N : Hash + Eq] Graph::bidirectional_astar(
  self : Graph[N],
  start : N,
  goal : N,
  heuristic : (N, N) -> Int,
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
  forward.push(start, heuristic(start, goal))
  backward.push(goal, heuristic(goal, start))
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
                  forward.push(edge.to, next_cost + heuristic(edge.to, goal))
                }
              None => {
                dist_forward.set(edge.to, next_cost)
                parents_forward.set(edge.to, current)
                forward.push(edge.to, next_cost + heuristic(edge.to, goal))
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
                  backward.push(edge.to, next_cost + heuristic(edge.to, start))
                }
              None => {
                dist_backward.set(edge.to, next_cost)
                parents_backward.set(edge.to, current)
                backward.push(edge.to, next_cost + heuristic(edge.to, start))
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
pub fn[N : Hash + Eq] Graph::dag_longest_path(
  self : Graph[N],
  start : N,
  goal : N,
) -> Path[N]? {
  guard self.contains_node(start) && self.contains_node(goal) else {
    return None
  }
  guard self.topological_sort() is Some(order) else { return None }
  let dist : @hashmap.HashMap[N, Int] = @hashmap.HashMap([])
  let parents : @hashmap.HashMap[N, N] = @hashmap.HashMap([])
  dist.set(start, 0)
  for node in order {
    match dist.get(node) {
      Some(current_cost) =>
        for edge in self.neighbors(node) {
          let next_cost = current_cost + edge.cost
          match dist.get(edge.to) {
            Some(existing) =>
              if next_cost > existing {
                dist.set(edge.to, next_cost)
                parents.set(edge.to, node)
              }
            None => {
              dist.set(edge.to, next_cost)
              parents.set(edge.to, node)
            }
          }
        }
      None => ()
    }
  }
  match dist.get(goal) {
    Some(cost) =>
      Some(Path::{
        cost,
        nodes: reconstruct_path(parents, start, goal),
        visited: dist.length(),
      })
    None => None
  }
}

///|
pub fn[N : Hash + Eq] Graph::dag_paths(
  self : Graph[N],
  start : N,
  goal : N,
) -> Array[Path[N]] {
  guard self.contains_node(start) && self.contains_node(goal) else { return [] }
  guard self.is_acyclic() else { return [] }
  let out : Array[Path[N]] = []
  let stack : Array[DagPathFrame[N]] = [
    DagPathFrame::{ node: start, nodes: [start], cost: 0 },
  ]
  while stack.length() > 0 {
    let frame = stack.unsafe_pop()
    if frame.node == goal {
      out.push(Path::{
        cost: frame.cost,
        nodes: frame.nodes,
        visited: frame.nodes.length(),
      })
      continue
    }
    for edge in self.neighbors(frame.node).rev() {
      let next_nodes = frame.nodes.copy()
      next_nodes.push(edge.to)
      stack.push(DagPathFrame::{
        node: edge.to,
        nodes: next_nodes,
        cost: frame.cost + edge.cost,
      })
    }
  }
  out
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
pub fn[N : Hash + Eq] Graph::shortest_path_tree(
  self : Graph[N],
  start : N,
) -> Array[Arc[N]] {
  guard self.contains_node(start) else { return [] }
  let frontier = PriorityQueue::new()
  let dist : @hashmap.HashMap[N, Int] = @hashmap.HashMap([])
  let parents : @hashmap.HashMap[N, Arc[N]] = @hashmap.HashMap([])
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
            parents.set(edge.to, Arc::{
              from: current,
              to: edge.to,
              cost: edge.cost,
            })
            frontier.push(edge.to, next_cost)
          }
        None => {
          dist.set(edge.to, next_cost)
          parents.set(edge.to, Arc::{
            from: current,
            to: edge.to,
            cost: edge.cost,
          })
          frontier.push(edge.to, next_cost)
        }
      }
    }
  }
  let tree : Array[Arc[N]] = []
  parents.each((_node, arc) => tree.push(arc))
  tree
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
pub fn[N : Hash + Eq] bellman_ford_distances(
  nodes : Array[N],
  arcs : Array[Arc[N]],
  start : N,
) -> @hashmap.HashMap[N, Int]? {
  match bellman_ford_scan(nodes, arcs, start) {
    Some((dist, _parents)) => Some(dist)
    None => None
  }
}

///|
pub fn[N : Hash + Eq] bellman_ford_path(
  nodes : Array[N],
  arcs : Array[Arc[N]],
  start : N,
  goal : N,
) -> Path[N]? {
  match bellman_ford_scan(nodes, arcs, start) {
    Some((dist, parents)) =>
      match dist.get(goal) {
        Some(cost) =>
          Some(Path::{
            cost,
            nodes: reconstruct_arc_path(parents, start, goal),
            visited: dist.length(),
          })
        None => None
      }
    None => None
  }
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
fn[N : Hash + Eq] bellman_ford_scan(
  nodes : Array[N],
  arcs : Array[Arc[N]],
  start : N,
) -> (@hashmap.HashMap[N, Int], @hashmap.HashMap[N, Arc[N]])? {
  let universe = collect_bellman_ford_nodes(nodes, arcs, start)
  let dist : @hashmap.HashMap[N, Int] = @hashmap.HashMap([])
  let parents : @hashmap.HashMap[N, Arc[N]] = @hashmap.HashMap([])
  dist.set(start, 0)
  let mut round = 0
  while round + 1 < universe.length() {
    let mut changed = false
    for arc in arcs {
      match dist.get(arc.from) {
        Some(current_cost) => {
          let next_cost = current_cost + arc.cost
          match dist.get(arc.to) {
            Some(existing) =>
              if next_cost < existing {
                dist.set(arc.to, next_cost)
                parents.set(arc.to, arc)
                changed = true
              }
            None => {
              dist.set(arc.to, next_cost)
              parents.set(arc.to, arc)
              changed = true
            }
          }
        }
        None => ()
      }
    }
    if !changed {
      break
    }
    round += 1
  }
  for arc in arcs {
    match dist.get(arc.from) {
      Some(current_cost) => {
        let next_cost = current_cost + arc.cost
        match dist.get(arc.to) {
          Some(existing) => if next_cost < existing { return None }
          None => return None
        }
      }
      None => ()
    }
  }
  Some((dist, parents))
}

///|
fn[N : Hash + Eq] collect_bellman_ford_nodes(
  nodes : Array[N],
  arcs : Array[Arc[N]],
  start : N,
) -> Array[N] {
  let seen : @hashset.HashSet[N] = @hashset.HashSet([])
  let out : Array[N] = []
  add_unique_node(out, seen, start)
  for node in nodes {
    add_unique_node(out, seen, node)
  }
  for arc in arcs {
    add_unique_node(out, seen, arc.from)
    add_unique_node(out, seen, arc.to)
  }
  out
}

///|
fn[N : Hash + Eq] add_unique_node(
  out : Array[N],
  seen : @hashset.HashSet[N],
  node : N,
) -> Unit {
  if !seen.contains(node) {
    seen.add(node)
    out.push(node)
  }
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
fn[N : Hash + Eq] reconstruct_arc_path(
  parents : @hashmap.HashMap[N, Arc[N]],
  start : N,
  goal : N,
) -> Array[N] {
  let path : Array[N] = []
  let mut current = goal
  path.push(current)
  while current != start {
    match parents.get(current) {
      Some(parent) => {
        current = parent.from
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
