using Documenter
using AbaqusBuilder
using AbaqusBuilder.Keyword
using AbaqusBuilder.Mesh
using AbaqusBuilder.IO
using AbaqusBuilder.Scripts

makedocs(
    sitename = "AbaqusBuilder.jl",
    modules  = [AbaqusBuilder, AbaqusBuilder.Keyword, AbaqusBuilder.Mesh, AbaqusBuilder.IO, AbaqusBuilder.Scripts],
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
