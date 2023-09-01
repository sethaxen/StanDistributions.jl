"""
    $TYPEDEF

A  Stan model wrapped as a `Distributions.ContinuousMultivariateDistribution`.

This type only implements the following functions from the Distributions API:
- `insupport`
- `Base.length`
- `pdf`
- `logpdf`

# Fields

$FIELDS
"""
struct StanDistribution{unconstrained,nan_on_error} <:
       Distributions.ContinuousMultivariateDistribution
    "A Stan model"
    model::BridgeStan.StanModel
end

const ConstrainedStanDistribution{nan_on_error} = StanDistribution{false,nan_on_error}
const UnconstrainedStanDistribution{nan_on_error} = StanDistribution{true,nan_on_error}

"""
    StanDistribution(model::BridgeStan.StanModel; kwargs...)

Construct a `StanDistribution` from a `BridgeStan.StanModel`.

# Keywords

- `unconstrained=false`: if `true`, the distribution is defined on the unconstrained
  parameter space.
- `nan_on_error=false`: if `true`, any errors from Stan will be suppressed, and `NaN`
  log-density will instead be returned.
"""
function StanDistribution(
    model::BridgeStan.StanModel; unconstrained::Bool=false, nan_on_error::Bool=false
)
    return StanDistribution{unconstrained,nan_on_error}(model)
end

"""
    StanDistribution(stan_file::String, data::String; kwargs...)

Construct a `BridgeStan.StanModel` from a `.stan` file and wrap it as a `StanDistribution`.

`data` should either be a string containing a JSON string literal or a path to a data file
ending in `.json`. If necessary, the model is compiled.

# Keywords

- `unconstrained=false`: if `true`, the distribution is defined on the unconstrained
  parameter space.
- `nan_on_error=false`: if `true`, any errors from Stan will be suppressed, and `NaN`
  log-density will instead be returned.
- `kwargs`:  Remaining `kwargs` are forwarded to
    [`BridgeStan.StanModel`](https://roualdes.github.io/bridgestan/languages/julia.html#BridgeStan.StanModel).

!!! note
    By default, Stan does not compile the model with multithreading support. If this is
    needed, pass `make_args=["STAN_THREADS=true"]` to `kwargs`.
"""
function StanDistribution(
    stan_file::String,
    data::String;
    unconstrained::Bool=false,
    nan_on_error::Bool=false,
    kwargs...,
)
    model = BridgeStan.StanModel(; stan_file, data, kwargs...)
    return StanDistribution(model; unconstrained, nan_on_error)
end

Base.length(dist::ConstrainedStanDistribution) = Int(BridgeStan.param_num(dist.model))
Base.length(dist::UnconstrainedStanDistribution) = Int(BridgeStan.param_unc_num(dist.model))

function Distributions.insupport(
    dist::StanDistribution{unconstrained}, x::AbstractVector{<:Real}
) where {unconstrained}
    length(x) == length(dist) && all(!isnan, x) || return false
    unconstrained && return true
    try
        BridgeStan.param_unconstrain(dist.model, _convert_to_stan_array(x))
        return true
    catch
        return false
    end
end

function _unconstrain(dist::ConstrainedStanDistribution{nan_on_error}) where {nan_on_error}
    return UnconstrainedStanDistribution{nan_on_error}(dist.model)
end

function Distributions.logpdf(dist::StanDistribution, x::AbstractVector{<:Real})
    return _logpdf(dist, _convert_to_stan_array(x))
end

function _logpdf(dist::ConstrainedStanDistribution, x; kwargs...)
    length(x) == length(dist) || throw(
        DimensionMismatch(
            "Length of x, $(length(x)), does not match dimension of distribution, $(length(dist))",
        ),
    )
    y = try
        BridgeStan.param_unconstrain(dist.model, x)
    catch
        return -Inf
    end
    return _logpdf(_unconstrain(dist), y; jacobian=false)
end
function _logpdf(
    dist::UnconstrainedStanDistribution{nan_on_error}, y; kwargs...
) where {nan_on_error}
    try
        return BridgeStan.log_density(dist.model, y; kwargs...)
    catch
        nan_on_error || rethrow()
        return NaN
    end
end

function _logpdf_and_gradient(
    dist::UnconstrainedStanDistribution{nan_on_error}, y; kwargs...
) where {nan_on_error}
    try
        return BridgeStan.log_density_gradient(dist.model, y; kwargs...)
    catch
        nan_on_error || rethrow()
        return NaN, fill(NaN, length(y))
    end
end
