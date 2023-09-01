using StanDistributions
using Documenter

DocMeta.setdocmeta!(StanDistributions, :DocTestSetup, :(using StanDistributions); recursive=true)

makedocs(;
    modules=[StanDistributions],
    authors="Seth Axen <seth@sethaxen.com> and contributors",
    repo="https://github.com/sethaxen/StanDistributions.jl/blob/{commit}{path}#{line}",
    sitename="StanDistributions.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
