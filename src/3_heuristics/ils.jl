struct ILSParams{F <: AbstractFloat, N <: Integer} <: ResolutionParams
    max_iteration::N
    time_limit::F
    perturbation_num_operations::N
    same_makespan_tolerance_ls::N
end

function initialize_ils_params(max_iteration::Int64 = 50, time_limit::Float64 = 100.0, perturbation_num_operations::Int64 = 2, same_makespan_tolerance_ls::Int64 = 5)
    return ILSParams(max_iteration, time_limit, perturbation_num_operations, same_makespan_tolerance_ls)
end


function ils(instance::InstanceUPMSP, ils_params::ILSParams = initialize_ils_params())
    start_time = time()
    k = 0
    new_solution = generate_zero_solution(instance)

    # Adoting this initial greedy solution because I want "low-cost solutions quickly", as discussed
    # by Lourenço et al. (2019), in Handbook of Metaheuristics
    best_solution = ls_heuristic(instance) 

    local_search!(best_solution, instance, ils_params)
    while k < ils_params.max_iteration && time() - start_time < ils_params.time_limit
        copy_solution!(new_solution, best_solution)
        perturbation!(new_solution, instance, ils_params)
        local_search!(new_solution, instance, ils_params)
        if new_solution.makespan <= best_solution.makespan 
            # Allowing sideway moves 
            copy_solution!(best_solution, new_solution)
        end
        k += 1
    end
    end_time = time() - start_time
    if VERIFY_FUNCTIONS 
        verify_has_any_zeros(best_solution)
    end
    return best_solution, end_time
end