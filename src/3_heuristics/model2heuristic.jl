function convert_model_to_heuristic(upmsp_model, instance; verify_fitness_function = true)
    solution = generate_zero_solution(instance)

    define_job_machine!(solution, upmsp_model, instance)

    model_makespan = objective_value(upmsp_model)
    if verify_fitness_function
        fitness_function!(solution, instance)
        if (0.0 - model_makespan)/model_makespan > 0.05
            println(solution.job_machine)
            println("makespan = $(solution.makespan) != $(model_makespan)")

            save_solution(solution, "./test//error_data")
            
            @error("The objective from the model is different from the fitness_function")
        end
    end

    solution.makespan = model_makespan

    return solution
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