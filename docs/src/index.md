# AbaqusBuilder.jl

```@docs
AbaqusBuilder
```

Julia package for programmatically generating Abaqus finite-element input files
and post-processing Abaqus output.

## Installation

```julia
] add https://github.com/runtosolve/AbaqusBuilder.jl
```

## Overview

| Module | Purpose |
|--------|---------|
| [Keywords](keywords.md) | Write `*Keyword` blocks for Abaqus `.inp` files |
| [Mesh](mesh.md) | Read node and element data from mesh files |
| [IO](io.md) | Parse Abaqus `.sta`, `.dat`, and nodal output files |
| [Scripts](scripts.md) | Generate Abaqus CAE Python scripts and macros |

## Quick Example

```julia
using AbaqusBuilder

lines = []

append!(lines, HEADING(["My Abaqus Model"]))
append!(lines, NODE(nodes))
append!(lines, ELEMENT(elements, "S4R", 4))
append!(lines, NSET(node_ids, "ALL_NODES"))
append!(lines, MATERIAL("Steel"))
append!(lines, ELASTIC(200e3, 0.3))
append!(lines, SHELL_SECTION("ALL_ELS", "Steel", "MIDSURFACE", 6.0, 5))
append!(lines, STEP("Step-1", "YES", 1000))
append!(lines, STATIC(0.01, 0.05, "YES", 0.01, 1.0, 1e-5, 0.1))
append!(lines, OUTPUT("field", "PRESELECT"))
append!(lines, NODE_OUTPUT(["U", "RF"]))
append!(lines, ELEMENT_OUTPUT("YES", ["S", "E"]))
push!(lines, "*End Step")

write_file("job.inp", lines)
```
