include("1_solution_struct.jl")

function generate_zero_solution(instance::InstanceUPMSP)
    job_machine = zeros(Int64, instance.J.stop)
    return SolutionUPMSP(job_machine, 0.0, 0)
end

function generate_aleatory_solution(instance::InstanceUPMSP)
    solution = generate_zero_solution(instance)
    return generate_aleatory_solution!(solution, instance)
end

function generate_aleatory_solution!(solution::SolutionUPMSP, instance::InstanceUPMSP)
    for j in instance.J
        solution.job_machine[j] = rand(instance.M_dist)
    end
    fitness_function!(solution, instance)
    return solution
end

function ls_heuristic(instance::InstanceUPMSP)
    # https://www.sciencedirect.com/science/article/pii/S0305048317307922, Wu and Che (2019)
    global VERIFY_FUNCTIONS

    solution = generate_zero_solution(instance)

    machine_complete_time = zeros(instance.M.stop)
    processing_time_efficiency = calculate_processing_time_efficiency(instance)
    non_allocated_jobs = non_allocated_jobs_sorted_by_efficiency(processing_time_efficiency, instance)
    p = 1
    o = 0
    while p <= instance.J.stop && o < 100
        o += 1
        for j_ in instance.J
            selected_machine = select_random_idler_machine(machine_complete_time)
            job = non_allocated_jobs[selected_machine, j_]
            if processing_time_efficiency[selected_machine, job] < 1.0/sqrt(instance.M.stop)
                machine_complete_time[selected_machine] = Inf
                break
            elseif solution.job_machine[job] != 0
                continue
            else
                machine_complete_time[selected_machine] += instance.processing_time[selected_machine, job]
                solution.job_machine[job] = selected_machine
                p += 1
                break
            end
        end
    end
    fitness_function!(solution, instance)
    VERIFY_FUNCTIONS ? verify_upper_bound_heuristic(solution, instance) : nothing
    return solution
end

function non_allocated_jobs_sorted_by_efficiency(processing_time_efficiency, instance)
    global VERIFY_FUNCTIONS
    
    non_allocated_jobs = zeros(Int64, instance.M.stop, instance.J.stop)
    for m in instance.M
        processing_time_efficiency_in_machine = view(processing_time_efficiency, m, instance.J)
        order_in_machine = sortperm(processing_time_efficiency_in_machine, rev = true)
        for j in instance.J
            non_allocated_jobs[m, j] = order_in_machine[j]
        end
    end
    VERIFY_FUNCTIONS ? verify_non_allocated_sorting(non_allocated_jobs, processing_time_efficiency, instance) : nothing
    return non_allocated_jobs
end

function verify_non_allocated_sorting(non_allocated_jobs, processing_time_efficiency, instance)
    for m in instance.M
        machine_m_still_used = true
        job_1 = non_allocated_jobs[m, 1]
        efficiency = processing_time_efficiency[m, job_1]
        for (j_, j) in enumerate(non_allocated_jobs[m, :])
            if efficiency >= processing_time_efficiency[m, j]
                efficiency = processing_time_efficiency[m, j]
                if efficiency < 1/sqrt(instance.M.stop) && machine_m_still_used
                    machine_m_still_used = false
                end
            else
                @error("Efficiency is going up, from job $(j-1) to $(j) in the non_allocated_jobs order")
            end
        end
    end
end

function select_random_idler_machine(machine_complete_time)
    idler_machine_time = minimum(machine_complete_time)
    idler_machines = findall(x -> x == idler_machine_time, machine_complete_time)
    selected_machine = rand(idler_machines)
    return selected_machine
end

function calculate_processing_time_efficiency(instance)
    minimum_processing_time_j = calculate_minimum_processing_time(instance)
    processing_time_efficiency = zeros(instance.M.stop, instance.J.stop)
    for j in instance.J
        for m in instance.M
            processing_time_efficiency[m, j] = minimum_processing_time_j[j]/instance.processing_time[m, j]
        end
    end
    return processing_time_efficiency
end

function calculate_minimum_processing_time(instance)
    minimum_processing_time_j = fill(Inf, instance.J.stop)
    for j in instance.J
        for m in instance.M
            minimum_processing_time_j[j] > instance.processing_time[m, j] ? minimum_processing_time_j[j] = instance.processing_time[m, j] : nothing
        end
    end
    return minimum_processing_time_j
end

function verify_upper_bound_heuristic(solution, instance)
    upmsp_model = solve_instance_by_milp(instance)
    if solution.makespan > 2.5*sqrt(instance.M.stop)*objective_value(upmsp_model)
        @error("Upper bound from the heuristic isn't being respected.")
        solution_address = "./test//error_data"
        save_solution(solution, solution_address)
    end
    return nothing
end