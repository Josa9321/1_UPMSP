function local_search!(solution::SolutionUPMSP, instance::InstanceUPMSP, ils_params::ILSParams)
    k = 0
    best_makespan = solution.makespan
    while local_search_in_neighboor!(solution, instance) && k < ils_params.same_makespan_tolerance_ls
        if best_makespan == solution.makespan
            k += 1
        end
        best_makespan = solution.makespan
    end
    return solution
end

function local_search_in_neighboor!(solution, instance)
    global VERIFY_FUNCTIONS
    before_makespan_machine = solution.makespan_machine_index
    before_makespan = solution.makespan

    best_index = before_makespan_machine
    best_makespan = before_makespan
    best_new_m = 0
    best_j = 0

    for j in instance.J
        if solution.job_machine[j] != before_makespan_machine
            continue
        end
        for new_m in instance.M
            if new_m != before_makespan_machine
                task_move_neighboor_operation!(solution, new_m, j)
                fitness_function!(solution, instance)
                if solution.makespan <= best_makespan
                    best_index = solution.makespan_machine_index
                    best_makespan = solution.makespan
                    best_new_m = new_m
                    best_j = j
                end
                task_move_neighboor_operation!(solution, before_makespan_machine, j)
            end
        end
    end
    if best_j != 0
        # It found a better solution
        task_move_neighboor_operation!(solution, best_new_m, best_j)
        solution.makespan_machine_index = best_index
        solution.makespan = best_makespan
    else
        # It doesn't found a better solution
        solution.makespan_machine_index = before_makespan_machine
        solution.makespan = before_makespan
    end
    VERIFY_FUNCTIONS ? verify_local_search_loop(solution, instance) : nothing
    return best_j != 0 ? true : false
end

function verify_local_search_loop(solution, instance)
    makespan_local_search = solution.makespan
    machine_makespan = solution.makespan_machine_index
    fitness_function!(solution, instance)
    if makespan_local_search != solution.makespan || machine_makespan != solution.makespan_machine_index
        @error("Solution makespan or makespan machine index is different than it should be.\n$(makespan_local_search) makespan should be $(solution.makespan) || $(machine_makespan) index should be $(solution.makespan_machine_index)")
        solution_address = "./test//error_data"
        save_solution(solution, solution_address)
    end
    return nothing
end

function task_move_neighboor_operation!(solution, new_m, j)
    solution.job_machine[j] = new_m
    return solution
end