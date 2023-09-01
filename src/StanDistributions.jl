module StanDistributions

using BridgeStan: BridgeStan
using Distributions: Distributions
using DocStringExtensions: FIELDS, TYPEDEF

export StanDistribution

include("utils.jl")
include("distribution.jl")

@static if !isdefined(Base, :get_extension)
    using Requires: @require

    function __init__()
        @require ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4" begin
            include("../ext/StanDistributionsChainRulesCoreExt.jl")
        end
        @require Bijectors = "76274a88-744f-5084-9051-94815aaf08c4" begin
            include("../ext/StanDistributionsBijectorsExt.jl")
        end
        @require ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210" begin
            include("../ext/StanDistributionsForwardDiffExt.jl")
        end
    end
end

end
