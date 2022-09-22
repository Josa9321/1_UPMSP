function local_search!(solution, instance)
    before_makespan_machine = solution.makespan_machine_index
    before_makespan = solution.makespan

    best_index = before_makespan_machine
    best_makespan = before_makespan
    best_new_m = 0
    best_j = 0

    for j in instance.J
        if solution.job_machine[j] != solution.makespan_machine_index
            continue
        end
        for new_m in instance.M
            if new_m != solution.makespan_machine_index
                task_move_neighboor_operation!(solution, new_m, j)
                fitness_function!(solution, instance)
                println(" * solution.makespan = $(solution.makespan)")
                if solution.makespan <= best_makespan
                    println("is better than $best_makespan")
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
        task_move_neighboor_operation!(solution, best_new_m, best_j)
        solution.makespan_machine_index = best_index
        solution.makespan = best_makespan
    end
    return solution
end

function task_move_neighboor_operation!(solution, new_m, j)
    solution.job_machine[j] = new_m
    return solution
end