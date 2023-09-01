module StanDistributionsForwardDiffExt

if isdefined(Base, :get_extension)
    using Distributions: Distributions
    using ForwardDiff: ForwardDiff, Dual
    using StanDistributions: StanDistributions
else  # using Requires
    using ..Distributions: Distributions
    using ..ForwardDiff: ForwardDiff, Dual
    using ..StanDistributions: StanDistributions
end

function Distributions.logpdf(
    dist::StanDistributions.UnconstrainedStanDistribution, x_∂x::AbstractVector{<:Dual{T}}
) where {T}
    x = StanDistributions._convert_to_stan_array(map(ForwardDiff.value, x_∂x))
    ∂x = map(ForwardDiff.partials, x_∂x)
    lp, ∂lp_∂x = StanDistributions._logpdf_and_gradient(dist, x)
    ∂lp = ∂lp_∂x'∂x
    return ForwardDiff.Dual{T}(lp, ∂lp)
end

end  # module
