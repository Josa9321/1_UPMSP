struct ILSParams{F <: AbstractFloat, N <: Integer, L, S} <: ResolutionParams
    max_iteration::N
    time_limit::F
    shaking_operation::S
    ls_operation::L
end

function initialize_ils_params(max_iteration = 50, time_limit = 100.0, shaking_operation = nothing, ls_operation = nothing)
    return ILSParams(Int64(max_iteration), FLoat64(time_limit), shaking_operation, ls_operation)
end


function ils(instance::InstanceUPMSP, ils_params::ILSParams)
    start_time = time()
    k = 0
    new_solution = generate_zero_solution(instance)

    # Adoting this initial greedy solution because I want "low-cost solutions quickly", as discussed
    # by Lourenço et al. (2019), in Handbook of Metaheuristics
    best_solution = ls_heuristic(instance) 

    local_search!(best_solution, instance)
    while k < ils_params.max_iteration && time() - start_time < ils_params.time_limit
        pertubation!(new_solution, best_solution, instance, ils_params)
        local_search!(new_solution, instance)
        if new_solution.makespan <= best_solution.makespan 
            # Allowing sideway moves 
            copy_solution!(best_solution, new_solution)
        end
    end
    return best_solution
end