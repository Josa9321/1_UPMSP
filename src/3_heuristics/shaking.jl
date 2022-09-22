using StatsBase

function perturbation!(solution::SolutionUPMSP, instance::InstanceUPMSP, ils_params::ILSParams)
    k = 0
    jobs = sample(instance.J, 2*ils_params.perturbation_num_operations, replace = false)
    for j_1 in range(1, 2*ils_params.perturbation_num_operations, step = 2)
        j_2 = j_1 + 1
        job_1 = jobs[j_1]
        job_2 = jobs[j_2]
        swap_neghboor_operation!(solution, job_1, job_2)
    end
    fitness_function!(solution, instance)
    return solution
end

function swap_neghboor_operation!(solution, j_1, j_2)
    aux = solution.job_machine[j_1]
    solution.job_machine[j_1] = solution.job_machine[j_2]
    solution.job_machine[j_2] = aux
    return solution
end