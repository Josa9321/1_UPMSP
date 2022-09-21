function convert_model_to_heuristic(upmsp_model, instance)
    global VERIFY_FUNCTIONS

    solution = generate_zero_solution(instance)
    define_job_machine!(solution, upmsp_model, instance)
    model_makespan = objective_value(upmsp_model)

    VERIFY_FUNCTIONS ? verify_fitness_function!(solution, instance, model_makespan
        ) : solution.makespan = model_makespan
    
    return solution
end

function verify_fitness_function!(solution, instance, model_makespan)
    fitness_function!(solution, instance)
    if abs((solution.makespan - model_makespan)/model_makespan) > 0.05
        println(solution.job_machine)
        println("makespan = $(solution.makespan) != $(model_makespan)")

        solution_address = "./test//error_data"
        save_solution(solution, solution_address)

        @error("The objective from the model is different from the fitness_function.\nSaving solution at: $solution_address")
        error_1
    end
    return nothing
end

function define_job_machine!(solution, upmsp_model, instance)
    x = value.(upmsp_model[:x])
    for j in instance.J
        for m in instance.M
            # Since the solve used can return a value not equal but close to 1.0, 0.8
            if x[m, j] >= 0.8 
                solution.job_machine[j] = m
            end
        end
    end
    return solution
end