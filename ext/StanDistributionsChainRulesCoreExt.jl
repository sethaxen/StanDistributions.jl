module StanDistributionsChainRulesCoreExt

if isdefined(Base, :get_extension)
    using Distributions: Distributions
    using ChainRulesCore: ChainRulesCore
    using StanDistributions: StanDistributions
else  # using Requires
    using ..Distributions: Distributions
    using ..ChainRulesCore: ChainRulesCore
    using ..StanDistributions: StanDistributions
end

function ChainRulesCore.frule(
    ::typeof(Distributions.logpdf),
    (_, _, Δy),
    dist::StanDistributions.UnconstrainedStanDistribution,
    y::AbstractVector{<:Real},
)
    lp, ∂lp_∂y = StanDistributions._logpdf_and_gradient(
        dist, StanDistributions._convert_to_stan_array(y)
    )
    ∂lp = ∂lp_∂y'Δy
    return lp, ∂lp
end

function ChainRulesCore.rrule(
    ::typeof(Distributions.logpdf),
    dist::StanDistributions.UnconstrainedStanDistribution,
    y::AbstractVector{<:Real},
)
    projecty = ChainRulesCore.ProjectTo(y)
    lp, ∂lp_∂y = StanDistributions._logpdf_and_gradient(
        dist, StanDistributions._convert_to_stan_array(y)
    )
    function logpdf_pullback(Δlp)
        ∂x = projecty(∂lp_∂y * Δlp)
        return ChainRulesCore.NoTangent(), ChainRulesCore.NoTangent(), ∂x
    end
    return lp, logpdf_pullback
end

end  # module
