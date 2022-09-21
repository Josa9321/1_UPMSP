struct ModelParams{F <: AbstractFloat, N <: Integer, O} <: ResolutionParams
    optimizer::O
    relative_gap::F
    log::N
    threads::N
end

function initialize_model_params(;optimizer = CPLEX.Optimizer, relative_gap = 1e-4, log = 0, threads = 2)
    return ModelParams(optimizer, relative_gap, log, threads)
end