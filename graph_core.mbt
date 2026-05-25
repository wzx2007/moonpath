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
