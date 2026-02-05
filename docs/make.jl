using Pkg
Pkg.activate(@__DIR__)
Pkg.develop(PackageSpec(path=joinpath(@__DIR__, "..")))
Pkg.instantiate()

using MemoryLayouts
using Documenter

DocMeta.setdocmeta!(MemoryLayouts, :DocTestSetup, :(using MemoryLayouts); recursive=true)

makedocs(;
    modules=[MemoryLayouts],
    authors="Joris Pinkse <pinkse@gmail.com> and contributors",
    sitename="MemoryLayouts.jl",
    warnonly=true,
    format=Documenter.HTML(;
        canonical="https://NittanyLion.github.io/MemoryLayouts.jl",
        edit_link="main",
        assets=["assets/custom.css"],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/NittanyLion/MemoryLayouts.jl",
    devbranch="main",
)
