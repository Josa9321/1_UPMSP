struct ModelParams{F <: AbstractFloat, N <: Integer, O} <: ResolutionParams
    optimizer::O
    relative_gap::F
    time_limit::F
    log::N
    threads::N
end

function initialize_model_params(;optimizer = CPLEX.Optimizer, relative_gap = 1e-4, time_limit = 100.0, log = 0, threads = 2)
    return ModelParams(optimizer, Float64(relative_gap), Float64(time_limit), Int64(log), Int64(threads))
end