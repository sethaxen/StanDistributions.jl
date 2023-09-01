module StanDistributionsBijectorsExt

if isdefined(Base, :get_extension)
    using Bijectors: Bijectors
    using StanDistributions: StanDistributions
else  # using Requires
    using ..Bijectors: Bijectors
    using ..StanDistributions: StanDistributions
end

function Bijectors.transformed(dist::StanDistributions.ConstrainedStanDistribution)
    return StanDistributions._unconstrain(dist)
end
Bijectors.transformed(dist::StanDistributions.UnconstrainedStanDistribution) = dist

end  # module
