module StanDistributions

using BridgeStan: BridgeStan
using Distributions: Distributions
using DocStringExtensions: FIELDS, TYPEDEF

export StanDistribution

include("utils.jl")
include("distribution.jl")

end
