include("1_solution_struct.jl")

function generate_zero_solution(instance::InstanceUPMSP)
    job_machine = zeros(Int64, instance.J.stop)
    return SolutionUPMSP(job_machine, 0.0)
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
