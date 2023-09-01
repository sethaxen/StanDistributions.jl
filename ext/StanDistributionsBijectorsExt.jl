module StanDistributionsBijectorsExt

if isdefined(Base, :get_extension)
    using Bijectors: Bijectors
    using BridgeStan: BridgeStan
    using StanDistributions: StanDistributions
else  # using Requires
    using ..Bijectors: Bijectors
    using ..BridgeStan: BridgeStan
    using ..StanDistributions: StanDistributions
end

function Bijectors.transformed(dist::StanDistributions.ConstrainedStanDistribution)
    return StanDistributions._unconstrain(dist)
end
Bijectors.transformed(dist::StanDistributions.UnconstrainedStanDistribution) = dist

struct StanBijector <: Bijectors.Bijector
    model::BridgeStan.StanModel
end

function Bijectors.bijector(dist::StanDistributions.ConstrainedStanDistribution)
    return StanBijector(dist.model)
end
Bijectors.bijector(::StanDistributions.UnconstrainedStanDistribution) = identity

function Bijectors.transform(b::StanBijector, x::AbstractVector{<:Real})
    return BridgeStan.param_unconstrain(
        b.model, StanDistributions._convert_to_stan_array(x)
    )
end
function Bijectors.transform(b::Bijectors.Inverse{StanBijector}, y::AbstractVector{<:Real})
    return BridgeStan.param_constrain(
        Bijectors.inverse(b).model, StanDistributions._convert_to_stan_array(y)
    )
end

function Bijectors.output_length(b::StanBijector, ::Int)
    return BridgeStan.param_unc_num(b.model)
end

end  # module
