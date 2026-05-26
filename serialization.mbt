///|
priv struct StringGraphData {
  nodes : Array[String]
  arcs : Array[Arc[String]]
} derive(ToJson, FromJson)

///|
priv struct GridData {
  width : Int
  height : Int
  blocked : Array[Point]
  terrain : Array[CellCost]
} derive(ToJson, FromJson)

///|
pub fn Graph::to_json(self : Graph[String]) -> Json {
  StringGraphData::{
    nodes: sorted_strings(self.nodes()),
    arcs: sorted_string_arcs(self.arcs()),
  }.to_json()
}

///|
pub fn Graph::to_json_string(self : Graph[String]) -> String {
  self.to_json().stringify(indent=2)
}

///|
pub fn Graph::from_json_string(text : String) -> Graph[String]? {
  try {
    let json = @json.parse(text)
    let data : StringGraphData = @json.from_json(json)
    graph_from_data(data)
  } catch {
    _ => None
  }
}

///|
pub fn Graph::to_text(self : Graph[String]) -> String {
  let out = StringBuilder()
  out.write_string("# moonpath graph v1\n")
  for node in sorted_strings(self.nodes()) {
    out.write_string("node\t")
    out.write_string(node.to_json().stringify())
    out.write_char('\n')
  }
  for arc in sorted_string_arcs(self.arcs()) {
    out.write_string("arc\t")
    out.write_string(arc.from.to_json().stringify())
    out.write_char('\t')
    out.write_string(arc.to.to_json().stringify())
    out.write_char('\t')
    out.write_object(arc.cost)
    out.write_char('\n')
  }
  out.to_string()
}

///|
pub fn Graph::from_text(text : String) -> Graph[String]? {
  let nodes : Array[String] = []
  let arcs : Array[Arc[String]] = []
  for raw in text.split("\n") {
    let line = raw.trim()
    if line.is_empty() || line.has_prefix("#") {
      continue
    }
    let parts = line.split("\t").to_array()
    if parts.length() == 2 && parts[0].equal_to_string("node") {
      match parse_json_string(parts[1]) {
        Some(node) => nodes.push(node)
        None => return None
      }
    } else if parts.length() == 4 && parts[0].equal_to_string("arc") {
      match
        (
          parse_json_string(parts[1]),
          parse_json_string(parts[2]),
          parse_int(parts[3]),
        ) {
        (Some(from), Some(to), Some(cost)) => arcs.push(Arc::{ from, to, cost })
        _ => return None
      }
    } else {
      return None
    }
  }
  graph_from_data(StringGraphData::{ nodes, arcs })
}

///|
pub fn Grid::to_json(self : Grid) -> Json {
  GridData::{
    width: self.width,
    height: self.height,
    blocked: sorted_points(self.blocked_points()),
    terrain: sorted_cell_costs(self.terrain_cells()),
  }.to_json()
}

///|
pub fn Grid::to_json_string(self : Grid) -> String {
  self.to_json().stringify(indent=2)
}

///|
pub fn Grid::from_json_string(text : String) -> Grid? {
  try {
    let json = @json.parse(text)
    let data : GridData = @json.from_json(json)
    grid_from_data(data)
  } catch {
    _ => None
  }
}

///|
pub fn Grid::to_text(self : Grid) -> String {
  let out = StringBuilder()
  out.write_string("# moonpath grid v1\n")
  out.write_string("grid\t")
  out.write_object(self.width)
  out.write_char('\t')
  out.write_object(self.height)
  out.write_char('\n')
  for point in sorted_points(self.blocked_points()) {
    out.write_string("blocked\t")
    out.write_object(point.x)
    out.write_char('\t')
    out.write_object(point.y)
    out.write_char('\n')
  }
  for cell in sorted_cell_costs(self.terrain_cells()) {
    out.write_string("terrain\t")
    out.write_object(cell.point.x)
    out.write_char('\t')
    out.write_object(cell.point.y)
    out.write_char('\t')
    out.write_object(cell.cost)
    out.write_char('\n')
  }
  out.to_string()
}

///|
pub fn Grid::from_text(text : String) -> Grid? {
  let mut width : Int? = None
  let mut height : Int? = None
  let blocked : Array[Point] = []
  let terrain : Array[CellCost] = []
  for raw in text.split("\n") {
    let line = raw.trim()
    if line.is_empty() || line.has_prefix("#") {
      continue
    }
    let parts = line.split("\t").to_array()
    if parts.length() == 3 && parts[0].equal_to_string("grid") {
      match (parse_int(parts[1]), parse_int(parts[2])) {
        (Some(w), Some(h)) => {
          width = Some(w)
          height = Some(h)
        }
        _ => return None
      }
    } else if parts.length() == 3 && parts[0].equal_to_string("blocked") {
      match (parse_int(parts[1]), parse_int(parts[2])) {
        (Some(x), Some(y)) => blocked.push(Point::new(x, y))
        _ => return None
      }
    } else if parts.length() == 4 && parts[0].equal_to_string("terrain") {
      match (parse_int(parts[1]), parse_int(parts[2]), parse_int(parts[3])) {
        (Some(x), Some(y), Some(cost)) =>
          terrain.push(CellCost::{ point: Point::new(x, y), cost })
        _ => return None
      }
    } else {
      return None
    }
  }
  match (width, height) {
    (Some(w), Some(h)) =>
      grid_from_data(GridData::{ width: w, height: h, blocked, terrain })
    _ => None
  }
}

///|
fn graph_from_data(data : StringGraphData) -> Graph[String]? {
  match Graph::try_from_arcs(data.arcs) {
    Some(graph) => {
      for node in data.nodes {
        graph.add_node(node)
      }
      Some(graph)
    }
    None => None
  }
}

///|
fn grid_from_data(data : GridData) -> Grid? {
  guard data.width >= 0 && data.height >= 0 else { return None }
  for cell in data.terrain {
    guard cell.cost >= 1 else { return None }
  }
  Some(Grid::from_parts(data.width, data.height, data.blocked, data.terrain))
}

///|
fn sorted_strings(items : Array[String]) -> Array[String] {
  let out = items.copy()
  out.sort()
  out
}

///|
fn sorted_string_arcs(arcs : Array[Arc[String]]) -> Array[Arc[String]] {
  let out = arcs.copy()
  out.sort_by(fn(a, b) {
    let from_cmp = a.from.lexical_compare(b.from)
    if from_cmp != 0 {
      from_cmp
    } else {
      let to_cmp = a.to.lexical_compare(b.to)
      if to_cmp != 0 {
        to_cmp
      } else {
        a.cost - b.cost
      }
    }
  })
  out
}

///|
fn sorted_points(points : Array[Point]) -> Array[Point] {
  let out = points.copy()
  out.sort_by(compare_points)
  out
}

///|
fn sorted_cell_costs(cells : Array[CellCost]) -> Array[CellCost] {
  let out = cells.copy()
  out.sort_by(fn(a, b) {
    let point_cmp = compare_points(a.point, b.point)
    if point_cmp != 0 {
      point_cmp
    } else {
      a.cost - b.cost
    }
  })
  out
}

///|
fn compare_points(a : Point, b : Point) -> Int {
  if a.y != b.y {
    a.y - b.y
  } else {
    a.x - b.x
  }
}

///|
fn parse_json_string(text : StringView) -> String? {
  try {
    let json = @json.parse(text)
    let value : String = @json.from_json(json)
    Some(value)
  } catch {
    _ => None
  }
}

///|
fn parse_int(text : StringView) -> Int? {
  Some(@string.parse_int(text)) catch {
    _ => None
  }
}
