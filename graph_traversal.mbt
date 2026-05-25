///|
priv struct DfsFrame[N] {
  node : N
  expanded : Bool
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
pub fn[N : Hash + Eq] Graph::bfs_tree(
  self : Graph[N],
  start : N,
) -> Array[Arc[N]] {
  let visited : @hashset.HashSet[N] = @hashset.HashSet([])
  let queue : Array[N] = []
  let tree : Array[Arc[N]] = []
  let mut head = 0
  visited.add(start)
  queue.push(start)
  while head < queue.length() {
    let current = queue[head]
    head += 1
    for edge in self.neighbors(current) {
      if !visited.contains(edge.to) {
        visited.add(edge.to)
        tree.push(Arc::{ from: current, to: edge.to, cost: edge.cost })
        queue.push(edge.to)
      }
    }
  }
  tree
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
