module StanDistributionsReverseDiffExt

if isdefined(Base, :get_extension)
    using Distributions: Distributions
    using ReverseDiff: ReverseDiff, Dual
    using StanDistributions: StanDistributions
else  # using Requires
    using ..Distributions: Distributions
    using ..ReverseDiff: ReverseDiff, Dual
    using ..StanDistributions: StanDistributions
end

ReverseDiff.@grad_from_chainrules Distributions.logpdf(
    dist::StanDistributions.UnconstrainedStanDistribution, y::ReverseDiff.TrackedArray
)

end  # module
