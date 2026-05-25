# MoonPath

MoonPath is a MoonBit graph algorithms and pathfinding library. It targets reusable infrastructure for MoonBit ecosystem projects: game maps, routing tools, compiler passes, dependency planning, workflow engines, visualization tools, and any code that needs graph traversal.

This repository is prepared for the `MoonBit 开源生态项目贡献赛` track. The current implementation includes a usable core, tests, a runnable demo, CI configuration, and contest submission materials under `docs/`.

## Features

- Directed weighted graph with explicit nodes and edges.
- BFS for shallow unweighted paths.
- Dijkstra shortest path for non-negative weighted graphs.
- A* search with custom heuristic functions.
- Reachability, connected components, and topological sort.
- Rectangular grid helpers with 4-neighbor and 8-neighbor pathfinding.
- Blackbox tests covering graph search, cycle detection, grid routing, and heuristic determinism.

## Install

Install MoonBit from the official site, then run:

```powershell
moon update
moon build
moon test
```

This repository was verified with:

```text
moon 0.1.20260522
moonc v0.9.3
```

## Usage

```moonbit
test "dijkstra demo" {
  let graph = @moonpath.Graph::new()
  graph.add_edge("A", "B", 4)
  graph.add_edge("A", "C", 1)
  graph.add_edge("C", "B", 2)
  graph.add_edge("B", "D", 1)
  guard graph.dijkstra("A", "D") is Some(path) else {
    fail("expected a path")
  }
  assert_eq(path.cost, 4)
  assert_true(path.nodes == ["A", "C", "B", "D"])
}
```

Grid pathfinding:

```moonbit
test "grid demo" {
  let grid = @moonpath.Grid::from_blocked(
    5,
    4,
    [@moonpath.Point::{ x: 1, y: 0 }, @moonpath.Point::{ x: 1, y: 1 }],
  )
  let start = @moonpath.Point::{ x: 0, y: 0 }
  let goal = @moonpath.Point::{ x: 4, y: 0 }
  assert_true(grid.astar4(start, goal) is Some(_))
}
```

Run the CLI demo:

```powershell
moon run cmd/main
```

Expected output:

```text
moonpath demo: cost=11, steps=11, visited=21
```

## Repository Layout

- `moonpath.mbt`: public library API and implementation.
- `moonpath_test.mbt`: blackbox behavior tests.
- `cmd/main`: runnable example.
- `.github/workflows/ci.yml`: CI for format, build, and tests.
- `docs/project-proposal.md`: one-page contest proposal draft.
- `docs/development-report.md`: completion report draft.
- `docs/submission-checklist.md`: GitHub/GitLink submission checklist.
- `docs/competition-requirements.md`: extracted requirements from the contest page.

## Roadmap

- Add bidirectional Dijkstra and A*.
- Add weighted grid terrain costs.
- Add graph serialization for JSON interchange.
- Add property tests for randomized graph invariants.
- Publish the package after the public repository is pushed.

## License

Apache-2.0.
