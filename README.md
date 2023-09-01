# StanDistributions

[![Build Status](https://github.com/sethaxen/StanDistributions.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sethaxen/StanDistributions.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/sethaxen/StanDistributions.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/sethaxen/StanDistributions.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

StanDistributions wraps a Stan model as a `Distributions.Distribution` for use as a component in Distributions-based modeling workflows.

## Example

In this example, we load wrap the non-centered eight schools model in PosteriorDB as a distribution, unconstrain it with Bijectors, and then compute the gradient of the log-density with ForwardDiff.

```julia
julia> using Bijectors, Distributions, ForwardDiff, PosteriorDB, StanDistributions

julia> pdb = PosteriorDB.database();

julia> post = PosteriorDB.posterior(pdb, "eight_schools-eight_schools_noncentered");

julia> stan_file = cp(PosteriorDB.path(PosteriorDB.implementation(PosteriorDB.model(post), "stan")), "stan_file.stan")
"stan_file.stan"

julia> stan_data = PosteriorDB.load(PosteriorDB.dataset(post), String)
"{\n  \"J\": 8,\n  \"y\": [28, 8, -3, 7, -1, 1, 18, 12],\n  \"sigma\": [15, 10, 16, 11, 9, 11, 10, 18]\n}\n"

julia> length(dist)
10

julia> dist_unc = Bijectors.transformed(dist);

julia> length(dist_unc)
10

julia> y = randn(length(dist_unc));

julia> logpdf(dist_unc, y)
-11.42570710317857

julia> ForwardDiff.gradient(y -> logpdf(dist_unc, y), y)
10-element Vector{Float64}:
 -0.3094907146123641
 -1.8681569559774613
 -0.8848883640800906
 -0.9199745527858457
  1.6713490463069083
  0.23157025045691185
 -0.5435639885286974
  0.19815644328099136
  0.543535599336159
  1.0234549379906248
```
