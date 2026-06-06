using Documenter
using ABAQUS
using ABAQUS.Keyword
using ABAQUS.Mesh
using ABAQUS.IO
using ABAQUS.Scripts

makedocs(
    sitename = "ABAQUS.jl",
    modules  = [ABAQUS, ABAQUS.Keyword, ABAQUS.Mesh, ABAQUS.IO, ABAQUS.Scripts],
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
