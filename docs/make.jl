using Documenter
using ABAQUSBuilder
using ABAQUSBuilder.Keyword
using ABAQUSBuilder.Mesh
using ABAQUSBuilder.IO
using ABAQUSBuilder.Scripts

makedocs(
    sitename = "ABAQUSBuilder.jl",
    modules  = [ABAQUSBuilder, ABAQUSBuilder.Keyword, ABAQUSBuilder.Mesh, ABAQUSBuilder.IO, ABAQUSBuilder.Scripts],
    format   = Documenter.HTML(prettyurls = false),
    pages    = [
        "Home"      => "index.md",
        "Keywords"  => "keywords.md",
        "Mesh"      => "mesh.md",
        "IO"        => "io.md",
        "Scripts"   => "scripts.md",
    ],
    checkdocs = :exports,
)
