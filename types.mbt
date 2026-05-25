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
