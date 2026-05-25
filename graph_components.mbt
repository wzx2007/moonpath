///|
priv struct ComponentDfsFrame[N] {
  node : N
  expanded : Bool
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
  let visited : @hashset.HashSet[N] = @hashset.HashSet([])
  let order : Array[N] = []
  for node in self.nodes() {
    if visited.contains(node) {
      continue
    }
    let stack : Array[ComponentDfsFrame[N]] = [
      ComponentDfsFrame::{ node, expanded: false },
    ]
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
      stack.push(ComponentDfsFrame::{ node: frame.node, expanded: true })
      for edge in self.neighbors(frame.node).rev() {
        if !visited.contains(edge.to) {
          stack.push(ComponentDfsFrame::{ node: edge.to, expanded: false })
        }
      }
    }
  }

  let reversed = self.transpose()
  let components : Array[Array[N]] = []
  let assigned : @hashset.HashSet[N] = @hashset.HashSet([])
  let mut index = order.length()
  while index > 0 {
    index -= 1
    let node = order[index]
    if assigned.contains(node) {
      continue
    }
    let component : Array[N] = []
    let stack : Array[N] = [node]
    assigned.add(node)
    while stack.length() > 0 {
      let current = stack.unsafe_pop()
      component.push(current)
      for edge in reversed.neighbors(current) {
        if !assigned.contains(edge.to) {
          assigned.add(edge.to)
          stack.push(edge.to)
        }
      }
    }
    components.push(component)
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
